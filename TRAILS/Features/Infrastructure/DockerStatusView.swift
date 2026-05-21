import SwiftUI

struct DockerStatusView: View {
    @Environment(AppState.self) private var appState

    private var containers: [DockerContainer] { appState.infraService.containers }

    private var runningCount: Int { containers.filter { $0.state == .running }.count }

    var body: some View {
        VStack(spacing: 0) {
            summaryBar
            Divider()
            List(containers) { container in
                ContainerRow(container: container)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Docker Containers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await appState.infraService.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(appState.infraService.isLoading)
            }
        }
    }

    private var summaryBar: some View {
        HStack(spacing: 16) {
            summaryPill(count: runningCount, label: "Running", color: .green)
            summaryPill(count: containers.count - runningCount, label: "Stopped/Exited", color: .red)
            Spacer()
            Text("\(containers.count) containers across R730 + R630")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func summaryPill(count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text("\(count) \(label)").font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct ContainerRow: View {
    let container: DockerContainer

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: container.state.icon)
                .foregroundStyle(container.state.color)
                .font(.title3)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(container.name)
                    .font(.callout)
                    .fontWeight(.medium)
                HStack(spacing: 6) {
                    Text(container.image)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text("·")
                    Text(container.server)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(container.state.label)
                    .font(.caption)
                    .foregroundStyle(container.state.color)
                if container.state == .running {
                    Text("Up \(container.uptime)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
