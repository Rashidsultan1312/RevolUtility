import SwiftUI

struct ContentView: View {
    @StateObject private var store = ExpenseStore.shared
    @AppStorage("rv_onboarded") private var onboarded = false
    @State private var tab = 0
    @State private var showAdd = false

    var body: some View {
        WebGateRouter {
            Group {
                if onboarded {
                    mainView
                } else {
                    OnboardingView { onboarded = true }
                }
            }
        } webContent: { url in
            WebGateView(url: url)
        }
    }

    private var mainView: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case 0: DashboardView(store: store)
                case 1: InsightsView(store: store)
                case 2: HistoryView(store: store)
                case 3: StatsView(store: store)
                case 4: ProfileView(store: store)
                default: DashboardView(store: store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            floatingBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAdd) {
            AddTransactionView(store: store)
        }
    }

    private var floatingBar: some View {
        HStack(spacing: 6) {
            tabPill(icon: "chart.pie.fill", label: "Home", tag: 0)
            tabPill(icon: "brain.head.profile", label: "Insights", tag: 1)

            Button { showAdd = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(RV.emeraldGrad)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(RV.gold.opacity(0.4), lineWidth: 1))
            }
            .shadow(color: RV.emerald.opacity(0.4), radius: 6, y: 2)

            tabPill(icon: "clock.fill", label: "History", tag: 2)
            tabPill(icon: "person.fill", label: "Profile", tag: 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(RV.surface.opacity(0.95))
                .overlay(
                    Capsule()
                        .stroke(RV.border, lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func tabPill(icon: String, label: String, tag: Int) -> some View {
        let active = tab == tag
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { tab = tag }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                if active {
                    Text(label)
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(1)
                }
            }
            .foregroundStyle(active ? .white : RV.textMuted)
            .padding(.horizontal, active ? 12 : 10)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(active ? RV.emerald.opacity(0.9) : .clear)
            )
        }
    }
}
