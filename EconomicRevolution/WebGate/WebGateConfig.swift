import Foundation
import UIKit

struct WebGateConfig {
    var host: String = ""
    var token: String = ""
    var timeout: TimeInterval = 10
    var targetStreams: Set<Int>? = nil
    var fallback: WebGateResult = .facade
    var userAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
    var subIDs: [String: String] = [:]

    var isReady: Bool {
        return !host.isEmpty
            && !token.isEmpty
            && !token.contains("REPLACE_WITH_")
    }

    func makeProbeURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/click_api/v3"

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "log", value: "1"),
            URLQueryItem(name: "info", value: "1")
        ]
        if let lang = Locale.preferredLanguages.first {
            queryItems.append(URLQueryItem(name: "language", value: lang))
        }
        for key in subIDs.keys.sorted() {
            if let value = subIDs[key] {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        components.queryItems = queryItems
        return components.url
    }

    func makeOfferURL(legacyToken: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: "_lp", value: "1"),
            URLQueryItem(name: "_token", value: legacyToken)
        ]
        return components.url
    }

    static func defaultSubIDs() -> [String: String] {
        var dict: [String: String] = [:]
        dict["sub_id_1"] = Bundle.main.bundleIdentifier ?? "unknown"
        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
        let build = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1"
        dict["sub_id_2"] = "\(version)-\(build)"
        dict["sub_id_3"] = Locale.preferredLanguages.first ?? "en"
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            dict["sub_id_4"] = idfv
        }
        dict["sub_id_5"] = "ios"
        return dict
    }
}

enum WebGateResult: Equatable {
    case show(URL)
    case facade
    case error(String)
}

struct WebGateResponse: Decodable {
    struct Info: Decodable {
        let streamId: Int?
        let campaignId: Int?
        let offerId: Int?
        let landingId: Int?
        let infoToken: String?
        let subId: String?
        let isBot: Bool?
        let type: String?
        let url: String?

        enum CodingKeys: String, CodingKey {
            case streamId = "stream_id"
            case campaignId = "campaign_id"
            case offerId = "offer_id"
            case landingId = "landing_id"
            case infoToken = "token"
            case subId = "sub_id"
            case isBot = "is_bot"
            case type, url
        }
    }

    let info: Info?
    let headers: [String]?
    let cookies: [String: String]?
    let cookiesTtl: Int?
    let contentType: String?

    enum CodingKeys: String, CodingKey {
        case info, headers, cookies
        case cookiesTtl = "cookies_ttl"
        case contentType = "contentType"
    }

    func resolveURL() -> URL? {
        if let raw = info?.url, !raw.isEmpty,
           let candidate = URL(string: raw), Self.isWebScheme(candidate) {
            return candidate
        }
        if let lines = headers {
            for line in lines where line.lowercased().hasPrefix("location:") {
                let value = line
                    .dropFirst("location:".count)
                    .trimmingCharacters(in: .whitespaces)
                if let candidate = URL(string: String(value)), Self.isWebScheme(candidate) {
                    return candidate
                }
            }
        }
        return nil
    }

    func makeCookies(for host: String) -> [HTTPCookie] {
        guard let dict = cookies, !dict.isEmpty, !host.isEmpty else { return [] }
        let hours = TimeInterval(cookiesTtl ?? 24)
        let expires = Date().addingTimeInterval(hours * 3600)
        return dict.compactMap { name, value in
            HTTPCookie(properties: [
                .domain: host,
                .path: "/",
                .name: name,
                .value: value,
                .expires: expires,
                .secure: "TRUE"
            ])
        }
    }

    private static func isWebScheme(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        return scheme == "https" || scheme == "http"
    }
}

struct WebGateOutcome: Equatable {
    let result: WebGateResult
    let cookies: [HTTPCookie]

    static var idle: WebGateOutcome {
        WebGateOutcome(result: .facade, cookies: [])
    }

    static func == (lhs: WebGateOutcome, rhs: WebGateOutcome) -> Bool {
        lhs.result == rhs.result && lhs.cookies.map(\.name) == rhs.cookies.map(\.name)
    }
}
