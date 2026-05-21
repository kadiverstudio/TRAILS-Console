import SwiftUI

enum SidebarSection: String {
    case musicTrails    = "Music Trails"
    case sceneTrails    = "Scene Trails"
    case infrastructure = "Infrastructure"
    case communications = "Communications"
    case actions        = "Quick Actions"
}

enum SidebarItem: String, CaseIterable, Identifiable {
    // Top-level
    case overview
    // Music Trails
    case mtIssues, mtSupport, mtDeploys
    // Scene Trails
    case stIssues, stSupport, stDeploys
    // Infrastructure
    case infrastructure, grafana, docker, nginxLogs
    // Communications
    case inbox, venueOutreach, studioMemberships
    // Actions
    case quickActions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview:         "Overview"
        case .mtIssues:         "Issues"
        case .mtSupport:        "Support"
        case .mtDeploys:        "Deploys"
        case .stIssues:         "Issues"
        case .stSupport:        "Support"
        case .stDeploys:        "Deploys"
        case .infrastructure:   "Servers"
        case .grafana:          "Grafana"
        case .docker:           "Docker"
        case .nginxLogs:        "NGINX Logs"
        case .inbox:            "Inbox"
        case .venueOutreach:    "Venue Outreach"
        case .studioMemberships:"Studio Members"
        case .quickActions:     "Quick Actions"
        }
    }

    var icon: String {
        switch self {
        case .overview:         "square.grid.2x2.fill"
        case .mtIssues:         "exclamationmark.circle"
        case .mtSupport:        "bubble.left.and.bubble.right"
        case .mtDeploys:        "arrow.up.to.line.circle"
        case .stIssues:         "exclamationmark.circle"
        case .stSupport:        "bubble.left.and.bubble.right"
        case .stDeploys:        "arrow.up.to.line.circle"
        case .infrastructure:   "server.rack"
        case .grafana:          "chart.bar.xaxis"
        case .docker:           "cube.box"
        case .nginxLogs:        "doc.text"
        case .inbox:            "tray"
        case .venueOutreach:    "mappin.and.ellipse"
        case .studioMemberships:"person.3"
        case .quickActions:     "bolt.fill"
        }
    }

    var section: SidebarSection? {
        switch self {
        case .overview:                              return nil
        case .mtIssues, .mtSupport, .mtDeploys:      return .musicTrails
        case .stIssues, .stSupport, .stDeploys:      return .sceneTrails
        case .infrastructure, .grafana, .docker,
             .nginxLogs:                             return .infrastructure
        case .inbox, .venueOutreach,
             .studioMemberships:                     return .communications
        case .quickActions:                          return .actions
        }
    }
}
