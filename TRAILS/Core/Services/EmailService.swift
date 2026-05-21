import SwiftUI

// Connects to Microsoft 365 via Graph API.
// Token is stored in Keychain under "trails.graph.token" — never in source.
@Observable
@MainActor
final class EmailService {
    var messages: [EmailMessage] = EmailMessage.mockData
    var isLoading = false
    var lastError: String?

    var unreadCount: Int { messages.filter { !$0.isRead }.count }

    func refresh() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        guard let token = graphToken() else {
            lastError = "No Graph API token found in Keychain. Add one under key 'trails.graph.token'."
            return
        }

        do {
            messages = try await fetchInbox(token: token)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func markRead(_ message: EmailMessage) async {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[index].isRead = true

        // Fire-and-forget patch to Graph API
        Task {
            guard let token = graphToken() else { return }
            await patchReadStatus(messageId: message.id.uuidString, token: token)
        }
    }

    // MARK: - Graph API

    private let graphBase = URL(string: "https://graph.microsoft.com/v1.0")!

    private func fetchInbox(token: String) async throws -> [EmailMessage] {
        let url = graphBase.appendingPathComponent("/me/messages")
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "$select", value: "id,from,subject,bodyPreview,isRead,receivedDateTime"),
            URLQueryItem(name: "$top",    value: "50"),
            URLQueryItem(name: "$orderby",value: "receivedDateTime desc"),
        ]

        var request = URLRequest(url: comps.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let envelope = try JSONDecoder().decode(GraphEnvelope.self, from: data)
        return envelope.value.compactMap { EmailMessage(from: $0) }
    }

    private func patchReadStatus(messageId: String, token: String) async {
        let url = graphBase.appendingPathComponent("/me/messages/\(messageId)")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["isRead": true])
        _ = try? await URLSession.shared.data(for: request)
    }

    private func graphToken() -> String? {
        let key = "trails.graph.token" as CFString
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Graph response shapes

private struct GraphEnvelope: Decodable {
    let value: [GraphMessage]
}

private struct GraphMessage: Decodable {
    let id: String
    let subject: String?
    let bodyPreview: String?
    let isRead: Bool
    let receivedDateTime: String
    let from: GraphSender?
}

private struct GraphSender: Decodable {
    let emailAddress: GraphEmail
}

private struct GraphEmail: Decodable {
    let address: String
}

private extension EmailMessage {
    init?(from g: GraphMessage) {
        guard let address = g.from?.emailAddress.address else { return nil }
        let iso = ISO8601DateFormatter()
        let date = iso.date(from: g.receivedDateTime) ?? Date()
        let tag: AppTag = address.contains("scenetrails") ? .sceneTrails : .musicTrails
        self.init(
            id: UUID(),
            from: address,
            subject: g.subject ?? "(no subject)",
            preview: g.bodyPreview ?? "",
            appTag: tag,
            receivedAt: date,
            isRead: g.isRead
        )
    }
}
