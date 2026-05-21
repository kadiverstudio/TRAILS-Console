import Foundation

enum PrometheusError: LocalizedError {
    case requestFailed(Int)
    case emptyResult
    case parseError

    var errorDescription: String? {
        switch self {
        case .requestFailed(let c): return "Prometheus responded with HTTP \(c)."
        case .emptyResult:          return "Prometheus returned no data for that query."
        case .parseError:           return "Could not parse Prometheus response."
        }
    }
}

actor PrometheusClient {
    static let shared = PrometheusClient()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        session = URLSession(configuration: config)
    }

    // MARK: - Instant query

    func queryInstant(_ promQL: String) async throws -> Double {
        var comps = URLComponents(url: AppConfig.prometheusURL.appendingPathComponent("/api/v1/query"),
                                   resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "query", value: promQL)]

        let (data, response) = try await session.data(from: comps.url!)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw PrometheusError.requestFailed((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        let result = try JSONDecoder().decode(PrometheusResponse.self, from: data)
        guard let valueStr = result.data.result.first?.value.valueString,
              let value = Double(valueStr) else {
            return 0
        }
        return value
    }

    // MARK: - Server metrics

    func fetchServerMetrics() async throws -> [ServerMetric] {
        async let r730cpu  = queryInstant("100 - (avg(rate(node_cpu_seconds_total{mode='idle',instance=~'r730.*'}[5m])) * 100)")
        async let r730ram  = queryInstant("(1 - node_memory_MemAvailable_bytes{instance=~'r730.*'} / node_memory_MemTotal_bytes{instance=~'r730.*'}) * 100")
        async let r730disk = queryInstant("(1 - node_filesystem_free_bytes{instance=~'r730.*',mountpoint='/'} / node_filesystem_size_bytes{instance=~'r730.*',mountpoint='/'}) * 100")
        async let r730up   = queryInstant("up{job='node',instance=~'r730.*'}")

        async let r630cpu  = queryInstant("100 - (avg(rate(node_cpu_seconds_total{mode='idle',instance=~'r630.*'}[5m])) * 100)")
        async let r630ram  = queryInstant("(1 - node_memory_MemAvailable_bytes{instance=~'r630.*'} / node_memory_MemTotal_bytes{instance=~'r630.*'}) * 100")
        async let r630disk = queryInstant("(1 - node_filesystem_free_bytes{instance=~'r630.*',mountpoint='/'} / node_filesystem_size_bytes{instance=~'r630.*',mountpoint='/'}) * 100")
        async let r630up   = queryInstant("up{job='node',instance=~'r630.*'}")

        return [
            ServerMetric(id: "r730", displayName: "Dell R730",
                         cpuPercent:  (try? await r730cpu)  ?? 0,
                         ramPercent:  (try? await r730ram)  ?? 0,
                         diskPercent: (try? await r730disk) ?? 0,
                         isOnline:    ((try? await r730up)  ?? 0) >= 1,
                         lastSeen:    Date()),
            ServerMetric(id: "r630", displayName: "Dell R630",
                         cpuPercent:  (try? await r630cpu)  ?? 0,
                         ramPercent:  (try? await r630ram)  ?? 0,
                         diskPercent: (try? await r630disk) ?? 0,
                         isOnline:    ((try? await r630up)  ?? 0) >= 1,
                         lastSeen:    Date()),
        ]
    }
}

// MARK: - Decodable shapes

private struct PrometheusResponse: Decodable {
    let status: String
    let data: PrometheusData
}

private struct PrometheusData: Decodable {
    let result: [PrometheusResult]
}

private struct PrometheusResult: Decodable {
    let value: PrometheusValue
}

// Prometheus returns value as [timestamp, "string_value"]
private struct PrometheusValue: Decodable {
    let valueString: String

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        _ = try c.decode(Double.self) // timestamp
        valueString = try c.decode(String.self)
    }
}
