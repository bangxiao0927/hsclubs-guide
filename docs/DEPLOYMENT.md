# HSclubs Guide iOS Distribution Guide

## 1. Distribution Target

HSclubs Guide is a native iPhone application distributed through TestFlight and,
following pilot approval, the Apple App Store. The app target supports iOS 17 and newer.

The private collector and sanitized public directory API remain separate from this
repository. The app must never collect directly from a school-owned endpoint.

## 2. Environments

| Environment | App data | Distribution |
|---|---|---|
| Local | Bundled fixtures or an approved HTTPS directory API | Xcode Simulator |
| CI | Bundled contract fixtures | GitHub-hosted Simulator |
| Internal pilot | Staging directory API after readiness | TestFlight internal testing |
| Production | Production sanitized directory API | App Store |

Fixture mode remains the only enabled mode until the readiness gate in
`docs/DEVELOPMENT_PLAN.md` passes.

## 3. Local Development

Prerequisites:

1. Install the full Xcode application and accept its license.
2. Select Xcode with `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.
3. Install XcodeGen with `brew install xcodegen`.
4. Run `xcodegen generate` after changing `project.yml`.

Open `HSclubsGuide.xcodeproj`, select an iPhone Simulator, and run the `HSclubsGuide`
scheme. No Apple Developer account is required for Simulator builds.

The app resolves the directory endpoint from `DIRECTORY_API_BASE_URL`. A value in the
generated Info.plist supplies the placeholder deployment origin; an environment variable
overrides it in Xcode run settings. The endpoint must be HTTPS without credentials,
query, or fragment. Set `USE_FIXTURE_DIRECTORY=true` to force bundled fixture mode.

Command-line validation:

```bash
xcodegen generate
xcodebuild test \
  -project HSclubsGuide.xcodeproj \
  -scheme HSclubsGuide \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  CODE_SIGNING_ALLOWED=NO
```

## 4. CI Requirements

Every pull request and `main` push must:

1. Regenerate the Xcode project and prove the committed project is current.
2. Build the iOS application for an iPhone Simulator.
3. Run contract, state, and discovery UI tests.
4. Upload the `.xcresult` bundle when tests fail.
5. Run dependency and secret scanning when third-party packages are introduced.

CI uses fixtures and must not call a school endpoint or production API.

## 5. Signing Setup

Signing is not needed for local Simulator or CI runs. Before TestFlight distribution:

1. Enroll the release owner in the Apple Developer Program.
2. Register the final bundle identifier; replace the placeholder `org.hsclubs.guide` if
   it is unavailable.
3. Create the App Store Connect application record.
4. Configure automatic signing for the release team outside committed files.
5. Store App Store Connect API credentials only in the protected CI secret store.

Never commit provisioning profiles, signing certificates, private keys, issuer IDs, or
API keys.

## 6. TestFlight Promotion

1. Confirm the source contract readiness gate has passed before enabling staging data.
2. Archive a Release build with the approved bundle identifier and version.
3. Upload through Xcode or an authenticated CI workflow.
4. Complete export compliance, privacy nutrition labels, and beta review information.
5. Release first to internal testers, then to a limited external school pilot.
6. Verify search, detail navigation, unavailable states, and outbound links on a physical
   iPhone before promotion.

## 7. App Store Release Gate

- Two independently deployed and verified schools are discoverable.
- No person-level or private operational field is present in app responses or telemetry.
- Contract, unit, UI, accessibility, and privacy tests pass.
- App icon, screenshots, support URL, privacy policy, and age rating are complete.
- Dynamic Type, VoiceOver, reduced motion, dark mode, and 320-point layouts are checked.
- API outage behavior retains or safely replaces last-known-good data.
- Monitoring, correction, suspension, deletion, and incident owners are documented.

## 8. Rollback and Incident Flow

App Store binaries cannot be rolled back instantly. For incidents:

1. Suspend affected school records in the private service without deleting valid data.
2. Disable unsafe API behavior server-side while preserving the public allowlist.
3. Stop a phased App Store release or expire an affected TestFlight build.
4. Submit a fixed build with an incremented build number.
5. Rotate exposed credentials and document impact, timeline, and prevention.

The app must fail closed on malformed data and must never bypass contract validation to
restore availability.
