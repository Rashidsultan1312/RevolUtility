import SwiftUI

struct DashboardView: View {
    @ObservedObject var store: ExpenseStore

    private var insights: [Insight] {
        InsightEngine.generate(from: store)
    }

    private var breakdown: [(ExpCategory, Double)] {
        store.categoryBreakdown(days: 30)
    }

    private var totalExpenseMonth: Double {
        breakdown.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                topBar
                balanceHero
                donutBlock
                categoriesCard
                weekCard
                insightsRail
                Color.clear.frame(height: 120)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(RV.bg.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingCaption)
                    .font(.rvCaption)
                    .foregroundStyle(RV.textSecondary)
                Text("Economic Revolution")
                    .font(.rvTitle)
                    .foregroundStyle(RV.text)
            }
            Spacer()
            Button {} label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RV.text)
                    .frame(width: 40, height: 40)
                    .background(RV.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(RV.hairline, lineWidth: 1))
            }
        }
    }

    private var balanceHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("TOTAL BALANCE")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(RV.textSecondary)
                Spacer()
                deltaChip
            }

            AnimatedCounter(
                value: store.balance,
                prefix: store.balance >= 0 ? "$" : "-$",
                font: .rvBigAmount,
                color: RV.text
            )

            HStack(spacing: 10) {
                balancePill(
                    icon: "arrow.down.left",
                    label: "Income",
                    value: store.totalIncome,
                    color: RV.income
                )
                balancePill(
                    icon: "arrow.up.right",
                    label: "Expense",
                    value: store.totalExpense,
                    color: RV.expense
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: RV.radius)
                .fill(RV.cardGrad)
        )
        .overlay(
            RoundedRectangle(cornerRadius: RV.radius)
                .stroke(RV.accent.opacity(0.25), lineWidth: 1)
        )
    }

    private var deltaChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.up.right")
                .font(.system(size: 10, weight: .bold))
            Text("+12.4%")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .foregroundStyle(RV.accentBright)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(RV.accent.opacity(0.15))
        )
        .overlay(
            Capsule().stroke(RV.accent.opacity(0.3), lineWidth: 0.5)
        )
    }

    private func balancePill(icon: String, label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 26, height: 26)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(RV.textSecondary)
                Text(formatCurrency(value))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(RV.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: RV.radiusSm)
                .fill(RV.surface)
        )
    }

    private var donutBlock: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Spending")
                    .font(.rvH2)
                    .foregroundStyle(RV.text)
                Spacer()
                Text("Last 30 days")
                    .font(.rvCaption)
                    .foregroundStyle(RV.textSecondary)
            }

            CategoryChart(data: breakdown, size: 220) {
                VStack(spacing: 4) {
                    Text("SPENT")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(RV.textSecondary)
                    Text(formatCurrency(totalExpenseMonth))
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(RV.text)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text("this month")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(RV.textMuted)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .rvCard()
    }

    private var categoriesCard: some View {
        let top = Array(breakdown.prefix(5))
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Top categories")
                    .font(.rvH3)
                    .foregroundStyle(RV.text)
                Spacer()
                Text("See all")
                    .font(.rvCaption)
                    .foregroundStyle(RV.accentBright)
            }

            if top.isEmpty {
                Text("No transactions yet")
                    .font(.rvBody)
                    .foregroundStyle(RV.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(top.enumerated()), id: \.offset) { idx, item in
                        CategoryRow(category: item.0, amount: item.1, total: totalExpenseMonth)
                        if idx < top.count - 1 {
                            Rectangle()
                                .fill(RV.hairline)
                                .frame(height: 1)
                                .padding(.leading, 44)
                        }
                    }
                }
            }
        }
        .padding(18)
        .rvCard()
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("This week")
                    .font(.rvH3)
                    .foregroundStyle(RV.text)
                Spacer()
                BalanceRing(
                    income: store.totalIncome,
                    expense: store.totalExpense,
                    size: 40
                )
            }

            MiniBarChart(data: store.dailyTotals(days: 7), height: 100)
        }
        .padding(18)
        .rvCard()
    }

    private var insightsRail: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(RV.accentBright)
                Text("Insights")
                    .font(.rvH3)
                    .foregroundStyle(RV.text)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insights.prefix(4)) { insight in
                        InsightCard(insight: insight)
                            .frame(width: 260)
                    }
                }
            }
            .padding(.horizontal, -20)
            .padding(.leading, 20)
        }
    }

    private var greetingCaption: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Welcome back"
        }
    }

    private func formatCurrency(_ val: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = UserDefaults.standard.string(forKey: "rv_currency") ?? "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: NSNumber(value: val)) ?? "$\(Int(val))"
    }
}
