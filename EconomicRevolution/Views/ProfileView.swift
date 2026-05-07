import SwiftUI

struct ProfileView: View {
    @ObservedObject var store: ExpenseStore
    @AppStorage("rv_username") private var username = "User"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatarSection
                    statsGrid
                    menuSection
                }
                .padding()
                .padding(.bottom, 80)
            }
            .background(RV.bg.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(RV.goldGrad)
                    .frame(width: 80, height: 80)
                Text(String(username.prefix(1)).uppercased())
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(RV.onGold)
            }

            Text(username)
                .font(.rvH2)
                .foregroundStyle(RV.text)

            Text("Member since \(memberDate)")
                .font(.rvCaption)
                .foregroundStyle(RV.textSecondary)
        }
        .padding(.vertical)
    }

    private var memberDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return fmt.string(from: Date())
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            statCard("Saved", value: formatCurrency(max(0, store.totalIncome - store.totalExpense)), icon: "leaf.fill", color: RV.income)
            statCard("Transactions", value: "\(store.transactions.count)", icon: "list.bullet", color: RV.gold)
            statCard("Categories", value: "\(Set(store.transactions.map(\.category)).count)", icon: "square.grid.2x2.fill", color: Color(hex: 0xAB47BC))
        }
    }

    private func statCard(_ label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(RV.text)
            Text(label)
                .font(.rvCaption)
                .foregroundStyle(RV.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .rvCard()
    }

    private var menuSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                SettingsView(store: store)
            } label: {
                menuRow(icon: "gearshape.fill", title: "Settings", color: RV.textSecondary)
            }

            Divider().background(RV.border)

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                menuRow(icon: "hand.raised.fill", title: "Privacy Policy", color: RV.textSecondary)
            }

            Divider().background(RV.border)

            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(RV.textSecondary)
                    .frame(width: 30)
                Text("Support")
                    .font(.rvBody)
                    .foregroundStyle(RV.text)
                Spacer()
                Text("dymvi66@icloud.com")
                    .font(.rvCaption)
                    .foregroundStyle(RV.textSecondary)
                    .textSelection(.enabled)
            }
            .padding(14)
        }
        .rvCard()
    }

    private func menuRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 30)
            Text(title)
                .font(.rvBody)
                .foregroundStyle(RV.text)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RV.textMuted)
        }
        .padding(14)
    }

    private func formatCurrency(_ val: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = UserDefaults.standard.string(forKey: "rv_currency") ?? "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: NSNumber(value: val)) ?? "$\(Int(val))"
    }
}
