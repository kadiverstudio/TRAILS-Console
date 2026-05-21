import SwiftUI

// Studio membership management for Scene Trails.
struct StudioMembershipsView: View {
    @State private var studios: [StudioMember] = StudioMember.mockData
    @State private var selected: StudioMember?
    @State private var searchText = ""
    @State private var filterTier: StudioMember.Tier? = nil

    private var filtered: [StudioMember] {
        studios.filter { s in
            let matchesTier   = filterTier == nil || s.tier == filterTier
            let matchesSearch = searchText.isEmpty
                || s.name.localizedCaseInsensitiveContains(searchText)
                || s.city.localizedCaseInsensitiveContains(searchText)
            return matchesTier && matchesSearch
        }
        .sorted { $0.joinedAt > $1.joinedAt }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                tierFilter
                Divider()
                List(filtered, selection: $selected) { studio in
                    StudioRow(studio: studio).tag(studio)
                }
                .listStyle(.plain)
                .overlay {
                    if filtered.isEmpty {
                        ContentUnavailableView("No Studios", systemImage: "person.3")
                    }
                }
            }
            .navigationTitle("Studio Members")
            .toolbar {
                ToolbarItem {
                    Text("\(studios.count) total")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        } detail: {
            if let studio = selected {
                StudioDetailView(studio: studio)
            } else {
                ContentUnavailableView("Select a Studio", systemImage: "person.3")
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search studios")
    }

    private var tierFilter: some View {
        HStack(spacing: 6) {
            chipButton("All", tag: nil, color: .primary)
            ForEach(StudioMember.Tier.allCases, id: \.self) { tier in
                chipButton(tier.label, tag: tier, color: tier.color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func chipButton(_ label: String, tag: StudioMember.Tier?, color: Color) -> some View {
        Button { filterTier = filterTier == tag ? nil : tag } label: {
            Text(label)
                .font(.caption)
                .fontWeight(filterTier == tag ? .semibold : .regular)
                .foregroundStyle(filterTier == tag ? .white : color)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(filterTier == tag ? color : color.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Model

struct StudioMember: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let city: String
    let state: String
    let contactEmail: String
    let tier: Tier
    let joinedAt: Date
    let activeBookings: Int

    enum Tier: String, CaseIterable {
        case free, pro, enterprise

        var label: String { rawValue.capitalized }

        var color: Color {
            switch self {
            case .free:       .secondary
            case .pro:        .blue
            case .enterprise: .purple
            }
        }

        var icon: String {
            switch self {
            case .free:       "star"
            case .pro:        "star.fill"
            case .enterprise: "crown.fill"
            }
        }
    }

    static let mockData: [StudioMember] = [
        StudioMember(name: "Sunset Sound Studios",  city: "Los Angeles",  state: "CA", contactEmail: "info@sunsetsound.com",   tier: .enterprise, joinedAt: Date().addingTimeInterval(-86400 * 120), activeBookings: 14),
        StudioMember(name: "Electric Lady Studios", city: "New York",     state: "NY", contactEmail: "contact@electriclady.com",tier: .enterprise, joinedAt: Date().addingTimeInterval(-86400 * 90),  activeBookings: 22),
        StudioMember(name: "Blackbird Studios",     city: "Nashville",    state: "TN", contactEmail: "book@blackbirdstudios.com",tier: .pro,       joinedAt: Date().addingTimeInterval(-86400 * 60),  activeBookings: 8),
        StudioMember(name: "Pachyderm Studio",      city: "Cannon Falls", state: "MN", contactEmail: "info@pachyderm.com",     tier: .pro,        joinedAt: Date().addingTimeInterval(-86400 * 45),  activeBookings: 3),
        StudioMember(name: "Tiny Telephone",        city: "San Francisco",state: "CA", contactEmail: "hello@tinytelephone.com",tier: .pro,        joinedAt: Date().addingTimeInterval(-86400 * 30),  activeBookings: 5),
        StudioMember(name: "Home Studio SF",        city: "San Francisco",state: "CA", contactEmail: "me@homestudio.com",      tier: .free,       joinedAt: Date().addingTimeInterval(-86400 * 10),  activeBookings: 0),
    ]
}

private struct StudioRow: View {
    let studio: StudioMember

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: studio.tier.icon)
                .foregroundStyle(studio.tier.color)
                .font(.callout)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(studio.name)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text("\(studio.city), \(studio.state)")
                    Text("·")
                    Text(studio.tier.label)
                        .foregroundStyle(studio.tier.color)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if studio.activeBookings > 0 {
                Text("\(studio.activeBookings)")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.blue, in: Capsule())
            }
        }
        .padding(.vertical, 2)
    }
}

private struct StudioDetailView: View {
    let studio: StudioMember

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(studio.name).font(.largeTitle).fontWeight(.bold)
                        Text("\(studio.city), \(studio.state)").font(.title3).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Label(studio.tier.label, systemImage: studio.tier.icon)
                        .foregroundStyle(studio.tier.color)
                        .font(.callout)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(studio.tier.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                HStack(spacing: 12) {
                    GroupBox {
                        VStack {
                            Text("\(studio.activeBookings)")
                                .font(.system(size: 34, weight: .semibold, design: .rounded))
                            Text("Active Bookings").font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    GroupBox {
                        VStack {
                            Text(studio.joinedAt.formatted(.dateTime.month().year()))
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Text("Member Since").font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                GroupBox("Contact") {
                    HStack {
                        Text(studio.contactEmail)
                            .font(.callout)
                        Spacer()
                        Button {
                            NSWorkspace.shared.open(URL(string: "mailto:\(studio.contactEmail)")!)
                        } label: {
                            Label("Email", systemImage: "envelope")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle(studio.name)
    }
}
