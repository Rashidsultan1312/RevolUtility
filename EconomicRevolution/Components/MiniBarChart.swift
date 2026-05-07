import SwiftUI

struct MiniBarChart: View {
    let data: [(Date, Double, Double)]
    var height: CGFloat = 100

    private var maxVal: Double {
        data.flatMap { [$0.1, $0.2] }.max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 2) {
                    HStack(alignment: .bottom, spacing: 1) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(RV.income)
                            .frame(width: 8, height: max(2, CGFloat(item.1 / maxVal) * height))

                        RoundedRectangle(cornerRadius: 2)
                            .fill(RV.expense)
                            .frame(width: 8, height: max(2, CGFloat(item.2 / maxVal) * height))
                    }

                    Text(dayLabel(item.0))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(RV.textMuted)
                }
            }
        }
        .frame(height: height + 16)
    }

    private func dayLabel(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        return String(fmt.string(from: date).prefix(2))
    }
}
