import SwiftUI

@Observable
@MainActor
final class DeployService {
    var mtDeploys: [DeployEvent] = DeployEvent.mockMT
    var stDeploys: [DeployEvent] = DeployEvent.mockST
    var isLoading = false
    var lastError: String?

    var latestMT: DeployEvent? { mtDeploys.first }
    var latestST: DeployEvent? { stDeploys.first }

    func refresh() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            async let mt: [DeployEvent] = APIClient.shared.fetch("/api/deploys?limit=20", from: .musicTrails)
            async let st: [DeployEvent] = APIClient.shared.fetch("/api/deploys?limit=20", from: .sceneTrails)
            mtDeploys = try await mt
            stDeploys = try await st
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deploys(for app: AppTag) -> [DeployEvent] {
        switch app {
        case .musicTrails: mtDeploys
        case .sceneTrails: stDeploys
        }
    }
}
