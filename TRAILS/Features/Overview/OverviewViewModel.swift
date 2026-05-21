import SwiftUI

@Observable
@MainActor
final class OverviewViewModel {
    var mtUserCount:    Int = 1_842
    var stUserCount:    Int = 634
    var serverMetrics:  [ServerMetric]  = ServerMetric.mockData
    var recentIssues:   [IssuePreview]  = IssuePreview.mockData
    var inboxPreview:   [EmailMessage]  = EmailMessage.mockData
    var lastRefreshed:  Date?           = Date()
    var isLoading:      Bool            = false

    private let infraService:  InfraService
    private let issueService:  IssueService
    private let emailService:  EmailService
    private let deployService: DeployService

    init(appState: AppState) {
        self.infraService  = appState.infraService
        self.issueService  = appState.issueService
        self.emailService  = appState.emailService
        self.deployService = appState.deployService
    }

    var serversOnline:  Int { serverMetrics.filter { $0.isOnline }.count }
    var totalServers:   Int { serverMetrics.count }
    var openIssueCount: Int { issueService.openIssueCount }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.infraService.refresh() }
            group.addTask { await self.issueService.refresh() }
            group.addTask { await self.emailService.refresh() }
        }

        serverMetrics = infraService.serverMetrics
        recentIssues  = Array(
            (issueService.mtIssues + issueService.stIssues)
                .sorted { $0.createdAt > $1.createdAt }
                .prefix(8)
        )
        inboxPreview  = Array(emailService.messages.prefix(3))
        lastRefreshed = Date()
    }
}
