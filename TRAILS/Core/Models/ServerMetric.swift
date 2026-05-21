import SwiftUI

enum ServerHealth {
    case online, warning, offline

    var color: Color {
        switch self {
        case .online:  .green
        case .warning: .orange
        case .offline: .red
        }
    }

    var label: String {
        switch self {
        case .online:  "Online"
        case .warning: "Warning"
        case .offline: "Offline"
        }
    }

    var icon: String {
        switch self {
        case .online:  "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .offline: "xmark.circle.fill"
        }
    }
}

struct ServerMetric: Identifiable, Hashable {
    let id: String
    let displayName: String
    var cpuPercent: Double
    var ramPercent: Double
    var diskPercent: Double
    var isOnline: Bool
    var lastSeen: Date

    var health: ServerHealth {
        guard isOnline else { return .offline }
        if cpuPercent > 80 || ramPercent > 85 || diskPercent > 90 { return .warning }
        return .online
    }
}

extension ServerMetric {
    static let mockData: [ServerMetric] = [
        ServerMetric(id: "r730", displayName: "Dell R730",
                     cpuPercent: 34, ramPercent: 61, diskPercent: 45,
                     isOnline: true, lastSeen: Date()),
        ServerMetric(id: "r630", displayName: "Dell R630",
                     cpuPercent: 12, ramPercent: 38, diskPercent: 22,
                     isOnline: true, lastSeen: Date()),
    ]
}
