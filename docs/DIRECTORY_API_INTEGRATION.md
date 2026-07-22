# Directory API Integration

## Current Client Flow

The iOS app currently performs no backend requests. `AppEnvironment` always selects the
bundled `FixtureDirectoryClient`, so local, CI, and release builds all use the reviewed
JSON fixtures included with the app.

There is no backend base URL in the generated Info.plist and no live networking client in
the application target. The app also never calls an individual school's `/api/summary`
endpoint.

## Reserved Future Contract

When backend integration is explicitly approved, the private Guide directory service is
expected to expose:

```text
GET https://<configured-origin>/api/v1/schools
Accept: application/json
```

This route is documentation only and is not called by the current app.

## Future Client Safeguards

- Only HTTPS origins without credentials, query parameters, or fragments are accepted.
- HTTP status must be in the 2xx range and declare JSON content.
- Responses larger than 256 KB are rejected.
- The strict decoder rejects unknown fields, invalid slugs, unsafe canonical URLs, and
  inconsistent club/category counts.
- UI errors expose a generic safe message rather than private backend details.

## Backend Readiness

Live integration requires the private directory service to publish a public response
matching `DirectoryResponse` and pass the readiness gate. Until the user explicitly
requests that integration, the endpoint, environment selection, and network transport
must remain absent from the app.
