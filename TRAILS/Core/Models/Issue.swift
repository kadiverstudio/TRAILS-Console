import SwiftUI

enum AppTag: String, Codable, Hashable {
    case musicTrails = "musictrails"
    case sceneTrails = "scenetrails"

    var displayName: String {
        switch self {
        case .musicTrails: "Music Trails"
        case .sceneTrails: "Scene Trails"
        }
    }

    var shortName: String {
        switch self {
        case .musicTrails: "MT"
        case .sceneTrails: "ST"
        }
    }

    var color: Color {
        switch self {
        case .musicTrails: Color(red: 0.325, green: 0.290, blue: 0.718)
        case .sceneTrails: .blue
        }
    }
}

enum IssueSeverity: String, Codable, Comparable {
    case high, medium, low, info

    static func < (lhs: IssueSeverity, rhs: IssueSeverity) -> Bool {
        let order: [IssueSeverity] = [.high, .medium, .low, .info]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }

    var color: Color {
        switch self {
        case .high:   .red
        case .medium: .orange
        case .low:    .green
        case .info:   .blue
        }
    }

    var label: String { rawValue.capitalized }
}

struct IssuePreview: Codable, Identifiable, Hashable {
    let id: UUID
    let appTag: AppTag
    let title: String
    let severity: IssueSeverity
    let issueNumber: Int
    let createdAt: Date

    var ageDescription: String {
        let interval = Date().timeIntervalSince(createdAt)
        let mins  = Int(interval / 60)
        let hours = Int(interval / 3_600)
        let days  = Int(interval / 86_400)
        if days  >= 1 { return "\(days)d" }
        if hours >= 1 { return "\(hours)h" }
        if mins  >= 1 { return "\(mins)m" }
        return "now"
    }
}

extension IssuePreview {
    static let mockData: [IssuePreview] = [
        IssuePreview(id: UUID(), appTag: .musicTrails,
                     title: "Login fails after FusionAuth token refresh",
                     severity: .high, issueNumber: 142,
                     createdAt: Date().addingTimeInterval(-3_600 * 2)),
        IssuePreview(id: UUID(), appTag: .musicTrails,
                     title: "Feed not loading for users in EU region",
                     severity: .medium, issueNumber: 141,
                     createdAt: Date().addingTimeInterval(-3_600 * 5)),
        IssuePreview(id: UUID(), appTag: .sceneTrails,
                     title: "Studio profile images not rendering",
                     severity: .medium, issueNumber: 89,
                     createdAt: Date().addingTimeInterval(-3_600 * 8)),
        IssuePreview(id: UUID(), appTag: .musicTrails,
                     title: "Push notifications delayed ~15 min",
                     severity: .low, issueNumber: 140,
                     createdAt: Date().addingTimeInterval(-86_400)),
        IssuePreview(id: UUID(), appTag: .sceneTrails,
                     title: "Venue search returning wrong radius results",
                     severity: .high, issueNumber: 88,
                     createdAt: Date().addingTimeInterval(-86_400 * 2)),
        IssuePreview(id: UUID(), appTag: .sceneTrails,
                     title: "Booking confirmation emails not sending",
                     severity: .medium, issueNumber: 87,
                     createdAt: Date().addingTimeInterval(-86_400 * 3)),
    ]

    static var mockMT: [IssuePreview] { mockData.filter { $0.appTag == .musicTrails } }
    static var mockST: [IssuePreview] { mockData.filter { $0.appTag == .sceneTrails } }
}
