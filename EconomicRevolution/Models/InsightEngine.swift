import Foundation

struct Insight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let trend: InsightTrend
}

enum InsightTrend {
    case up, down, neutral
}

@MainActor
struct InsightEngine {
    static func generate(from store: ExpenseStore) -> [Insight] {
        var insights: [Insight] = []
        let txs = store.transactions
        guard !txs.isEmpty else {
            return [Insight(icon: "plus.circle", title: "Start tracking", value: "Add your first transaction to get insights", trend: .neutral)]
        }

        let thisMonth = store.transactionsForPeriod(30)
        let lastMonth = txs.filter {
            let days = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 0
            return days >= 30 && days < 60
        }

        let thisExpense = thisMonth.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
        let lastExpense = lastMonth.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }

        if lastExpense > 0 {
            let change = ((thisExpense - lastExpense) / lastExpense) * 100
            let trend: InsightTrend = change > 0 ? .up : .down
            let dir = change > 0 ? "up" : "down"
            insights.append(Insight(
                icon: change > 0 ? "arrow.up.right" : "arrow.down.right",
                title: "Monthly spending",
                value: "Your spending is \(abs(Int(change)))% \(dir) vs last month",
                trend: trend
            ))
        }

        let breakdown = store.categoryBreakdown(days: 30)
        if let top = breakdown.first, thisExpense > 0 {
            let pct = Int((top.1 / thisExpense) * 100)
            insights.append(Insight(
                icon: "chart.pie.fill",
                title: "Top category",
                value: "\(top.0.label) is your biggest expense (\(pct)%)",
                trend: .neutral
            ))
        }

        let income30 = thisMonth.filter(\.isIncome).reduce(0) { $0 + $1.amount }
        if income30 > 0 {
            let saved = income30 - thisExpense
            let rate = Int((saved / income30) * 100)
            if rate > 0 {
                insights.append(Insight(
                    icon: "leaf.fill",
                    title: "Saving rate",
                    value: "You saved \(rate)% of your income this month",
                    trend: .up
                ))
            } else {
                insights.append(Insight(
                    icon: "exclamationmark.triangle.fill",
                    title: "Over budget",
                    value: "You spent \(abs(rate))% more than you earned",
                    trend: .down
                ))
            }
        }

        let dailies = store.dailyTotals(days: 7)
        let weekExpenses = dailies.map(\.2)
        if weekExpenses.count >= 3 {
            let recent3 = Array(weekExpenses.suffix(3))
            let allDecreasing = recent3.enumerated().allSatisfy { idx, val in
                idx == 0 || val <= recent3[idx - 1]
            }
            if allDecreasing && recent3.last ?? 0 > 0 {
                insights.append(Insight(
                    icon: "arrow.down.right.circle.fill",
                    title: "Spending trend",
                    value: "Daily expenses dropping 3 days in a row",
                    trend: .down
                ))
            }
        }

        let subTotal = thisMonth.filter { $0.category == .subscriptions }.reduce(0) { $0 + $1.amount }
        if subTotal > 0 && income30 > 0 {
            let pct = Int((subTotal / income30) * 100)
            if pct >= 5 {
                insights.append(Insight(
                    icon: "repeat.circle.fill",
                    title: "Subscriptions",
                    value: "Recurring costs take \(pct)% of income",
                    trend: pct > 15 ? .up : .neutral
                ))
            }
        }

        let txCount = thisMonth.count
        if txCount > 0 {
            let avgPerDay = thisExpense / 30
            let fmt = String(format: "$%.0f", avgPerDay)
            insights.append(Insight(
                icon: "calendar",
                title: "Daily average",
                value: "You spend about \(fmt) per day",
                trend: .neutral
            ))
        }

        return Array(insights.prefix(6))
    }
}
