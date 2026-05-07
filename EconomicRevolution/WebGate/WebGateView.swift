import SwiftUI
import WebKit

@MainActor
final class WebViewModel: NSObject, ObservableObject {
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false
    @Published var progress: Double = 0

    let webView: WKWebView
    let homeURL: URL

    private var observations: [NSKeyValueObservation] = []
    private var reloadAttempts = 0
    private let reloadCeiling = 4

    init(homeURL: URL, userAgent: String, sessionCookies: [HTTPCookie] = []) {
        self.homeURL = homeURL

        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.allowsBackForwardNavigationGestures = true
        wv.scrollView.bounces = true
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.backgroundColor = .clear
        wv.customUserAgent = userAgent
        self.webView = wv

        super.init()

        wv.navigationDelegate = self
        observations = [
            wv.observe(\.canGoBack, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.canGoBack = wv.canGoBack }
            },
            wv.observe(\.canGoForward, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.canGoForward = wv.canGoForward }
            },
            wv.observe(\.isLoading, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.isLoading = wv.isLoading }
            },
            wv.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.progress = wv.estimatedProgress }
            }
        ]

        WebGateLog.write("WV init target=\(homeURL.absoluteString) cookies=\(sessionCookies.count)")
        if sessionCookies.isEmpty {
            webView.load(URLRequest(url: homeURL))
        } else {
            let store = wv.configuration.websiteDataStore.httpCookieStore
            Task { @MainActor [weak self] in
                for cookie in sessionCookies {
                    WebGateLog.write("WV set cookie \(cookie.name) domain=\(cookie.domain)")
                    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                        store.setCookie(cookie) { cont.resume() }
                    }
                }
                WebGateLog.write("WV cookies set, loading")
                self?.webView.load(URLRequest(url: homeURL))
            }
        }
    }

    deinit {
        observations.forEach { $0.invalidate() }
    }

    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func reload() { webView.reload() }
    func goHome() { webView.load(URLRequest(url: homeURL)) }
}

extension WebViewModel: WKNavigationDelegate {
    func webView(_ wv: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = action.request.url else { return .cancel }
        let scheme = url.scheme ?? ""
        if ["tel", "mailto", "itms-apps", "itms-appss"].contains(scheme) {
            await UIApplication.shared.open(url)
            return .cancel
        }
        return .allow
    }

    func webView(_ wv: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        WebGateLog.write("WV start nav → \(wv.url?.absoluteString ?? "nil")")
    }

    func webView(_ wv: WKWebView, didFinish navigation: WKNavigation!) {
        WebGateLog.write("WV finish nav → \(wv.url?.absoluteString ?? "nil")")
        reloadAttempts = 0
    }

    func webView(_ wv: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsErr = error as NSError
        WebGateLog.write("WV didFail \(nsErr.domain) \(nsErr.code) \(nsErr.localizedDescription)")
        if nsErr.domain == NSURLErrorDomain, nsErr.code == NSURLErrorCancelled { return }
        if !Self.isRetryable(nsErr) { return }
        Task { @MainActor [weak self] in await self?.scheduleReload(reason: "didFail \(nsErr.code)") }
    }

    func webView(_ wv: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsErr = error as NSError
        WebGateLog.write("WV provisional fail \(nsErr.domain) \(nsErr.code) \(nsErr.localizedDescription)")
        if nsErr.domain == NSURLErrorDomain, nsErr.code == NSURLErrorCancelled { return }
        if !Self.isRetryable(nsErr) { return }
        Task { @MainActor [weak self] in await self?.scheduleReload(reason: "provisional \(nsErr.code)") }
    }

    private static func isRetryable(_ err: NSError) -> Bool {
        guard err.domain == NSURLErrorDomain else { return false }
        switch err.code {
        case NSURLErrorTimedOut,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorDNSLookupFailed,
             NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorDataNotAllowed:
            return true
        default:
            return false
        }
    }

    private func scheduleReload(reason: String) async {
        guard reloadAttempts < reloadCeiling else {
            WebGateLog.write("WV reload limit \(reloadAttempts)/\(reloadCeiling) — stop")
            return
        }
        reloadAttempts += 1
        let waitSec = min(8, 1 << (reloadAttempts - 1))
        WebGateLog.write("WV reload #\(reloadAttempts) in \(waitSec)s — \(reason)")
        try? await Task.sleep(nanoseconds: UInt64(waitSec) * 1_000_000_000)
        if webView.url == nil {
            webView.load(URLRequest(url: homeURL))
        } else {
            webView.reload()
        }
    }
}

private struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    func makeUIView(context: Context) -> WKWebView { webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct WebGateView: View {
    @StateObject private var model: WebViewModel

    init(url: URL) {
        _model = StateObject(wrappedValue: WebViewModel(
            homeURL: url,
            userAgent: WebGate.shared.config.userAgent,
            sessionCookies: WebGate.shared.sessionCookies
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                WebViewRepresentable(webView: model.webView)
                    .ignoresSafeArea(edges: [.top, .horizontal])

                if model.isLoading {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color(hex: 0xF4FD2B))
                            .frame(width: geo.size.width * model.progress, height: 2)
                            .animation(.easeInOut(duration: 0.2), value: model.progress)
                    }
                    .frame(height: 2)
                    .ignoresSafeArea(edges: [.top, .horizontal])
                }
            }

            WebNavBar(model: model)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

private struct WebNavBar: View {
    @ObservedObject var model: WebViewModel

    var body: some View {
        HStack(spacing: 0) {
            navButton(systemName: "chevron.left", enabled: model.canGoBack) {
                model.goBack()
            }
            navButton(systemName: "chevron.right", enabled: model.canGoForward) {
                model.goForward()
            }
            navButton(systemName: "house.fill", enabled: true, weight: .semibold) {
                model.goHome()
            }
            navButton(systemName: "arrow.clockwise", enabled: true) {
                model.reload()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(
            Color(hex: 0x141414)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5),
            alignment: .top
        )
    }

    @ViewBuilder
    private func navButton(systemName: String, enabled: Bool, weight: Font.Weight = .regular, action: @escaping () -> Void) -> some View {
        Button(action: {
            if enabled {
                let gen = UIImpactFeedbackGenerator(style: .light)
                gen.impactOccurred()
                action()
            }
        }) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: weight))
                .foregroundStyle(enabled ? Color.white.opacity(0.92) : Color.white.opacity(0.25))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }
}
