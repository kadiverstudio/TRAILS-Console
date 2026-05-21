import SwiftUI

// Scene Trails reuses the shared IssueListView parameterized with .sceneTrails.
struct SceneTrailsIssueListView: View {
    var body: some View { IssueListView(app: .sceneTrails) }
}
