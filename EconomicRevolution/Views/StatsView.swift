import SwiftUI

struct StatsView: View {
    @ObservedObject var store: ExpenseStore
    @State private var period = 30

    private var breakdown: [(ExpCategory, Double)] {
        store.categoryBreakdown(days: period)
    }

    private var totalExpense: Double {
        breakdown.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Period", selection: $period) {
                        Text("7 days").tag(7)
                        Text("30 days").tag(30)
                        Text("All").tag(9999)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    CategoryChart(data: breakdown, size: 200)

                    chartSection

                    categoryList
                }
                .padding(.bottom, 100)
            }
            .background(RV.bg.ignoresSafeArea())
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Flow")
                .font(.rvH3)
                .foregroundStyle(RV.text)

            MiniBarChart(
                data: store.dailyTotals(days: min(period, 14)),
                height: 120
            )
        }
        .padding()
        .rvCard()
        .padding(.horizontal)
    }

    private var categoryList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("By Category")
                .font(.rvH3)
                .foregroundStyle(RV.text)
                .padding(.horizontal)

            ForEach(breakdown, id: \.0) { item in
                CategoryRow(category: item.0, amount: item.1, total: totalExpense)
                    .padding(.horizontal)
            }
        }
    }
}
