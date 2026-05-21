import SwiftUI

enum ContainerState: String, Codable {
    case running, stopped, restarting, exited

    var color: Color {
        switch self {
        case .running:    .green
        case .restarting: .orange
        case .stopped:    .secondary
        case .exited:     .red
        }
    }

    var label: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .running:    "circle.fill"
        case .restarting: "arrow.clockwise.circle.fill"
        case .stopped:    "stop.circle.fill"
        case .exited:     "xmark.circle.fill"
        }
    }
}

struct DockerContainer: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let image: String
    let state: ContainerState
    let uptime: String
    let server: String
}

extension DockerContainer {
    static let mockData: [DockerContainer] = [
        DockerContainer(id: "mt-api",       name: "musictrails-api",   image: "musictrails/api:1.4.2",  state: .running,    uptime: "4 days",    server: "R730"),
        DockerContainer(id: "st-api",       name: "scenetrails-api",   image: "scenetrails/api:2.1.0",  state: .running,    uptime: "1 day",     server: "R730"),
        DockerContainer(id: "postgres-mt",  name: "postgres-mt",       image: "postgres:16",            state: .running,    uptime: "12 days",   server: "R730"),
        DockerContainer(id: "postgres-st",  name: "postgres-st",       image: "postgres:16",            state: .running,    uptime: "12 days",   server: "R730"),
        DockerContainer(id: "minio",        name: "minio",             image: "minio/minio:latest",     state: .running,    uptime: "12 days",   server: "R730"),
        DockerContainer(id: "fusionauth-mt",name: "fusionauth-mt",     image: "fusionauth/fusionauth-app:1.50.0", state: .running, uptime: "5 days", server: "R730"),
        DockerContainer(id: "fusionauth-st",name: "fusionauth-st",     image: "fusionauth/fusionauth-app:1.50.0", state: .running, uptime: "5 days", server: "R730"),
        DockerContainer(id: "nginx",        name: "nginx",             image: "nginx:alpine",           state: .running,    uptime: "12 days",   server: "R730"),
        DockerContainer(id: "mt-portal",    name: "musictrails-portal",image: "musictrails/portal:latest", state: .running, uptime: "2 days",   server: "R630"),
        DockerContainer(id: "st-portal",    name: "scenetrails-portal",image: "scenetrails/portal:latest", state: .running, uptime: "1 day",    server: "R630"),
        DockerContainer(id: "uptime-kuma",  name: "uptime-kuma",       image: "louislam/uptime-kuma:1", state: .running,    uptime: "12 days",   server: "R630"),
    ]
}
