# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wind Power Monitoring System (风电监控系统) — a desktop Flutter application for real-time monitoring and control of wind turbine de-icing systems. Targets Windows, macOS, and Linux.

## Common Commands

```bash
# Run the app (desktop)
flutter run -d macos    # or -d windows, -d linux

# Build
flutter build macos     # or windows, linux

# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test
flutter test test/specific_test.dart

# Generate Drift database code
dart run build_runner build
```

## Architecture

### Navigation & Shell

- `main.dart` — App entry, window setup (1920x1280 default), Material theme, localization (zh_CN/en_US)
- `page/main_shell_page.dart` — Two-layer shell: fixed header (`GlobalHeader`) + `ContentNavigator`
- `content_navigator.dart` — Custom Navigator with named routes: `/home`, `/detail`, `/history`, `/real_time`

### Networking (TCP-first)

The app communicates with devices primarily over **direct TCP sockets**, not REST APIs.

- `network/socket/web_socket_manager.dart` — Singleton managing up to 100 device TCP connections with LRU eviction. Broadcasts device messages via `devicePushStream`.
- `network/socket/device_connection.dart` — Per-device TCP socket handling: JSON-line protocol, request/response correlation via `cmd` field, heartbeat, auto-reconnect, TCP packet reassembly.
- `network/http/api_util.dart` — Static API methods wrapping TCP commands (polling, device detail, emergency stop, reset, heating control, mode switch, clock sync). All requests logged to `request_log.txt`.
- `core/network/base_http_request.dart` — Dio-based HTTP client (callback pattern with `successCallback`/`failCallback`, not futures).

### Database (SQLite via Drift)

- `db/app_database.dart` — Singleton database. Stores to `Documents/window_app.db`.
- Three table groups:
  - **Devices** — PK: `sn`, stores IP/port/deviceSn for each turbine
  - **Users** — PK: `username`, role-based auth with default admin
  - **History (monthly partitioned)** — Tables named `history_YYYY_MM`, composite key `(sn, recordTime)`. Stores electrical/temperature/fault/blade data plus full JSON payload. Cross-month range queries handled automatically.
- Run `dart run build_runner build` after modifying `db/table/` definitions.

### Data Model

- `model/DeviceDetailData.dart` — Core composite model with three sub-objects:
  - **State** — electrical (currents/voltages), environmental, heating, wind, device status
  - **Fault** — error flags (ring, UPS, contactor, per-blade faults)
  - **Winddata** — per-blade temperature/thickness/motion for 3 blades

### State Management

Uses Flutter's built-in `StatefulWidget` + `setState()`. No external state management framework. Real-time updates come through `StreamSubscription` on `WebSocketManager.devicePushStream`. Timer-based polling for device status refresh.

### Global Singletons

- `WebSocketManager` — TCP connection pool
- `AppDatabase` — Database access
- `AppConstant.shared` — Screen metrics and context
- `UserInfo` — Current logged-in user

### Key Directories

- `core/` — Config, constants, extensions, HTTP base, styles, encryption, utilities
- `db/` — Drift table definitions and database operations
- `genernal/` — Extension helpers (String, Text, Double, EdgeInsets) — note: directory name is intentionally `genernal`
- `model/` — Data transfer objects
- `network/` — TCP socket management and API commands
- `page/` — Screen widgets and dialog components
- `view/` — Reusable UI components (header, charts, dialogs)
- `utils/` — Application utilities

### Key Libraries

- **dio** — HTTP client (callback-based, not async/await)
- **drift** + **sqflite_common_ffi** — Type-safe SQLite ORM for desktop
- **syncfusion_flutter_charts** — Real-time charting
- **pluto_grid** — Data tables
- **window_manager** — Desktop window control
- **flutter_secure_storage** — Encrypted credential storage (with JSON file fallback)
- **excel** / **pdf** + **printing** — Data export
