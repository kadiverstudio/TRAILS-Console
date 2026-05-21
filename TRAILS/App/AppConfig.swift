import Foundation

enum AppConfig {
    private static let plist: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any] else {
            fatalError("Config.plist not found in bundle — add it to the TRAILS target in Xcode.")
        }
        return dict
    }()

    private static func string(_ key: String) -> String {
        guard let value = plist[key] as? String, !value.isEmpty else {
            fatalError("Config.plist missing required key '\(key)' — check Resources/Config.plist.")
        }
        return value
    }

    private static func url(_ key: String) -> URL {
        guard let u = URL(string: string(key)) else {
            fatalError("Config.plist key '\(key)' is not a valid URL.")
        }
        return u
    }

    static var musicTrailsAPIURL: URL { url("MusicTrailsAPIURL") }
    static var sceneTrailsAPIURL: URL { url("SceneTrailsAPIURL") }
    static var grafanaURL: URL        { url("GrafanaURL") }
    static var prometheusURL: URL     { url("PrometheusURL") }
    static var uptimeKumaURL: URL     { url("UptimeKumaURL") }
    static var r730SSHHost: String    { string("R730SSHHost") }
    static var r630SSHHost: String    { string("R630SSHHost") }
}
