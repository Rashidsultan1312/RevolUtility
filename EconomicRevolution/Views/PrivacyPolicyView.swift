import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    private let privacyURL = URL(string: "https://alienpaul.lol/policy")!

    var body: some View {
        PrivacyWebView(url: privacyURL)
            .background(RV.bg.ignoresSafeArea())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.isOpaque = false
        wv.backgroundColor = UIColor(RV.bg)
        wv.scrollView.backgroundColor = UIColor(RV.bg)
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ wv: WKWebView, context: Context) {}
}
