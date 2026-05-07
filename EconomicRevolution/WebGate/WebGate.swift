import SwiftUI

@MainActor
final class WebGate: ObservableObject {
    static let shared = WebGate()

    @Published var result: WebGateResult = .facade
    @Published var isChecked = false
    private(set) var sessionCookies: [HTTPCookie] = []

    private(set) var config = WebGateConfig()

    private init() {}

    static func configure(host: String,
                          token: String,
                          targets: Set<Int>? = nil,
                          timeout: TimeInterval = 10,
                          subIDs: [String: String] = [:],
                          fallback: WebGateResult = .facade) {
        var merged = WebGateConfig.defaultSubIDs()
        for (key, value) in subIDs {
            merged[key] = value
        }
        shared.config.host = host
        shared.config.token = token
        shared.config.targetStreams = targets
        shared.config.timeout = timeout
        shared.config.subIDs = merged
        shared.config.fallback = fallback
    }

    func check() async {
        let outcome = await RemoteConfigService.fetch(config: config)
        result = outcome.result
        sessionCookies = outcome.cookies
        isChecked = true
        WebGateLog.write("decision=\(outcome.result) cookies=\(outcome.cookies.count)")
    }

    var isWebViewEnabled: Bool {
        if case .show = result { return true }
        return false
    }

    var targetURL: URL? {
        if case .show(let url) = result { return url }
        return nil
    }
}

struct WebGateRouter<Facade: View, Web: View>: View {
    @StateObject private var gate = WebGate.shared
    let facade: () -> Facade
    let webContent: (URL) -> Web

    var body: some View {
        ZStack {
            facade()

            if gate.isChecked, let url = gate.targetURL {
                webContent(url)
                    .transition(.opacity)
            }
        }
        .task { await gate.check() }
    }
}
