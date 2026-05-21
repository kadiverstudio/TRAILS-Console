import SwiftUI

@Observable
@MainActor
final class InfraService {
    var serverMetrics: [ServerMetric] = ServerMetric.mockData
    var containers: [DockerContainer] = DockerContainer.mockData
    var isLoading = false
    var lastError: String?

    @ObservationIgnored private var pollTask: Task<Void, Never>?

    init() {
        startPolling()
    }

    deinit {
        pollTask?.cancel()
    }

    var onlineCount: Int { serverMetrics.filter { $0.isOnline }.count }
    var totalCount:  Int { serverMetrics.count }
    var allOnline:   Bool { onlineCount == totalCount }

    func refresh() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            serverMetrics = try await PrometheusClient.shared.fetchServerMetrics()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func startPolling() {
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                await self?.refresh()
            }
        }
    }
}
