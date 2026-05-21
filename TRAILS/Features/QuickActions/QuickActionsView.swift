import SwiftUI

struct QuickActionsView: View {
    private let columns = [GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 12)]
    private let vmActions: [SSHAction] = [
        SSHAction(name: "EDGE-PROXY", target: "edge@10.0.0.175"),
        SSHAction(name: "TRAILS-DB-01", target: "trails_db@10.0.0.182"),
        SSHAction(name: "TRAILS-AUTH-WEB-01", target: "web-auth@10.0.0.183"),
        SSHAction(name: "TRAILS-API-MUSIC-01", target: "music_api@10.0.0.177"),
        SSHAction(name: "TRAILS-API-SCENE-01", target: "scene_api@10.0.0.185"),
        SSHAction(name: "TRAILS-MEDIA-01", target: "trails_media@10.0.0.178"),
        SSHAction(name: "REDIS-REALTIME", target: "redis@10.0.0.179"),
        SSHAction(name: "BACKUP-MGMT", target: "backup_mgmt@10.0.0.180"),
        SSHAction(name: "ADMIN-TOOLS", target: "admin_tools@10.0.0.181"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionHeader("Monitoring")
                LazyVGrid(columns: columns, spacing: 12) {
                    ActionCard(
                        title: "MacMINI-OBS",
                        subtitle: "ianmclean@10.0.0.40",
                        icon: "terminal.fill",
                        color: .green
                    ) {
                        openSSH("ianmclean@10.0.0.40")
                    }
                    ActionCard(
                        title: "Grafana",
                        subtitle: hostLabel(for: AppConfig.grafanaURL),
                        icon: "chart.bar.xaxis",
                        color: .orange
                    ) {
                        NSWorkspace.shared.open(AppConfig.grafanaURL)
                    }
                    ActionCard(
                        title: "Uptime Kuma",
                        subtitle: hostLabel(for: AppConfig.uptimeKumaURL),
                        icon: "antenna.radiowaves.left.and.right",
                        color: .teal
                    ) {
                        NSWorkspace.shared.open(AppConfig.uptimeKumaURL)
                    }
                    ActionCard(
                        title: "Prometheus Targets",
                        subtitle: hostLabel(for: AppConfig.prometheusURL),
                        icon: "target",
                        color: .blue
                    ) {
                        NSWorkspace.shared.open(AppConfig.prometheusURL.appendingPathComponent("targets"))
                    }
                }

                sectionHeader("SSH into VMs")
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(vmActions) { vm in
                        ActionCard(
                            title: vm.name,
                            subtitle: vm.target,
                            icon: "terminal.fill",
                            color: .green
                        ) {
                            openSSH(vm.target)
                        }
                    }
                }

                sectionHeader("Finance & Distribution")
                LazyVGrid(columns: columns, spacing: 12) {
                    ActionCard(
                        title: "Stripe",
                        subtitle: "dashboard.stripe.com",
                        icon: "creditcard.fill",
                        color: .purple
                    ) {
                        NSWorkspace.shared.open(URL(string: "https://dashboard.stripe.com")!)
                    }
                }

                sectionHeader("Developer")
                LazyVGrid(columns: columns, spacing: 12) {
                    ActionCard(
                        title: "GitHub",
                        subtitle: "github.com",
                        icon: "chevron.left.forwardslash.chevron.right",
                        color: Color(nsColor: .labelColor)
                    ) {
                        NSWorkspace.shared.open(URL(string: "https://github.com")!)
                    }
                    ActionCard(
                        title: "App Store Connect",
                        subtitle: "appstoreconnect.apple.com",
                        icon: "apple.logo",
                        color: .blue
                    ) {
                        NSWorkspace.shared.open(URL(string: "https://appstoreconnect.apple.com")!)
                    }
                    ActionCard(
                        title: "Google Play Console",
                        subtitle: "play.google.com/console",
                        icon: "play.circle.fill",
                        color: .green
                    ) {
                        NSWorkspace.shared.open(URL(string: "https://play.google.com/console")!)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Quick Actions")
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
    }

    private func openSSH(_ target: String) {
        guard let url = URL(string: "ssh://\(target)") else { return }
        NSWorkspace.shared.open(url)
    }

    private func hostLabel(for url: URL) -> String {
        guard let host = url.host else { return url.absoluteString }
        if let port = url.port {
            return "\(host):\(port)"
        }
        return host
    }
}

// MARK: - Card

private struct SSHAction: Identifiable {
    let name: String
    let target: String

    var id: String { target }
}

private struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                        .padding(8)
                        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Spacer(minLength: 0)

                    HStack {
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 120)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isHovered)
        .onHover { isHovered = $0 }
    }
}
