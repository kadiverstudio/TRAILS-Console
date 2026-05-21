import SwiftUI

@Observable
@MainActor
final class AppState {
    var selectedItem: SidebarItem? = .overview

    let issueService  = IssueService()
    let infraService  = InfraService()
    let emailService  = EmailService()
    let deployService = DeployService()

    var totalUnreadEmails: Int  { emailService.unreadCount }
    var totalOpenIssues:   Int  { issueService.openIssueCount }
    var allServersOnline:  Bool { infraService.allOnline }

    func refreshAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.issueService.refresh() }
            group.addTask { await self.infraService.refresh() }
            group.addTask { await self.emailService.refresh() }
            group.addTask { await self.deployService.refresh() }
        }
    }
}
