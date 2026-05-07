import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var store: ExpenseStore
    @Environment(\.dismiss) private var dismiss

    @State private var isIncome = false
    @State private var amount = ""
    @State private var category: ExpCategory = .food
    @State private var note = ""
    @State private var date = Date()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    private var categories: [ExpCategory] {
        isIncome ? ExpCategory.incomeCategories : ExpCategory.expenseCategories
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    typePicker
                    amountField
                    categoryGrid
                    detailFields
                }
                .padding()
            }
            .background(RV.bg.ignoresSafeArea())
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(RV.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(RV.gold)
                        .disabled(amount.isEmpty)
                }
            }
        }
    }

    private var typePicker: some View {
        HStack(spacing: 0) {
            typeTab("Expense", active: !isIncome, color: RV.expense) { isIncome = false; category = .food }
            typeTab("Income", active: isIncome, color: RV.income) { isIncome = true; category = .salary }
        }
        .background(RV.card)
        .clipShape(RoundedRectangle(cornerRadius: RV.radiusSm))
    }

    private func typeTab(_ label: String, active: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(active ? RV.onGold : RV.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(active ? color : .clear)
                .clipShape(RoundedRectangle(cornerRadius: RV.radiusSm))
        }
    }

    private var amountField: some View {
        VStack(spacing: 8) {
            Text(isIncome ? "+" : "-")
                .font(.rvH2)
                .foregroundStyle(isIncome ? RV.income : RV.expense)

            TextField("0.00", text: $amount)
                .font(.rvBigAmount)
                .foregroundStyle(RV.gold)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
        }
        .padding(.vertical, 16)
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories) { cat in
                Button {
                    category = cat
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: cat.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(category == cat ? RV.onGold : cat.color)
                            .frame(width: 44, height: 44)
                            .background(category == cat ? cat.color : cat.color.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text(cat.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(category == cat ? RV.text : RV.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    private var detailFields: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(RV.textMuted)
                TextField("Note (optional)", text: $note)
                    .foregroundStyle(RV.text)
            }
            .padding(12)
            .rvCard()

            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(RV.textMuted)
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .tint(RV.gold)
                Spacer()
            }
            .padding(12)
            .rvCard()
        }
    }

    private func save() {
        guard let val = Double(amount.replacingOccurrences(of: ",", with: ".")), val > 0 else { return }
        let tx = Transaction(amount: val, category: category, isIncome: isIncome, note: note, date: date)
        store.add(tx)
        dismiss()
    }
}
