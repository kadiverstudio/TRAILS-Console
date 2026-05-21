import SwiftUI

struct InboxView: View {
    @Environment(AppState.self) private var appState
    @State private var selected: EmailMessage?
    @State private var searchText = ""
    @State private var filterApp: AppTag? = nil

    private var messages: [EmailMessage] {
        appState.emailService.messages
            .filter { msg in
                let matchesApp    = filterApp == nil || msg.appTag == filterApp
                let matchesSearch = searchText.isEmpty
                    || msg.subject.localizedCaseInsensitiveContains(searchText)
                    || msg.from.localizedCaseInsensitiveContains(searchText)
                return matchesApp && matchesSearch
            }
            .sorted { $0.receivedAt > $1.receivedAt }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                filterBar
                Divider()
                List(messages, selection: $selected) { msg in
                    InboxRow(message: msg).tag(msg)
                }
                .listStyle(.plain)
                .overlay {
                    if messages.isEmpty {
                        ContentUnavailableView(
                            searchText.isEmpty ? "Inbox Empty" : "No Results",
                            systemImage: searchText.isEmpty ? "tray" : "magnifyingglass"
                        )
                    }
                }
            }
            .navigationTitle("Inbox")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { Task { await appState.emailService.refresh() } } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(appState.emailService.isLoading)
                }
                ToolbarItem {
                    if appState.emailService.isLoading {
                        ProgressView().controlSize(.small)
                    }
                }
            }
        } detail: {
            if let msg = selected {
                EmailDetailView(message: msg)
            } else {
                ContentUnavailableView("Select a Message", systemImage: "envelope")
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search inbox")
        .task { await appState.emailService.refresh() }
    }

    private var filterBar: some View {
        HStack(spacing: 6) {
            filterButton(label: "All", tag: nil)
            filterButton(label: "MT", tag: .musicTrails, color: AppTag.musicTrails.color)
            filterButton(label: "ST", tag: .sceneTrails, color: AppTag.sceneTrails.color)
            Spacer()
            if appState.emailService.unreadCount > 0 {
                Text("\(appState.emailService.unreadCount) unread")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func filterButton(label: String, tag: AppTag?, color: Color = .primary) -> some View {
        Button {
            filterApp = filterApp == tag ? nil : tag
        } label: {
            Text(label)
                .font(.caption)
                .fontWeight(filterApp == tag ? .semibold : .regular)
                .foregroundStyle(filterApp == tag ? .white : color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(filterApp == tag ? color : color.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Row

private struct InboxRow: View {
    let message: EmailMessage

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(message.isRead ? Color.clear : Color.blue)
                .overlay(Circle().stroke(message.isRead ? Color.secondary.opacity(0.2) : Color.clear, lineWidth: 1))
                .frame(width: 8, height: 8)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(message.senderName)
                        .font(.callout)
                        .fontWeight(message.isRead ? .regular : .semibold)
                        .lineLimit(1)
                    Text(message.appTag.shortName)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(message.appTag.color)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(message.appTag.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 3))
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

// MARK: - Detail

private struct EmailDetailView: View {
    let message: EmailMessage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(message.appTag.shortName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(message.appTag.color)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(message.appTag.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 5))
                        Spacer()
                        Text(message.receivedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Text(message.subject)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("From: \(message.from)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Divider()

                Text(message.preview)
                    .font(.body)
                    .lineSpacing(4)

                Text("[ Full email body fetched from Microsoft Graph API ]")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 12)
            }
            .padding(24)
        }
        .navigationTitle(message.senderName)
    }
}
