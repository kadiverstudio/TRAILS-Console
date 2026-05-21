import SwiftUI

// Crash report data would come from the API at /api/crashes
// Currently showing mock data to unblock UI development.
struct CrashReportView: View {
    let app: AppTag

    @State private var crashes: [MockCrash] = MockCrash.samples
    @State private var selected: MockCrash?

    var body: some View {
        NavigationSplitView {
            List(crashes, selection: $selected) { crash in
                CrashRow(crash: crash).tag(crash)
            }
            .listStyle(.plain)
            .navigationTitle("\(app.displayName) Crashes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Text("\(crashes.count) reports")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } detail: {
            if let crash = selected {
                CrashDetailView(crash: crash)
            } else {
                ContentUnavailableView("Select a Crash Report", systemImage: "ladybug")
            }
        }
    }
}

// MARK: - Mock model

private struct MockCrash: Identifiable, Hashable {
    let id = UUID()
    let version: String
    let platform: String
    let errorType: String
    let message: String
    let occurrences: Int
    let lastSeen: Date
    let stackTrace: String

    static let samples: [MockCrash] = [
        MockCrash(version: "1.4.2", platform: "iOS 17.4", errorType: "EXC_BAD_ACCESS",
                  message: "SIGSEGV SEGV_ACCERR at 0x0000000000000010",
                  occurrences: 14, lastSeen: Date().addingTimeInterval(-1800),
                  stackTrace: "0  libswiftCore.dylib\n1  TRAILS\n2  LoginViewModel.handleToken()\n3  FusionAuthService.refresh()"),
        MockCrash(version: "1.4.1", platform: "iOS 16.7", errorType: "NSInvalidArgumentException",
                  message: "*** -[NSNull length]: unrecognized selector sent to instance",
                  occurrences: 6, lastSeen: Date().addingTimeInterval(-7200),
                  stackTrace: "0  CoreFoundation\n1  TRAILS\n2  FeedDecoder.decodeItem()\n3  APIClient.fetch()"),
        MockCrash(version: "1.4.2", platform: "Android 14", errorType: "NullPointerException",
                  message: "Attempt to invoke virtual method on a null object reference",
                  occurrences: 3, lastSeen: Date().addingTimeInterval(-86400),
                  stackTrace: "at com.musictrails.api.MessageService.send(MessageService.kt:82)\nat MainActivity.onResume()"),
    ]
}

private struct CrashRow: View {
    let crash: MockCrash

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "ladybug.fill")
                .foregroundStyle(.red)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                Text(crash.errorType)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(crash.platform)
                    Text("·")
                    Text("v\(crash.version)")
                    Spacer()
                    Text("\(crash.occurrences)×")
                        .foregroundStyle(.red)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct CrashDetailView: View {
    let crash: MockCrash

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "ladybug.fill").foregroundStyle(.red).font(.title)
                    VStack(alignment: .leading) {
                        Text(crash.errorType).font(.title2).fontWeight(.semibold)
                        Text("Last seen \(crash.lastSeen.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(crash.occurrences) occurrences")
                        .font(.caption).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(.red, in: Capsule())
                }

                GroupBox("Error") {
                    Text(crash.message)
                        .font(.system(.callout, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }

                GroupBox("Stack Trace") {
                    Text(crash.stackTrace)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }

                GroupBox("Environment") {
                    Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 6) {
                        GridRow {
                            Text("Platform").foregroundStyle(.secondary)
                            Text(crash.platform)
                        }
                        GridRow {
                            Text("App version").foregroundStyle(.secondary)
                            Text("v\(crash.version)")
                        }
                    }
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
        }
        .navigationTitle(crash.errorType)
    }
}
