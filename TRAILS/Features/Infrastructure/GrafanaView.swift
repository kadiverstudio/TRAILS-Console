import SwiftUI
import WebKit

struct GrafanaView: View {
    @State private var isLoading = true
    @State private var isOffline = false
    @State private var loadTrigger = UUID()

    var body: some View {
        VStack(spacing: 0) {
            toolbarRow
            Divider()

            if isOffline {
                offlineState
            } else {
                ZStack {
                    GrafanaWebView(
                        url: AppConfig.grafanaURL,
                        loadTrigger: loadTrigger,
                        isLoading: $isLoading,
                        onOffline: { isOffline = true }
                    )
                    if isLoading {
                        ProgressView("Loading Grafana…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(nsColor: .windowBackgroundColor))
                    }
                }
            }
        }
        .navigationTitle("Grafana")
    }

    private var toolbarRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .foregroundStyle(.orange)
            Text("Grafana")
                .font(.headline)
            Text("·")
                .foregroundStyle(.tertiary)
            Text(AppConfig.grafanaURL.host ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if isLoading && !isOffline {
                ProgressView().controlSize(.mini)
            }
            Button {
                NSWorkspace.shared.open(AppConfig.grafanaURL)
            } label: {
                Label("Open in Browser", systemImage: "safari")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var offlineState: some View {
        ContentUnavailableView {
            Label("Grafana Unreachable", systemImage: "antenna.radiowaves.left.and.right.slash")
        } description: {
            Text("Could not connect to \(AppConfig.grafanaURL.absoluteString).\nCheck that the Mac mini is powered on and Grafana is running on port 3000.")
        } actions: {
            HStack(spacing: 10) {
                Button("Retry") {
                    isOffline = false
                    loadTrigger = UUID()
                }
                .buttonStyle(.borderedProminent)
                Button("Open in Browser") {
                    NSWorkspace.shared.open(AppConfig.grafanaURL)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - WKWebView wrapper

struct GrafanaWebView: NSViewRepresentable {
    let url: URL
    let loadTrigger: UUID
    @Binding var isLoading: Bool
    var onOffline: () -> Void

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastTrigger != loadTrigger {
            context.coordinator.lastTrigger = loadTrigger
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, onOffline: onOffline, trigger: loadTrigger)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        var onOffline: () -> Void
        var lastTrigger: UUID

        init(isLoading: Binding<Bool>, onOffline: @escaping () -> Void, trigger: UUID) {
            _isLoading  = isLoading
            self.onOffline   = onOffline
            self.lastTrigger = trigger
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            isLoading = false
            onOffline()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
            isLoading = false
            onOffline()
        }
    }
}
