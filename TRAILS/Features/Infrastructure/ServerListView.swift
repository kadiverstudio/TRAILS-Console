import SwiftUI

struct ServerListView: View {
    @Environment(AppState.self) private var appState
    @State private var selected: ServerMetric?

    private var metrics: [ServerMetric] { appState.infraService.serverMetrics }

    var body: some View {
        NavigationSplitView {
            List(metrics, selection: $selected) { metric in
                ServerMetricRow(metric: metric).tag(metric)
            }
            .listStyle(.plain)
            .navigationTitle("Servers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await appState.infraService.refresh() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(appState.infraService.isLoading)
                }
                ToolbarItem {
                    if appState.infraService.isLoading {
                        ProgressView().controlSize(.small)
                    }
                }
            }
        } detail: {
            if let metric = selected {
                ServerDetailView(metric: metric)
            } else {
                ContentUnavailableView("Select a Server", systemImage: "server.rack")
            }
        }
        .task { await appState.infraService.refresh() }
    }
}

struct ServerMetricRow: View {
    let metric: ServerMetric

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: metric.health.icon)
                .foregroundStyle(metric.health.color)
                .font(.title3)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(metric.displayName)
                        .font(.callout)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(metric.health.label)
                        .font(.caption)
                        .foregroundStyle(metric.health.color)
                }

                HStack(spacing: 16) {
                    compactBar(label: "CPU", value: metric.cpuPercent)
                    compactBar(label: "RAM", value: metric.ramPercent)
                    compactBar(label: "Disk", value: metric.diskPercent)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func compactBar(label: String, value: Double) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .frame(width: 26, alignment: .leading)
            ProgressView(value: value / 100)
                .tint(value > 80 ? .red : value > 60 ? .orange : .green)
                .frame(width: 52)
            Text("\(Int(value))%")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 30, alignment: .trailing)
        }
    }
}

private struct ServerDetailView: View {
    let metric: ServerMetric

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metric.displayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Last seen: \(metric.lastSeen.formatted(date: .omitted, time: .standard))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Label(metric.health.label, systemImage: metric.health.icon)
                        .foregroundStyle(metric.health.color)
                        .font(.callout)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(metric.health.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                HStack(spacing: 12) {
                    gaugeCard(label: "CPU", value: metric.cpuPercent, icon: "cpu")
                    gaugeCard(label: "RAM", value: metric.ramPercent, icon: "memorychip")
                    gaugeCard(label: "Disk", value: metric.diskPercent, icon: "internaldrive")
                }

                GroupBox("Quick Actions") {
                    HStack(spacing: 10) {
                        Button {
                            NSWorkspace.shared.open(URL(string: "ssh://\(AppConfig.r730SSHHost)")!)
                        } label: {
                            Label("SSH into \(metric.displayName)", systemImage: "terminal")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            NSWorkspace.shared.open(AppConfig.grafanaURL)
                        } label: {
                            Label("View in Grafana", systemImage: "chart.bar.xaxis")
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
        }
        .navigationTitle(metric.displayName)
    }

    private func gaugeCard(label: String, value: Double, icon: String) -> some View {
        GroupBox {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(value > 80 ? .red : value > 60 ? .orange : .green)
                Text("\(Int(value))%")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: value / 100)
                    .tint(value > 80 ? .red : value > 60 ? .orange : .green)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
