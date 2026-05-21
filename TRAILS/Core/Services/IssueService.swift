import SwiftUI

@Observable
@MainActor
final class IssueService {
    var mtIssues: [IssuePreview] = IssuePreview.mockMT
    var stIssues: [IssuePreview] = IssuePreview.mockST
    var isLoading = false
    var lastError: String?

    var mtOpenCount: Int { mtIssues.filter { $0.severity != .info }.count }
    var stOpenCount: Int { stIssues.filter { $0.severity != .info }.count }
    var openIssueCount: Int { mtOpenCount + stOpenCount }

    func refresh() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            async let mt: [IssuePreview] = APIClient.shared.fetch("/api/issues?status=open", from: .musicTrails)
            async let st: [IssuePreview] = APIClient.shared.fetch("/api/issues?status=open", from: .sceneTrails)
            mtIssues = try await mt
            stIssues = try await st
        } catch {
            lastError = error.localizedDescription
            // Keep existing data on failure
        }
    }

    func issues(for app: AppTag) -> [IssuePreview] {
        switch app {
        case .musicTrails: mtIssues
        case .sceneTrails: stIssues
        }
    }
}
