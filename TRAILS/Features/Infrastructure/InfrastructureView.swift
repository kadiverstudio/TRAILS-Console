import SwiftUI

// Servers + Grafana split — the primary Infrastructure landing page.
struct InfrastructureView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VSplitView {
            ServerListView()
                .frame(minHeight: 200, idealHeight: 340)
            GrafanaView()
                .frame(minHeight: 200)
        }
    }
}
