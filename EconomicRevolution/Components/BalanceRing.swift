import SwiftUI

struct BalanceRing: View {
    let income: Double
    let expense: Double
    var size: CGFloat = 60

    private var ratio: Double {
        guard income > 0 else { return 0 }
        return min(expense / income, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(RV.emerald.opacity(0.25), lineWidth: 6)

            Circle()
                .trim(from: 0, to: ratio)
                .stroke(
                    ratio > 0.85 ? RV.expense : RV.emerald,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(Int(ratio * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundStyle(ratio > 0.85 ? RV.expense : RV.emerald)
                Text("spent")
                    .font(.system(size: size * 0.12, weight: .medium))
                    .foregroundStyle(RV.textMuted)
            }
        }
        .frame(width: size, height: size)
    }
}
