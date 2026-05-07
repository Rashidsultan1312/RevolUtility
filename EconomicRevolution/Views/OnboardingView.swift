import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var page = 0

    private let pages: [(String, String, String)] = [
        ("chart.pie.fill", "Track Every Dollar", "See exactly where your money goes with beautiful visual breakdowns"),
        ("brain.head.profile", "AI-Powered Insights", "Get smart recommendations to optimize your spending habits"),
        ("target", "Reach Your Goals", "Set budgets, track progress, and achieve financial freedom"),
    ]

    var body: some View {
        ZStack {
            RV.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(0..<pages.count, id: \.self) { idx in
                        pageView(pages[idx])
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                bottomButtons
                    .padding(.bottom, 40)
            }
        }
    }

    private func pageView(_ data: (String, String, String)) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(RV.emerald.opacity(0.12))
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(RV.emeraldGrad, lineWidth: 2.5)
                    .frame(width: 120, height: 120)
                Image(systemName: data.0)
                    .font(.system(size: 48))
                    .foregroundStyle(RV.gold)
            }

            Text(data.1)
                .font(.rvTitle)
                .foregroundStyle(RV.text)
                .multilineTextAlignment(.center)

            Text(data.2)
                .font(.rvBody)
                .foregroundStyle(RV.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private var bottomButtons: some View {
        HStack {
            if page < pages.count - 1 {
                Button("Skip") {
                    onComplete()
                }
                .font(.rvBody)
                .foregroundStyle(RV.textMuted)

                Spacer()

                Button("Next") {
                    withAnimation { page += 1 }
                }
                .rvPrimaryButton()
            } else {
                Spacer()

                Button("Get Started") {
                    onComplete()
                }
                .rvPrimaryButton()

                Spacer()
            }
        }
        .padding(.horizontal, 24)
    }
}
