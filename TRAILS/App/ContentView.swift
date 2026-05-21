import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            detailView(for: appState.selectedItem)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private func detailView(for item: SidebarItem?) -> some View {
        switch item ?? .overview {
        case .overview:
            OverviewView()
        case .mtIssues:
            IssueListView(app: .musicTrails)
        case .mtSupport:
            SupportView(app: .musicTrails)
        case .mtDeploys:
            DeployHistoryView(app: .musicTrails)
        case .stIssues:
            IssueListView(app: .sceneTrails)
        case .stSupport:
            SupportView(app: .sceneTrails)
        case .stDeploys:
            DeployHistoryView(app: .sceneTrails)
        case .infrastructure:
            InfrastructureView()
        case .grafana:
            GrafanaView()
        case .docker:
            DockerStatusView()
        case .nginxLogs:
            NGINXLogsView()
        case .inbox:
            InboxView()
        case .venueOutreach:
            VenueOutreachView()
        case .studioMemberships:
            StudioMembershipsView()
        case .quickActions:
            QuickActionsView()
        }
    }
}
