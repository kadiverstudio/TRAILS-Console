# TRAILS Admin Console

## What this is
Native macOS SwiftUI application (minimum macOS 14 Sonoma).
Admin console for two self-hosted mobile apps running on Dell R630/R730
servers via Proxmox VMs. No Azure — everything is on-prem.

---

## The two apps

### Music Trails
Musician networking app — iOS + Android via Ionic/React/Capacitor 8.

| Thing | Value |
|---|---|
| API (prod) | `https://api.musictrails.app` |
| Web portal | `https://musictrails.online` (Next.js) |
| App / deep links | `https://musictrails.app` |
| Auth server | `https://auth.musictrails.online` (FusionAuth) |
| Media / CDN | `https://media.musictrails.online` (MinIO) |
| SignalR hub | `https://api.musictrails.app/hubs/messages` |
| DB host (LAN) | `10.0.0.178:5432` (PostgreSQL) |
| MinIO host (LAN) | `10.0.0.170:9000` |

### Scene Trails
Venue and studio networking app — iOS + Android, same Ionic/Capacitor stack.

| Thing | Value |
|---|---|
| API (prod) | `https://api.scenetrails.app` |
| Auth server | `https://auth.scenetrails.online` (FusionAuth) |
| Web portal | `https://scenetrails.online` (Vite) |
| App / deep links | `https://scenetrails.app` |

---

## Infrastructure (on-prem, no Azure)

| Node | Role |
|---|---|
| Dell R730 | Primary VM host (Proxmox) — runs APIs, PostgreSQL, MinIO, NGINX |
| Dell R630 | Secondary VM host (Proxmox) — overflow, staging, backups |
| Mac mini | Monitoring node — Grafana + Prometheus scraping both servers |

**Services running on VMs:**
- NGINX — reverse proxy for both APIs and web portals
- PostgreSQL — separate DBs for Music Trails and Scene Trails
- MinIO — S3-compatible object storage for media
- FusionAuth — auth/identity for both apps (two separate tenants)
- Docker — all .NET API services containerised
- Uptime Kuma — uptime monitoring (already running)
- Grafana — metrics dashboards (on Mac mini)

**Secrets are in environment variables / `.env` files on the servers.**
Never hardcode credentials in source. Never commit `.env` files.

---

## TRAILS console — what it monitors and manages

### Quick actions (open in browser or SSH)
- SSH into MacMINI-OBS and each production VM
- Open Grafana (Mac mini)
- Open Prometheus targets
- Open Uptime Kuma
- Open Stripe dashboard
- Open GitHub
- Open App Store Connect
- Open Google Play Console

### Overview dashboard
- Music Trails: active user count, open issues, last deploy
- Scene Trails: active user count, open issues, last deploy
- Server health: R730 + R630 metrics from Grafana/Prometheus
- Unread support emails

### App management (per app: Music Trails + Scene Trails)
- Issue tracker (bugs, crash reports, support tickets)
- Deploy history
- Stripe subscription stats

### Infrastructure
- Grafana dashboard embed (WKWebView — Mac mini Grafana URL)
- R730 / R630 server metrics (CPU, RAM, disk, uptime via Prometheus API)
- NGINX error log tail
- Docker container status

### Communications
- Unified inbox for all support email addresses
- Venue outreach (Music Trails)
- Studio memberships (Scene Trails)

---

## Tech stack — TRAILS console itself

- Swift 5.9 + SwiftUI, macOS 14.0 minimum
- Architecture: MVVM with `@Observable` (Swift 5.9 macro, not ObservableObject)
- Networking: `URLSession` + `async/await`, no third-party HTTP libraries
- Auth for TRAILS console itself: local keychain token (admin-only app, no public auth)
- No CoreData / SwiftData — all data fetched live from APIs and Prometheus

---

## Naming conventions

| Type | Pattern |
|---|---|
| Views | `OverviewView.swift`, `IssueListView.swift` |
| ViewModels | `OverviewViewModel.swift` |
| Models | `Issue.swift`, `ServerMetric.swift` |
| Services | `IssueService.swift`, `InfraService.swift` |
| Shared | `APIClient.swift`, `PrometheusClient.swift` |

---

## Project folder structure

```
TRAILS/
  App/
    TRAILSApp.swift          — @main, window config
    SidebarView.swift        — NavigationSplitView sidebar
    SidebarItem.swift        — SidebarItem enum + SidebarSection
    ContentView.swift        — NavigationSplitView root
    AppState.swift           — global @Observable state
    AppConfig.swift          — Config.plist loader
  Features/
    Overview/
      OverviewView.swift
      OverviewViewModel.swift
    MusicTrails/
      IssueListView.swift
      CrashReportView.swift
      SupportView.swift
      DeployHistoryView.swift
    SceneTrails/             — mirrors MusicTrails/
    Infrastructure/
      GrafanaView.swift      — WKWebView embed
      ServerListView.swift
      InfrastructureView.swift
      DockerStatusView.swift
      NGINXLogsView.swift
    Communications/
      InboxView.swift
      VenueOutreachView.swift
      StudioMembershipsView.swift
    QuickActions/
      QuickActionsView.swift — SSH, Grafana, Stripe, GitHub, stores
  Core/
    Models/
      Issue.swift
      ServerMetric.swift
      EmailMessage.swift
      DeployEvent.swift
      DockerContainer.swift
    Network/
      APIClient.swift        — hits Music Trails + Scene Trails APIs
      PrometheusClient.swift — hits Mac mini Prometheus for server metrics
      GrafanaClient.swift    — Grafana HTTP API for panel data
    Services/
      IssueService.swift
      InfraService.swift
      EmailService.swift
      DeployService.swift
  Resources/
    Assets.xcassets/
    Config.plist             — all URLs and endpoints, no secrets
```

---

## Config.plist keys (no secrets in source)

```xml
MusicTrailsAPIURL       = https://api.musictrails.app
SceneTrailsAPIURL       = https://api.scenetrails.app
GrafanaURL              = http://10.0.0.40:3000
PrometheusURL           = http://100.108.162.41:9091
UptimeKumaURL           = http://10.0.0.40:3001
R730SSHHost             = r730.local
R630SSHHost             = r630.local
```

Quick Actions also includes SSH targets for:
`ianmclean@10.0.0.40`, `edge@10.0.0.175`, `trails_db@10.0.0.182`,
`web-auth@10.0.0.183`, `music_api@10.0.0.177`, `scene_api@10.0.0.185`,
`trails_media@10.0.0.178`, `redis@10.0.0.179`, `backup_mgmt@10.0.0.180`,
and `admin_tools@10.0.0.181`.

Sensitive values (API tokens, SSH keys, SSH passwords) go in macOS Keychain only.

---

## Key SwiftUI patterns

- `NavigationSplitView` for sidebar/content layout (`.balanced` style)
- `@Observable` for all view models
- `.task {}` modifier for async data loading on view appear
- `GroupBox` for native macOS card containers
- `List` with `Section` for sidebar nav groups
- `WKWebView` wrapped in `NSViewRepresentable` for Grafana embed
- `@AppStorage` for user preferences (selected theme, refresh interval)
