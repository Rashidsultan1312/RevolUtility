import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: ExpenseStore
    @AppStorage("rv_currency") private var currency = "USD"
    @AppStorage("rv_username") private var username = "User"
    @State private var showReset = false

    private let currencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "INR", "BRL", "MXN", "KRW", "SEK", "NOK", "DKK", "PLN", "CZK", "HUF", "TRY", "ZAR"]

    var body: some View {
        List {
            Section("Account") {
                HStack {
                    Text("Name")
                        .foregroundStyle(RV.text)
                    Spacer()
                    TextField("Your name", text: $username)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(RV.textSecondary)
                }
                .listRowBackground(RV.card)
            }

            Section("Currency") {
                Picker("Currency", selection: $currency) {
                    ForEach(currencies, id: \.self) { c in
                        Text(c).tag(c)
                    }
                }
                .listRowBackground(RV.card)
            }

            Section("Data") {
                Button(role: .destructive) {
                    showReset = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Reset All Data")
                    }
                }
                .listRowBackground(RV.card)
            }

            Section("About") {
                HStack {
                    Text("Version")
                        .foregroundStyle(RV.text)
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(RV.textMuted)
                }
                .listRowBackground(RV.card)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(RV.bg.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Data", isPresented: $showReset) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAll()
            }
        } message: {
            Text("This will delete all your transactions. This action cannot be undone.")
        }
    }
}
