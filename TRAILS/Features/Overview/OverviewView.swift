import SwiftUI

private let trailsPurple = Color(red: 0.325, green: 0.290, blue: 0.718)

struct OverviewView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: OverviewViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = OverviewViewModel(appState: appState)
            }
        }
        .task {
            guard let vm = viewModel else { return }
            await vm.refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: .globalRefresh)) { _ in
            Task { await viewModel?.refresh() }
        }
    }

    @ViewBuilder
    private func content(vm: OverviewViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(vm: vm)
                metricCards(vm: vm)
                midRow(vm: vm)
                inboxSection(vm: vm)
            }
            .padding(20)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header

    private func header(vm: OverviewViewModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Overview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                if let date = vm.lastRefreshed {
                    Text("Updated \(date.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if vm.isLoading {
                ProgressView().controlSize(.small).padding(.trailing, 4)
            }
            Button {
                Task { await vm.refresh() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .disabled(vm.isLoading)
            .keyboardShortcut("r", modifiers: .command)
        }
    }

    // MARK: - Metric cards

    private func metricCards(vm: OverviewViewModel) -> some View {
        HStack(spacing: 12) {
            MetricCard(
                label: "Music Trails Users",
                value: vm.mtUserCount.formatted(),
                icon: "music.mic",
                color: trailsPurple
            )
            MetricCard(
                label: "Scene Trails Users",
                value: vm.stUserCount.formatted(),
                icon: "building.2",
                color: .blue
            )
            MetricCard(
                label: "Open Issues",
                value: vm.openIssueCount.formatted(),
                icon: "exclamationmark.circle.fill",
                color: vm.openIssueCount > 5 ? .red : .orange
            )
            MetricCard(
                label: "Servers Online",
                value: "\(vm.serversOnline)/\(vm.totalServers)",
                icon: "server.rack",
                color: vm.serversOnline == vm.totalServers ? .green : .red
            )
        }
    }

    // MARK: - Mid row (issues + servers)

    private func midRow(vm: OverviewViewModel) -> some View {
        HStack(alignment: .top, spacing: 12) {
            issuesPanel(vm: vm)
            serversPanel(vm: vm)
        }
        .frame(maxHeight: 280)
    }

    private func issuesPanel(vm: OverviewViewModel) -> some View {
        GroupBox {
            if vm.recentIssues.isEmpty {
                Text("No open issues")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List(vm.recentIssues) { issue in
                    IssueRow(issue: issue)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                }
                .listStyle(.plain)
            }
        } label: {
            Label("Recent Issues", systemImage: "exclamationmark.circle")
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
    }

    private func serversPanel(vm: OverviewViewModel) -> some View {
        GroupBox {
            List(vm.serverMetrics) { metric in
                ServerRow(metric: metric)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            .listStyle(.plain)
        } label: {
            Label("Infrastructure", systemImage: "server.rack")
                .font(.headline)
        }
        .frame(maxWidth: 320)
    }

    // MARK: - Inbox preview

    private func inboxSection(vm: OverviewViewModel) -> some View {
        GroupBox {
            if vm.inboxPreview.isEmpty {
                Text("No unread messages")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.inboxPreview) { message in
                        EmailPreviewRow(message: message)
                        if message.id != vm.inboxPreview.last?.id {
                            Divider().padding(.horizontal, 4)
                        }
                    }
                }
            }
        } label: {
            Label("Recent Emails", systemImage: "tray")
                .font(.headline)
        }
    }
}

// MARK: - Reusable subviews

private struct MetricCard: View {
    let label: String
    let value: String
    let icon:  String
    let color: Color

    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .padding(8)
                    .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct IssueRow: View {
    let issue: IssuePreview

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(issue.severity.color)
                .frame(width: 8, height: 8)
                .padding(.top, 1)

            Text(issue.appTag.shortName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(issue.appTag.color)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(issue.appTag.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))

            Text("#\(issue.issueNumber)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Text(issue.title)
                .font(.callout)
                .lineLimit(1)

            Spacer()

            Text(issue.ageDescription)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .monospacedDigit()
        }
    }
}

private struct ServerRow: View {
    let metric: ServerMetric

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: metric.health.icon)
                .foregroundStyle(metric.health.color)
                .font(.footnote)

            Text(metric.displayName)
                .font(.callout)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                metricBar(label: "CPU", value: metric.cpuPercent)
                metricBar(label: "RAM", value: metric.ramPercent)
            }

            Spacer()
        }
    }

    private func metricBar(label: String, value: Double) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .leading)
            ProgressView(value: value / 100)
                .tint(value > 80 ? .orange : .green)
                .frame(width: 70)
            Text("\(Int(value))%")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 30, alignment: .trailing)
        }
    }
}

private struct EmailPreviewRow: View {
    let message: EmailMessage

    var body: some View {
        HStack(spacing: 10) {
            if !message.isRead {
                Circle().fill(.blue).frame(width: 7, height: 7)
            } else {
                Circle().fill(.clear).frame(width: 7, height: 7)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(message.senderName)
                        .font(.callout)
                        .fontWeight(message.isRead ? .regular : .semibold)
                    Text(message.appTag.shortName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(message.appTag.color)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(message.appTag.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
                    Spacer()
                    Text(message.ageDescription)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Text(message.subject)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(message.preview)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }
}
