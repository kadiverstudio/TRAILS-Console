import SwiftUI

// Venue outreach for Music Trails — tracks venues we're targeting for partnerships.
struct VenueOutreachView: View {
    @State private var venues: [VenueLead] = VenueLead.mockData
    @State private var selected: VenueLead?
    @State private var searchText = ""

    private var filtered: [VenueLead] {
        venues.filter { v in
            searchText.isEmpty
                || v.name.localizedCaseInsensitiveContains(searchText)
                || v.city.localizedCaseInsensitiveContains(searchText)
        }
        .sorted { $0.status.sortOrder < $1.status.sortOrder }
    }

    var body: some View {
        NavigationSplitView {
            List(filtered, selection: $selected) { venue in
                VenueRow(venue: venue).tag(venue)
            }
            .listStyle(.plain)
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView("No Venues", systemImage: "mappin.and.ellipse")
                }
            }
            .navigationTitle("Venue Outreach")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        venues.append(VenueLead(
                            name: "New Venue", city: "City", state: "ST",
                            contactEmail: "", status: .prospect, notes: ""
                        ))
                    } label: {
                        Label("Add Venue", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let venue = selected {
                VenueDetailView(venue: venue)
            } else {
                ContentUnavailableView("Select a Venue", systemImage: "mappin.and.ellipse")
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search venues")
    }
}

// MARK: - Model

struct VenueLead: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var city: String
    var state: String
    var contactEmail: String
    var status: OutreachStatus
    var notes: String

    enum OutreachStatus: String, CaseIterable {
        case prospect, contacted, inConversation, onboarded, declined

        var label: String {
            switch self {
            case .prospect:        "Prospect"
            case .contacted:       "Contacted"
            case .inConversation:  "In Conversation"
            case .onboarded:       "Onboarded"
            case .declined:        "Declined"
            }
        }

        var color: Color {
            switch self {
            case .prospect:        .secondary
            case .contacted:       .blue
            case .inConversation:  .orange
            case .onboarded:       .green
            case .declined:        .red
            }
        }

        var sortOrder: Int {
            switch self {
            case .inConversation: 0
            case .contacted:      1
            case .prospect:       2
            case .onboarded:      3
            case .declined:       4
            }
        }
    }

    static let mockData: [VenueLead] = [
        VenueLead(name: "The Fillmore",         city: "San Francisco", state: "CA", contactEmail: "booking@fillmore.com",       status: .inConversation, notes: "Spoke with GM on May 10. They're open to featuring local artists on Music Trails."),
        VenueLead(name: "Metro Chicago",         city: "Chicago",       state: "IL", contactEmail: "events@metrochicago.com",   status: .contacted,      notes: "Sent intro email. Awaiting reply."),
        VenueLead(name: "9:30 Club",             city: "Washington",    state: "DC", contactEmail: "info@930.com",             status: .prospect,       notes: "High priority — strong indie scene."),
        VenueLead(name: "The Troubadour",        city: "Los Angeles",   state: "CA", contactEmail: "contact@troubadour.com",   status: .onboarded,      notes: "Profile live as of April 2026."),
        VenueLead(name: "First Avenue",          city: "Minneapolis",   state: "MN", contactEmail: "bookings@first-avenue.com",status: .declined,       notes: "Not interested at this time."),
    ]
}

private struct VenueRow: View {
    let venue: VenueLead

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(venue.status.color)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(venue.name)
                    .font(.callout)
                    .fontWeight(.medium)
                Text("\(venue.city), \(venue.state) · \(venue.status.label)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct VenueDetailView: View {
    let venue: VenueLead

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(venue.name).font(.largeTitle).fontWeight(.bold)
                        Text("\(venue.city), \(venue.state)").font(.title3).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(venue.status.label)
                        .font(.callout)
                        .foregroundStyle(venue.status.color)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(venue.status.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                GroupBox("Contact") {
                    HStack {
                        Text(venue.contactEmail.isEmpty ? "No contact email" : venue.contactEmail)
                            .font(.callout)
                            .foregroundStyle(venue.contactEmail.isEmpty ? .tertiary : .primary)
                        Spacer()
                        if !venue.contactEmail.isEmpty {
                            Button {
                                NSWorkspace.shared.open(URL(string: "mailto:\(venue.contactEmail)")!)
                            } label: {
                                Label("Email", systemImage: "envelope")
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }

                GroupBox("Notes") {
                    Text(venue.notes.isEmpty ? "No notes yet." : venue.notes)
                        .font(.callout)
                        .foregroundStyle(venue.notes.isEmpty ? .tertiary : .primary)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                }
            }
            .padding(24)
        }
        .navigationTitle(venue.name)
    }
}
