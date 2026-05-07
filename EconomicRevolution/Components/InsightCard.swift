import SwiftUI

struct InsightCard: View {
    let insight: Insight

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(trendColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(trendColor.opacity(0.3), lineWidth: 1)
                    .frame(width: 44, height: 44)
                Image(systemName: insight.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(trendColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.rvCaption)
                    .foregroundStyle(RV.accentBright)
                Text(insight.value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RV.text)
                    .lineLimit(2)
            }

            Spacer()

            trendBadge
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(RV.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(RV.hairline, lineWidth: 1)
        )
    }

    private var trendColor: Color {
        switch insight.trend {
        case .up: return RV.expense
        case .down: return RV.income
        case .neutral: return RV.gold
        }
    }

    @ViewBuilder
    private var trendBadge: some View {
        let (icon, color): (String, Color) = {
            switch insight.trend {
            case .up: return ("arrow.up.right", RV.expense)
            case .down: return ("arrow.down.right", RV.income)
            case .neutral: return ("minus", RV.textMuted)
            }
        }()

        Image(systemName: icon)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(color)
            .frame(width: 28, height: 28)
            .background(color.opacity(0.12))
            .clipShape(Circle())
    }
}
