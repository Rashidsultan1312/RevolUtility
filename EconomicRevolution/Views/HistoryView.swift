import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: ExpenseStore
    @State private var filter = 0
    @State private var search = ""

    private var filtered: [Transaction] {
        var txs = store.transactions
        switch filter {
        case 1: txs = txs.filter(\.isIncome)
        case 2: txs = txs.filter { !$0.isIncome }
        default: break
        }
        if !search.isEmpty {
            txs = txs.filter { $0.note.localizedCaseInsensitiveContains(search) || $0.category.label.localizedCaseInsensitiveContains(search) }
        }
        return txs
    }

    private var grouped: [(String, [Transaction])] {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        let dict = Dictionary(grouping: filtered) { fmt.string(from: $0.date) }
        return dict.sorted { lhs, rhs in
            (lhs.value.first?.date ?? .distantPast) > (rhs.value.first?.date ?? .distantPast)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                filterBar

                if filtered.isEmpty {
                    emptyState
                } else {
                    transactionsList
                }
            }
            .background(RV.bg.ignoresSafeArea())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RV.textMuted)
            TextField("", text: $search, prompt: Text("Search transactions").foregroundColor(RV.textMuted))
                .font(.rvBody)
                .foregroundStyle(RV.text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !search.isEmpty {
                Button {
                    search = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(RV.textMuted)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: RV.radiusSm)
                .fill(RV.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: RV.radiusSm)
                .stroke(RV.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var filterBar: some View {
        Picker("Filter", selection: $filter) {
            Text("All").tag(0)
            Text("Income").tag(1)
            Text("Expense").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            ZStack {
                Circle()
                    .fill(RV.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "tray")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(RV.accentBright)
            }
            Text(emptyTitle)
                .font(.rvH3)
                .foregroundStyle(RV.text)
            Text(emptySubtitle)
                .font(.rvBody)
                .foregroundStyle(RV.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTitle: String {
        if !search.isEmpty { return "Nothing found" }
        if store.transactions.isEmpty { return "No transactions yet" }
        switch filter {
        case 1: return "No income"
        case 2: return "No expenses"
        default: return "Empty"
        }
    }

    private var emptySubtitle: String {
        if !search.isEmpty { return "Try a different search query" }
        if store.transactions.isEmpty { return "Tap + to add your first transaction" }
        return "Switch the filter above to see other entries"
    }

    private var transactionsList: some View {
        List {
            ForEach(grouped, id: \.0) { section in
                Section {
                    ForEach(section.1) { tx in
                        txRow(tx)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.delete(tx)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowBackground(RV.card)
                            .listRowSeparatorTint(RV.hairline)
                    }
                } header: {
                    Text(section.0)
                        .font(.rvCaption)
                        .foregroundStyle(RV.textSecondary)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func txRow(_ tx: Transaction) -> some View {
        HStack(spacing: 12) {
            Image(systemName: tx.category.icon)
                .font(.system(size: 14))
                .foregroundStyle(tx.category.color)
                .frame(width: 36, height: 36)
                .background(tx.category.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.note.isEmpty ? tx.category.label : tx.note)
                    .font(.rvBody)
                    .foregroundStyle(RV.text)
                Text(tx.category.label)
                    .font(.rvCaption)
                    .foregroundStyle(RV.textMuted)
            }

            Spacer()

            Text(formatAmount(tx))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(tx.isIncome ? RV.income : RV.expense)
        }
        .padding(.vertical, 4)
    }

    private func formatAmount(_ tx: Transaction) -> String {
        let sign = tx.isIncome ? "+" : "-"
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = UserDefaults.standard.string(forKey: "rv_currency") ?? "USD"
        fmt.maximumFractionDigits = 2
        let str = fmt.string(from: NSNumber(value: tx.amount)) ?? "$\(tx.amount)"
        return "\(sign)\(str)"
    }
}
