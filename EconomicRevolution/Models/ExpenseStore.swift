import SwiftUI

@MainActor
final class ExpenseStore: ObservableObject {
    static let shared = ExpenseStore()

    @Published var transactions: [Transaction] = []

    private let cacheKey = "rv_transactions_v1"

    private init() {
        loadFromCache()
    }

    var balance: Double {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }

    var totalIncome: Double {
        transactions.filter(\.isIncome).reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    func add(_ tx: Transaction) {
        transactions.insert(tx, at: 0)
        saveToCache()
    }

    func delete(_ tx: Transaction) {
        transactions.removeAll { $0.id == tx.id }
        saveToCache()
    }

    func resetAll() {
        transactions.removeAll()
        saveToCache()
    }

    func transactionsForPeriod(_ days: Int) -> [Transaction] {
        guard days < 9000 else { return transactions }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return transactions.filter { $0.date >= cutoff }
    }

    func categoryBreakdown(days: Int, incomeOnly: Bool = false) -> [(ExpCategory, Double)] {
        let txs = transactionsForPeriod(days).filter { $0.isIncome == incomeOnly }
        var map: [ExpCategory: Double] = [:]
        for tx in txs { map[tx.category, default: 0] += tx.amount }
        return map.sorted { $0.value > $1.value }
    }

    func dailyTotals(days: Int) -> [(Date, Double, Double)] {
        let cal = Calendar.current
        let txs = transactionsForPeriod(days)
        var result: [(Date, Double, Double)] = []
        for offset in (0..<days).reversed() {
            let day = cal.date(byAdding: .day, value: -offset, to: cal.startOfDay(for: Date()))!
            let dayTxs = txs.filter { cal.isDate($0.date, inSameDayAs: day) }
            let inc = dayTxs.filter(\.isIncome).reduce(0) { $0 + $1.amount }
            let exp = dayTxs.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
            result.append((day, inc, exp))
        }
        return result
    }

    private func saveToCache() {
        guard let data = try? JSONEncoder().encode(transactions) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }

    private func loadFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let txs = try? JSONDecoder().decode([Transaction].self, from: data) else { return }
        transactions = txs
    }

    func seedDemoIfEmpty() {
        guard transactions.isEmpty else { return }
        let cal = Calendar.current
        let demos: [(Double, ExpCategory, Bool, String, Int)] = [
            (4200, .salary, true, "Monthly salary", -25),
            (650, .freelance, true, "Design project", -18),
            (120, .investment, true, "Dividends", -10),
            (89.50, .food, false, "Grocery store", -1),
            (45, .food, false, "Restaurant", -3),
            (32, .transport, false, "Gas station", -2),
            (15.99, .subscriptions, false, "Streaming service", -5),
            (250, .shopping, false, "New headphones", -7),
            (75, .utilities, false, "Electric bill", -12),
            (120, .entertainment, false, "Concert tickets", -4),
            (40, .health, false, "Pharmacy", -6),
            (180, .travel, false, "Weekend trip", -8),
        ]
        for (amt, cat, inc, note, dayOffset) in demos {
            let date = cal.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            transactions.append(Transaction(amount: amt, category: cat, isIncome: inc, note: note, date: date))
        }
        saveToCache()
    }
}
