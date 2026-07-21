# Native iOS Foundation

## Scope

This milestone replaces the former Vue frontend with a native SwiftUI iPhone app. It
keeps the same school-discovery boundary and does not connect directly to school-owned
HSclubs instances.

## Acceptance Criteria

- The repository contains a Swift 6 SwiftUI application targeting iPhone on iOS 17 or
  newer.
- A maintainer can generate the project with XcodeGen and run it in an iPhone Simulator.
- Strict contract decoding accepts reviewed fixtures and rejects malformed, insecure, or
  undeclared private fields.
- The app supports fixture-driven school search, cards, details, status, category counts,
  and canonical outbound links.
- Loading, empty search, and safe failure states are accessible with Dynamic Type and
  VoiceOver labels supplied by native controls.
- XCTest unit and UI tests run in CI without a live endpoint or signing identity.

## Project Layout

```text
HSclubsGuide/App          Application entry point
HSclubsGuide/Models       Public contracts and strict decoding
HSclubsGuide/Services     Fixture client and discovery state
HSclubsGuide/Views        SwiftUI discovery interface
HSclubsGuide/Resources    Asset catalog and contract fixtures
HSclubsGuideTests         Contract and state unit tests
HSclubsGuideUITests       Simulator discovery flow tests
project.yml               XcodeGen source of project structure
```

## Fixture Policy

The bundled source and directory fixtures represent proposed contracts only. They do not
indicate that the backend readiness gate has passed. Production API integration must use
the sanitized private directory service, never an individual school's `/api/summary`
endpoint.

The decoder rejects unknown keys rather than relying on Codable's default behavior of
silently ignoring them. Canonical links must use HTTPS and cannot contain credentials.

## Local Tooling

After changing targets, resources, or build settings, regenerate the project and review
the resulting project file:

```bash
xcodegen generate
git diff -- HSclubsGuide.xcodeproj
```

No API key, signing certificate, Apple account, or collector secret belongs in this
repository.
