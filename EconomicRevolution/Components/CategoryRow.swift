import SwiftUI

struct CategoryRow: View {
    let category: ExpCategory
    let amount: Double
    let total: Double

    private var ratio: Double {
        guard total > 0 else { return 0 }
        return amount / total
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 14))
                .foregroundStyle(category.color)
                .frame(width: 32, height: 32)
                .background(category.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.label)
                        .font(.rvBody)
                        .foregroundStyle(RV.text)
                    Spacer()
                    Text(formatAmount(amount))
                        .font(.rvMono)
                        .foregroundStyle(RV.text)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(RV.border)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(category.color)
                            .frame(width: geo.size.width * ratio, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatAmount(_ val: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = UserDefaults.standard.string(forKey: "rv_currency") ?? "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: NSNumber(value: val)) ?? "$\(Int(val))"
    }
}
