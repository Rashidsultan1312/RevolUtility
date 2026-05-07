import SwiftUI

struct CategoryChart<Center: View>: View {
    let data: [(ExpCategory, Double)]
    var size: CGFloat = 240
    let center: () -> Center

    @State private var animProgress: Double = 0

    private var total: Double {
        data.reduce(0) { $0 + $1.1 }
    }

    private let ringWidth: CGFloat = 28

    init(
        data: [(ExpCategory, Double)],
        size: CGFloat = 240,
        @ViewBuilder center: @escaping () -> Center
    ) {
        self.data = data
        self.size = size
        self.center = center
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(RV.hairline, lineWidth: 1)
                .frame(width: size, height: size)

            Circle()
                .stroke(RV.card, lineWidth: ringWidth)
                .frame(width: size - ringWidth, height: size - ringWidth)

            if total > 0 {
                donutSlices
            }

            center()
                .frame(width: size - ringWidth * 2 - 16, height: size - ringWidth * 2 - 16)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                animProgress = 1
            }
        }
    }

    private var donutSlices: some View {
        ZStack {
            ForEach(Array(sliceAngles.enumerated()), id: \.offset) { idx, angles in
                DonutSlice(
                    startAngle: angles.0,
                    endAngle: Angle.degrees(angles.0.degrees + (angles.1.degrees - angles.0.degrees) * animProgress),
                    thickness: ringWidth
                )
                .fill(data[idx].0.color)
            }
        }
        .frame(width: size - ringWidth, height: size - ringWidth)
    }

    private var sliceAngles: [(Angle, Angle)] {
        var result: [(Angle, Angle)] = []
        var current = Angle.degrees(-90)
        for item in data {
            let sweep = Angle.degrees((item.1 / total) * 360)
            result.append((current, current + sweep))
            current = current + sweep
        }
        return result
    }
}

extension CategoryChart where Center == DefaultChartCenter {
    init(data: [(ExpCategory, Double)], size: CGFloat = 240) {
        let total = data.reduce(0) { $0 + $1.1 }
        self.init(data: data, size: size) {
            DefaultChartCenter(total: total)
        }
    }
}

struct DefaultChartCenter: View {
    let total: Double

    var body: some View {
        VStack(spacing: 4) {
            Text("Total")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.2)
                .foregroundStyle(RV.textSecondary)
            Text(formatAmount(total))
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(RV.text)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
    }

    private func formatAmount(_ val: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = UserDefaults.standard.string(forKey: "rv_currency") ?? "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: NSNumber(value: val)) ?? "$\(Int(val))"
    }
}

struct DonutSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR - thickness

        var p = Path()
        p.addArc(center: center, radius: outerR, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        p.addArc(center: center, radius: innerR, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        p.closeSubpath()
        return p
    }
}
