import SwiftUI

private let trailsPurple = Color(red: 0.325, green: 0.290, blue: 0.718)

struct SidebarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        List(selection: $appState.selectedItem) {
            logoHeader

            Label(SidebarItem.overview.title, systemImage: SidebarItem.overview.icon)
                .tag(SidebarItem.overview)

            Section(SidebarSection.musicTrails.rawValue) {
                row(.mtIssues,  badge: appState.issueService.mtOpenCount)
                row(.mtSupport)
                row(.mtDeploys)
            }

            Section(SidebarSection.sceneTrails.rawValue) {
                row(.stIssues,  badge: appState.issueService.stOpenCount)
                row(.stSupport)
                row(.stDeploys)
            }

            Section(SidebarSection.infrastructure.rawValue) {
                row(.infrastructure, badge: appState.infraService.allOnline ? 0 : 1)
                row(.grafana)
                row(.docker)
                row(.nginxLogs)
            }

            Section(SidebarSection.communications.rawValue) {
                row(.inbox, badge: appState.emailService.unreadCount)
                row(.venueOutreach)
                row(.studioMemberships)
            }

            Section(SidebarSection.actions.rawValue) {
                row(.quickActions)
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
    }

    // MARK: - Subviews

    private var logoHeader: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8)
                .fill(trailsPurple)
                .frame(width: 34, height: 34)
                .overlay {
                    Text("T")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 1) {
                Text("TRAILS")
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.bold)
                Text("Console")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func row(_ item: SidebarItem, badge: Int = 0) -> some View {
        HStack(spacing: 0) {
            Label(item.title, systemImage: item.icon)
            Spacer()
            if badge > 0 {
                Text("\(min(badge, 99))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.red, in: Capsule())
            }
        }
        .tag(item)
    }
}
