import SwiftUI

struct InsightsView: View {
    @ObservedObject var store: ExpenseStore

    private var insights: [Insight] {
        InsightEngine.generate(from: store)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    ForEach(insights) { insight in
                        InsightCard(insight: insight)
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
            .background(RV.bg.ignoresSafeArea())
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RV.gold.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24))
                    .foregroundStyle(RV.gold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Smart Analysis")
                    .font(.rvH3)
                    .foregroundStyle(RV.text)
                Text("Based on your spending patterns")
                    .font(.rvCaption)
                    .foregroundStyle(RV.textSecondary)
            }
            Spacer()
        }
        .padding()
        .rvCard()
    }
}
