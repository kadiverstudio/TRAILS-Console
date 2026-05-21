import SwiftUI

struct IssueListView: View {
    let app: AppTag

    @Environment(AppState.self) private var appState
    @State private var selectedIssue: IssuePreview?
    @State private var searchText = ""
    @State private var filterSeverity: IssueSeverity? = nil

    private var issues: [IssuePreview] {
        appState.issueService.issues(for: app)
            .filter { issue in
                let matchesSearch = searchText.isEmpty ||
                    issue.title.localizedCaseInsensitiveContains(searchText)
                let matchesSeverity = filterSeverity == nil || issue.severity == filterSeverity
                return matchesSearch && matchesSeverity
            }
            .sorted { $0.severity < $1.severity }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                filterBar
                Divider()
                List(issues, selection: $selectedIssue) { issue in
                    IssueListRow(issue: issue)
                        .tag(issue)
                }
                .listStyle(.plain)
                .overlay {
                    if issues.isEmpty {
                        ContentUnavailableView(
                            searchText.isEmpty ? "No Open Issues" : "No Results",
                            systemImage: searchText.isEmpty ? "checkmark.circle" : "magnifyingglass",
                            description: Text(searchText.isEmpty
                                ? "All caught up for \(app.displayName)."
                                : "Try adjusting your search or filter.")
                        )
                    }
                }
            }
            .navigationTitle("\(app.displayName) Issues")
            .toolbar { toolbarContent }
        } detail: {
            if let issue = selectedIssue {
                IssueDetailView(issue: issue)
            } else {
                ContentUnavailableView("Select an Issue", systemImage: "exclamationmark.circle")
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search issues")
        .task { await appState.issueService.refresh() }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                FilterChip(label: "All", isSelected: filterSeverity == nil) {
                    filterSeverity = nil
                }
                ForEach([IssueSeverity.high, .medium, .low, .info], id: \.self) { severity in
                    FilterChip(label: severity.label, color: severity.color,
                               isSelected: filterSeverity == severity) {
                        filterSeverity = filterSeverity == severity ? nil : severity
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                Task { await appState.issueService.refresh() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .disabled(appState.issueService.isLoading)
        }
        ToolbarItem {
            if appState.issueService.isLoading {
                ProgressView().controlSize(.small)
            }
        }
    }
}

// MARK: - Row

private struct IssueListRow: View {
    let issue: IssuePreview

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(issue.severity.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(issue.title)
                    .font(.callout)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    Text("#\(issue.issueNumber)")
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(issue.severity.label)
                        .foregroundStyle(issue.severity.color)
                    Spacer()
                    Text(issue.ageDescription)
                        .foregroundStyle(.tertiary)
                }
                .font(.caption)
                .monospacedDigit()
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Detail

private struct IssueDetailView: View {
    let issue: IssuePreview

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("#\(issue.issueNumber)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(issue.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    Label(issue.severity.label, systemImage: "circle.fill")
                        .foregroundStyle(issue.severity.color)
                        .font(.callout)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(issue.severity.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                GroupBox("Details") {
                    Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 8) {
                        GridRow {
                            Text("App").foregroundStyle(.secondary)
                            Text(issue.appTag.displayName)
                        }
                        GridRow {
                            Text("Severity").foregroundStyle(.secondary)
                            Text(issue.severity.label).foregroundStyle(issue.severity.color)
                        }
                        GridRow {
                            Text("Opened").foregroundStyle(.secondary)
                            Text(issue.createdAt.formatted(date: .abbreviated, time: .shortened))
                        }
                        GridRow {
                            Text("Age").foregroundStyle(.secondary)
                            Text(issue.ageDescription)
                        }
                    }
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Notes") {
                    Text("Add your investigation notes here.")
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                }
            }
            .padding(24)
        }
        .navigationTitle("#\(issue.issueNumber)")
    }
}

// MARK: - Filter chip

private struct FilterChip: View {
    let label: String
    var color: Color = .primary
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? color : color.opacity(0.08),
                             in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
