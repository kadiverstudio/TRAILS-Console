import SwiftUI

// Log tail would be streamed via an API endpoint (e.g. /api/logs/nginx?lines=200)
// or over SSH. Showing mock entries to unblock UI work.
struct NGINXLogsView: View {
    @State private var lines: [LogLine] = LogLine.mockData
    @State private var filterLevel: LogLevel? = nil
    @State private var isLive = false
    @State private var autoScrollTask: Task<Void, Never>?

    var filteredLines: [LogLine] {
        guard let level = filterLevel else { return lines }
        return lines.filter { $0.level == level }
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            logList
        }
        .navigationTitle("NGINX Logs")
        .onDisappear { autoScrollTask?.cancel() }
    }

    private var toolbar: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.text")
            Text("error.log + access.log")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()

            Toggle(isOn: $isLive) {
                Label("Live", systemImage: isLive ? "record.circle.fill" : "record.circle")
            }
            .toggleStyle(.button)
            .tint(.red)
            .controlSize(.small)

            Divider().frame(height: 20)

            ForEach(LogLevel.allCases, id: \.self) { level in
                Toggle(level.rawValue.uppercased(), isOn: Binding(
                    get: { filterLevel == level },
                    set: { filterLevel = $0 ? level : nil }
                ))
                .toggleStyle(.button)
                .tint(level.color)
                .controlSize(.mini)
            }

            Button { lines = LogLine.mockData } label: {
                Label("Clear", systemImage: "trash")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var logList: some View {
        ScrollViewReader { proxy in
            List(filteredLines) { line in
                LogLineRow(line: line)
                    .id(line.id)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            }
            .listStyle(.plain)
            .font(.system(.caption, design: .monospaced))
            .onChange(of: lines.count) { _, _ in
                if let last = filteredLines.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }
}

// MARK: - Models

enum LogLevel: String, CaseIterable {
    case error, warn, info

    var color: Color {
        switch self {
        case .error: .red
        case .warn:  .orange
        case .info:  .secondary
        }
    }
}

struct LogLine: Identifiable {
    let id = UUID()
    let timestamp: String
    let level: LogLevel
    let method: String
    let path: String
    let status: Int
    let bytes: Int
    let duration: Double

    var statusColor: Color {
        switch status {
        case 200...299: .green
        case 300...399: .blue
        case 400...499: .orange
        default:        .red
        }
    }

    static let mockData: [LogLine] = [
        LogLine(timestamp: "2026-05-15 10:01:32", level: .info,  method: "GET",  path: "/api/feed",        status: 200, bytes: 4_812, duration: 0.044),
        LogLine(timestamp: "2026-05-15 10:01:33", level: .info,  method: "POST", path: "/api/auth/refresh", status: 200, bytes: 512,   duration: 0.031),
        LogLine(timestamp: "2026-05-15 10:01:35", level: .warn,  method: "GET",  path: "/api/media/large",  status: 404, bytes: 120,   duration: 0.008),
        LogLine(timestamp: "2026-05-15 10:01:40", level: .error, method: "POST", path: "/api/messages",     status: 500, bytes: 200,   duration: 0.812),
        LogLine(timestamp: "2026-05-15 10:01:41", level: .info,  method: "GET",  path: "/api/users/me",     status: 200, bytes: 1_024, duration: 0.022),
        LogLine(timestamp: "2026-05-15 10:01:44", level: .info,  method: "GET",  path: "/api/venues",       status: 200, bytes: 8_204, duration: 0.058),
        LogLine(timestamp: "2026-05-15 10:01:49", level: .warn,  method: "PUT",  path: "/api/profile",      status: 401, bytes: 80,    duration: 0.005),
        LogLine(timestamp: "2026-05-15 10:02:01", level: .info,  method: "GET",  path: "/api/notifications",status: 200, bytes: 640,   duration: 0.019),
    ]
}

private struct LogLineRow: View {
    let line: LogLine

    var body: some View {
        HStack(spacing: 8) {
            Text(line.timestamp)
                .foregroundStyle(.tertiary)
                .frame(width: 155, alignment: .leading)

            Text(line.level.rawValue.uppercased())
                .foregroundStyle(line.level.color)
                .frame(width: 36, alignment: .leading)

            Text(line.method)
                .foregroundStyle(.blue)
                .frame(width: 36, alignment: .leading)

            Text(line.path)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer()

            Text("\(line.status)")
                .foregroundStyle(line.statusColor)
                .frame(width: 32, alignment: .trailing)

            Text("\(String(format: "%.0f", line.duration * 1000))ms")
                .foregroundStyle(.secondary)
                .frame(width: 48, alignment: .trailing)
        }
        .padding(.vertical, 1)
    }
}
