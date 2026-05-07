import Foundation

enum AppConfig {
    static let relayHost = "REPLACE_WITH_KEITARO_HOST"
    static let relayKey = "REPLACE_WITH_CAMPAIGN_TOKEN"
    static let relayTimeout: TimeInterval = 10
    static let relayTargets: Set<Int>? = nil
}
