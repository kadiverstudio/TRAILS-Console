import Foundation

struct EmailMessage: Codable, Identifiable, Hashable {
    let id: UUID
    let from: String
    let subject: String
    let preview: String
    let appTag: AppTag
    let receivedAt: Date
    var isRead: Bool

    var ageDescription: String {
        let interval = Date().timeIntervalSince(receivedAt)
        let hours = Int(interval / 3_600)
        let days  = Int(interval / 86_400)
        if days  >= 1 { return "\(days)d ago" }
        if hours >= 1 { return "\(hours)h ago" }
        let mins = Int(interval / 60)
        return mins > 0 ? "\(mins)m ago" : "Just now"
    }

    var senderName: String {
        from.components(separatedBy: "@").first?.replacingOccurrences(of: ".", with: " ").capitalized ?? from
    }
}

extension EmailMessage {
    static let mockData: [EmailMessage] = [
        EmailMessage(id: UUID(),
                     from: "jake@bandname.com",
                     subject: "Can't log into Music Trails",
                     preview: "Hi, I've been trying to log in for the past hour but keep getting an error after entering my credentials...",
                     appTag: .musicTrails,
                     receivedAt: Date().addingTimeInterval(-1_800),
                     isRead: false),
        EmailMessage(id: UUID(),
                     from: "manager@studiospace.com",
                     subject: "Studio listing not showing up in search",
                     preview: "We created our studio profile last week but it's not appearing when users search our area...",
                     appTag: .sceneTrails,
                     receivedAt: Date().addingTimeInterval(-3_600 * 3),
                     isRead: false),
        EmailMessage(id: UUID(),
                     from: "maria@creativestudios.io",
                     subject: "Membership upgrade question",
                     preview: "We're interested in upgrading to the pro plan. Can you tell us what the additional features include?",
                     appTag: .sceneTrails,
                     receivedAt: Date().addingTimeInterval(-3_600 * 6),
                     isRead: true),
        EmailMessage(id: UUID(),
                     from: "support@musictrails.online",
                     subject: "New crash report: iOS 17.4 login flow",
                     preview: "Automated crash report from 3 devices running iOS 17.4. Stack trace attached.",
                     appTag: .musicTrails,
                     receivedAt: Date().addingTimeInterval(-3_600 * 9),
                     isRead: true),
    ]
}
