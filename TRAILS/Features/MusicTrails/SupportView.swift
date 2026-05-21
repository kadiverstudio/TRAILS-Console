import SwiftUI

struct SupportView: View {
    let app: AppTag

    @Environment(AppState.self) private var appState
    @State private var selected: EmailMessage?
    @State private var searchText = ""

    private var messages: [EmailMessage] {
        appState.emailService.messages
            .filter { $0.appTag == app }
            .filter { searchText.isEmpty || $0.subject.localizedCaseInsensitiveContains(searchText) || $0.from.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.receivedAt > $1.receivedAt }
    }

    var body: some View {
        NavigationSplitView {
            List(messages, selection: $selected) { msg in
                SupportMessageRow(message: msg).tag(msg)
            }
            .listStyle(.plain)
            .overlay {
                if messages.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Support Emails" : "No Results",
                        systemImage: "envelope",
                        description: Text(searchText.isEmpty ? "All support emails for \(app.displayName) will appear here." : "Try a different search.")
                    )
                }
            }
            .navigationTitle("\(app.displayName) Support")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { Task { await appState.emailService.refresh() } } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        } detail: {
            if let msg = selected {
                SupportMessageDetail(message: msg)
            } else {
                ContentUnavailableView("Select a Message", systemImage: "envelope")
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search messages")
        .task { await appState.emailService.refresh() }
    }
}

private struct SupportMessageRow: View {
    let message: EmailMessage

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(message.isRead ? Color.clear : Color.blue)
                .overlay(Circle().stroke(message.isRead ? Color.secondary.opacity(0.3) : Color.clear, lineWidth: 1))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(message.senderName)
                        .font(.callout)
                        .fontWeight(message.isRead ? .regular : .semibold)
                        .lineLimit(1)
                    Spacer()
                    Text(message.ageDescription)
                        .font(.caption2)
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
        .padding(.vertical, 3)
    }
}

private struct SupportMessageDetail: View {
    let message: EmailMessage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.subject)
                        .font(.title2)
                        .fontWeight(.semibold)
                    HStack {
                        Text("From: \(message.from)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(message.receivedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Divider()

                Text(message.preview)
                    .font(.body)

                Text("[ Full email body would be fetched from Microsoft Graph API ]")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 8)

                Spacer()
            }
            .padding(24)
        }
        .navigationTitle(message.senderName)
    }
}
