import Foundation

final class RemoteConfigService {
    private static let maxAttempts = 3
    private static let backoff: [UInt64] = [800_000_000, 2_000_000_000]

    private static let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForResource = 10
        cfg.timeoutIntervalForRequest = 10
        cfg.waitsForConnectivity = false
        cfg.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: cfg)
    }()

    private enum FetchStep {
        case ok(Data)
        case retry(String)
        case stop(String)
    }

    static func fetch(config: WebGateConfig) async -> WebGateOutcome {
        let idle = WebGateOutcome(result: config.fallback, cookies: [])
        WebGateLog.write("fetch start ready=\(config.isReady) host=\(config.host)")
        guard config.isReady else { return idle }
        guard let url = config.makeProbeURL() else { return idle }
        WebGateLog.write("GET \(url.absoluteString)")

        var req = URLRequest(url: url, timeoutInterval: config.timeout)
        req.httpMethod = "GET"
        req.setValue(config.userAgent, forHTTPHeaderField: "User-Agent")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let lang = Locale.preferredLanguages.first {
            req.setValue(lang, forHTTPHeaderField: "Accept-Language")
        }

        for attempt in 1...maxAttempts {
            switch await runOnce(req, attempt: attempt) {
            case .ok(let data):
                return decodeAndInterpret(data: data, config: config, idle: idle)
            case .stop(let reason):
                WebGateLog.write("terminal: \(reason)")
                if reason.hasPrefix("auth") { return WebGateOutcome(result: .error("invalid_token"), cookies: []) }
                if reason.hasPrefix("disabled") { return WebGateOutcome(result: .error("click_api_disabled"), cookies: []) }
                return idle
            case .retry(let reason):
                WebGateLog.write("transient: \(reason) attempt=\(attempt)/\(maxAttempts)")
                if attempt < maxAttempts {
                    let nanos = backoff[min(attempt - 1, backoff.count - 1)]
                    try? await Task.sleep(nanoseconds: nanos)
                    continue
                }
                WebGateLog.write("retries exhausted")
                return idle
            }
        }
        return idle
    }

    private static func runOnce(_ req: URLRequest, attempt: Int) async -> FetchStep {
        do {
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                return .retry("no-http-response")
            }
            WebGateLog.write("HTTP \(http.statusCode) (attempt \(attempt))")
            switch http.statusCode {
            case 200...299:
                return .ok(data)
            case 401, 403:
                return .stop("auth \(http.statusCode)")
            case 409:
                return .stop("disabled \(http.statusCode)")
            case 404, 410:
                return .stop("not-found \(http.statusCode)")
            case 408, 425, 429, 500, 502, 503, 504:
                return .retry("retryable \(http.statusCode)")
            case 400...499:
                return .stop("client \(http.statusCode)")
            default:
                return .retry("status \(http.statusCode)")
            }
        } catch {
            let nsErr = error as NSError
            if nsErr.domain == NSURLErrorDomain {
                switch nsErr.code {
                case NSURLErrorCancelled, NSURLErrorBadURL, NSURLErrorUnsupportedURL,
                     NSURLErrorAppTransportSecurityRequiresSecureConnection:
                    return .stop("nsurl \(nsErr.code)")
                default:
                    return .retry("nsurl \(nsErr.code)")
                }
            }
            return .retry("error")
        }
    }

    private static func decodeAndInterpret(data: Data, config: WebGateConfig, idle: WebGateOutcome) -> WebGateOutcome {
        guard let payload = try? JSONDecoder().decode(WebGateResponse.self, from: data) else {
            WebGateLog.write("decode failed")
            return idle
        }
        let jar = payload.makeCookies(for: config.host)
        WebGateLog.write("decoded streamId=\(payload.info?.streamId.map(String.init) ?? "nil") tokenPresent=\(payload.info?.infoToken?.isEmpty == false) cookies=\(jar.count)")

        if let bot = payload.info?.isBot, bot {
            return WebGateOutcome(result: config.fallback, cookies: jar)
        }
        if let allowed = config.targetStreams,
           let streamId = payload.info?.streamId,
           !allowed.contains(streamId) {
            return WebGateOutcome(result: config.fallback, cookies: jar)
        }
        if let resolved = payload.resolveURL() {
            return WebGateOutcome(result: .show(resolved), cookies: jar)
        }
        if let legacy = payload.info?.infoToken,
           !legacy.isEmpty,
           let built = config.makeOfferURL(legacyToken: legacy) {
            return WebGateOutcome(result: .show(built), cookies: jar)
        }
        return WebGateOutcome(result: config.fallback, cookies: jar)
    }
}

enum WebGateLog {
    static func write(_ message: String) {
        #if DEBUG
        print("[WebGate] \(message)")
        #endif
    }
}
