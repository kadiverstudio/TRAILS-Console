import Foundation

enum GrafanaError: LocalizedError {
    case requestFailed(Int)
    case parseError

    var errorDescription: String? {
        switch self {
        case .requestFailed(let c): return "Grafana responded with HTTP \(c)."
        case .parseError:           return "Could not parse Grafana response."
        }
    }
}

struct GrafanaAlert: Identifiable, Decodable {
    let id: Int
    let dashboardTitle: String
    let name: String
    let state: String // "ok", "alerting", "no_data", "paused"
    let newStateDate: String
}

actor GrafanaClient {
    static let shared = GrafanaClient()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        session = URLSession(configuration: config)
    }

    private var baseURL: URL { AppConfig.grafanaURL }

    func fetchAlerts() async throws -> [GrafanaAlert] {
        let url = baseURL.appendingPathComponent("/api/alerts")
        var request = URLRequest(url: url)

        if let token = grafanaToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw GrafanaError.requestFailed((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return (try? decoder.decode([GrafanaAlert].self, from: data)) ?? []
    }

    func fetchDashboards() async throws -> [[String: String]] {
        let url = baseURL.appendingPathComponent("/api/search")
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw GrafanaError.requestFailed((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return (try? JSONDecoder().decode([[String: String]].self, from: data)) ?? []
    }

    private func grafanaToken() -> String? {
        let key = "trails.grafana.token" as CFString
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
