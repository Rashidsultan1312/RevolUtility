import SwiftUI

@main
struct EconomicRevolutionApp: App {
    init() {
        WebGate.configure(
            host: AppConfig.relayHost,
            token: AppConfig.relayKey,
            targets: AppConfig.relayTargets,
            timeout: AppConfig.relayTimeout
        )
        setupAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }

    private func setupAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(RV.bg)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(RV.text)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(RV.text)]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(RV.surface)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().isHidden = true
    }
}
