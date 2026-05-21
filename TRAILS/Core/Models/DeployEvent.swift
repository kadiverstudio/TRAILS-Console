import SwiftUI

enum DeployStatus: String, Codable {
    case success, failed, inProgress = "in_progress"

    var label: String {
        switch self {
        case .success:    "Success"
        case .failed:     "Failed"
        case .inProgress: "In Progress"
        }
    }

    var color: Color {
        switch self {
        case .success:    .green
        case .failed:     .red
        case .inProgress: .orange
        }
    }

    var icon: String {
        switch self {
        case .success:    "checkmark.circle.fill"
        case .failed:     "xmark.circle.fill"
        case .inProgress: "arrow.clockwise.circle.fill"
        }
    }
}

struct DeployEvent: Codable, Identifiable, Hashable {
    let id: UUID
    let appTag: AppTag
    let version: String
    let environment: String
    let status: DeployStatus
    let deployedAt: Date
    let deployedBy: String
    let commitSHA: String

    var shortSHA: String { String(commitSHA.prefix(7)) }

    var timeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: deployedAt, relativeTo: Date())
    }
}

extension DeployEvent {
    static let mockData: [DeployEvent] = [
        DeployEvent(id: UUID(), appTag: .musicTrails, version: "1.4.2",
                    environment: "production", status: .success,
                    deployedAt: Date().addingTimeInterval(-3_600 * 4),
                    deployedBy: "ian", commitSHA: "a3f91bc2d0e14"),
        DeployEvent(id: UUID(), appTag: .sceneTrails, version: "2.1.0",
                    environment: "production", status: .success,
                    deployedAt: Date().addingTimeInterval(-86_400),
                    deployedBy: "ian", commitSHA: "c7e28fa91b043"),
        DeployEvent(id: UUID(), appTag: .musicTrails, version: "1.4.1",
                    environment: "production", status: .failed,
                    deployedAt: Date().addingTimeInterval(-86_400 * 2),
                    deployedBy: "ian", commitSHA: "55a1d3b09f872"),
        DeployEvent(id: UUID(), appTag: .musicTrails, version: "1.4.0",
                    environment: "production", status: .success,
                    deployedAt: Date().addingTimeInterval(-86_400 * 5),
                    deployedBy: "ian", commitSHA: "f09e2ca371b5d"),
        DeployEvent(id: UUID(), appTag: .sceneTrails, version: "2.0.9",
                    environment: "production", status: .success,
                    deployedAt: Date().addingTimeInterval(-86_400 * 7),
                    deployedBy: "ian", commitSHA: "b81c0d4e22af9"),
    ]

    static var mockMT: [DeployEvent] { mockData.filter { $0.appTag == .musicTrails } }
    static var mockST: [DeployEvent] { mockData.filter { $0.appTag == .sceneTrails } }
}
