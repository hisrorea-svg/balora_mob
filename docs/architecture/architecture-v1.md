# Balora Mobile Companion - Architecture v1.0

## Overview
The app follows a **Feature-First Clean Architecture** utilizing **Pragmatic CQRS**, **Optimistic UI**, **Repository Pattern**, and a **Prioritized Offline-First Sync Queue**. 

**Golden Rule:** The mobile application is a "Dumb Client". It does not enforce complex business rules. `Balora Desktop` is the Single Source of Truth for all business logic.

## Directory Structure Highlights
```text
/
├── docs/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── design_system/
│   ├── shared/
│   ├── core/
│   │   ├── api/
│   │   ├── result/
│   │   ├── errors/
│   │   ├── event_bus/
│   │   ├── plugins/
│   │   ├── sync/
│   │   └── services/
│   └── features/
│       ├── scanner/        
│       ├── products/
│       ├── authentication/
│       ├── inventory/
│       └── settings/
├── test/
├── Makefile
├── analysis_options.yaml
└── pubspec.yaml
```

## Non-Functional Requirements (NFRs)
1. **Scanning Throughput:** Support 300 continuous scans without UI freezing.
2. **Camera Initialization:** < 1 second.
3. **Decode Speed:** < 200ms in good lighting conditions.
4. **Resiliency:** Auto-recover session and WebSocket connection after Wi-Fi drop.
5. **Data Integrity:** Zero data loss for any operation that enters the Queue.
6. **Battery Efficiency:** Optimized CPU usage.
7. **Responsiveness:** Flawless adaptation to different screens.

## Execution Order (Engine-First Strategy)
1. Project Creation & Infrastructure (docs, directories, linting).
2. Protocol Definition (REST & WebSocket protocols).
3. Desktop Mock Server.
4. Queue & Sync Engine.
5. Desktop Integration Testing.
6. Pairing Feature.
7. Scanner Feature.
8. Products Feature.
9. Inventory Feature.
10. Settings & Polish.
11. Testing.
