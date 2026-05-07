import SwiftUI

struct CategoriesView: View {
    @ObservedObject var store: ExpenseStore

    private var breakdown: [(ExpCategory, Double)] {
        store.categoryBreakdown(days: 30)
    }

    private var total: Double {
        breakdown.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(breakdown, id: \.0) { item in
                        categoryCard(item.0, amount: item.1)
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
            .background(RV.bg.ignoresSafeArea())
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func categoryCard(_ cat: ExpCategory, amount: Double) -> some View {
        let pct = total > 0 ? Int((amount / total) * 100) : 0
        return HStack(spacing: 14) {
            Image(systemName: cat.icon)
                .font(.system(size: 18))
                .foregroundStyle(cat.color)
                .frame(width: 44, height: 44)
                .background(cat.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(cat.label)
                    .font(.rvH3)
                    .foregroundStyle(RV.text)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RV.border)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(cat.color)
                            .frame(width: geo.size.width * (total > 0 ? amount / total : 0), height: 8)
                    }
                }
                .frame(height: 8)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatAmount(amount))
                    .font(.rvMono)
                    .foregroundStyle(RV.text)
                Text("\(pct)%")
                    .font(.rvPercent)
                    .foregroundStyle(RV.gold)
            }
        }
        .padding(14)
        .rvCard(glow: cat.color.opacity(0.2))
    }

    private func formatAmount(_ val: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = UserDefaults.standard.string(forKey: "rv_currency") ?? "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: NSNumber(value: val)) ?? "$\(Int(val))"
    }
}
