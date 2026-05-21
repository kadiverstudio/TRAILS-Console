import SwiftUI

struct DeployHistoryView: View {
    let app: AppTag

    @Environment(AppState.self) private var appState
    @State private var selected: DeployEvent?

    private var deploys: [DeployEvent] {
        appState.deployService.deploys(for: app)
    }

    var body: some View {
        NavigationSplitView {
            List(deploys, selection: $selected) { event in
                DeployRow(event: event).tag(event)
            }
            .listStyle(.plain)
            .overlay {
                if deploys.isEmpty {
                    ContentUnavailableView("No Deploys", systemImage: "arrow.up.to.line.circle",
                                          description: Text("Deploy history for \(app.displayName) will appear here."))
                }
            }
            .navigationTitle("\(app.displayName) Deploys")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { Task { await appState.deployService.refresh() } } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        } detail: {
            if let event = selected {
                DeployDetailView(event: event)
            } else {
                ContentUnavailableView("Select a Deploy", systemImage: "arrow.up.to.line.circle")
            }
        }
        .task { await appState.deployService.refresh() }
    }
}

private struct DeployRow: View {
    let event: DeployEvent

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: event.status.icon)
                .foregroundStyle(event.status.color)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("v\(event.version)")
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("→")
                        .foregroundStyle(.secondary)
                    Text(event.environment.capitalized)
                        .font(.callout)
                    Spacer()
                    Text(event.timeDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Text(event.shortSHA)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text("·")
                    Text(event.deployedBy)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(event.status.label)
                        .font(.caption)
                        .foregroundStyle(event.status.color)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

private struct DeployDetailView: View {
    let event: DeployEvent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("v\(event.version)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(event.environment.capitalized)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Label(event.status.label, systemImage: event.status.icon)
                        .foregroundStyle(event.status.color)
                        .font(.callout)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(event.status.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                GroupBox("Details") {
                    Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 8) {
                        GridRow {
                            Text("App").foregroundStyle(.secondary)
                            Text(event.appTag.displayName)
                        }
                        GridRow {
                            Text("Version").foregroundStyle(.secondary)
                            Text("v\(event.version)")
                        }
                        GridRow {
                            Text("Environment").foregroundStyle(.secondary)
                            Text(event.environment.capitalized)
                        }
                        GridRow {
                            Text("Commit").foregroundStyle(.secondary)
                            Text(event.shortSHA)
                                .font(.system(.callout, design: .monospaced))
                        }
                        GridRow {
                            Text("Deployed by").foregroundStyle(.secondary)
                            Text(event.deployedBy)
                        }
                        GridRow {
                            Text("Deployed at").foregroundStyle(.secondary)
                            Text(event.deployedAt.formatted(date: .complete, time: .shortened))
                        }
                    }
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
        }
        .navigationTitle("Deploy v\(event.version)")
    }
}
