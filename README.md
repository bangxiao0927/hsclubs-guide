# HSclubs Guide for iOS

HSclubs Guide is a native iPhone app for discovering verified, independent school-owned
HSclubs sites. Students search for their school, review public aggregate information,
and open the school's canonical club directory.

The app does not own clubs, memberships, applications, user accounts, or school
administration.

## Status

The native SwiftUI foundation and fixture-driven discovery flow are implemented. Live
integration remains blocked on the source summary readiness gate in
`docs/DEVELOPMENT_PLAN.md`. Until that gate passes, the app loads bundled contract
fixtures and makes no request to an individual school instance.

## Requirements

- macOS with Xcode 16 or newer.
- iOS 17 or newer for the app target.
- XcodeGen 2.46 or newer when changing `project.yml`.

## Run the App

1. Accept the local Xcode license and select the full Xcode installation if needed.
2. Open `HSclubsGuide.xcodeproj`.
3. Select the `HSclubsGuide` scheme and an iPhone Simulator.
4. Run with `Command-R`.

Command-line build and tests:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild test \
  -project HSclubsGuide.xcodeproj \
  -scheme HSclubsGuide \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  CODE_SIGNING_ALLOWED=NO
```

Regenerate the committed project after changing `project.yml`:

```bash
xcodegen generate
```

## Architecture

- Swift 6 and SwiftUI application lifecycle.
- `NavigationStack` discovery and school detail flow.
- Strict Foundation-based JSON contract validation.
- Bundled fixtures as the default and only data source until API readiness.
- XCTest unit and UI coverage.
- XcodeGen for deterministic project generation.

## Documentation

- [Development plan](docs/DEVELOPMENT_PLAN.md)
- [iOS foundation](docs/IOS_FOUNDATION.md)
- [1st repo backend audit](docs/FIRST_REPO_BACKEND_AUDIT.md)
- [Distribution guide](docs/DEPLOYMENT.md)

## Project Rules

- School sites remain independent and own all club and user data.
- Never collect or expose student, member, president, or administrator identity data.
- Keep private collector code, credentials, and operational metadata out of this public
  repository.
- Keep all project documentation and user-facing copy in English.
