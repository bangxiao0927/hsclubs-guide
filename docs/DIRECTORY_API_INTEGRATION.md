# Directory API Integration

## Client Flow

The iOS app reads only from the sanitized Guide directory service. It does not call an
individual school's `/api/summary` endpoint. The app entry point chooses a data client
through `AppEnvironment`:

1. `USE_FIXTURE_DIRECTORY=true` forces the bundled fixture client.
2. Otherwise the app uses `DIRECTORY_API_BASE_URL` from the process environment.
3. Without an environment override, the generated Info.plist value supplies the target
   deployment origin.

The resulting request is:

```text
GET https://<configured-origin>/api/v1/schools
Accept: application/json
```

## Client Safeguards

- Only HTTPS origins without credentials, query parameters, or fragments are accepted.
- HTTP status must be in the 2xx range and declare JSON content.
- Responses larger than 256 KB are rejected.
- The strict decoder rejects unknown fields, invalid slugs, unsafe canonical URLs, and
  inconsistent club/category counts.
- UI errors expose a generic safe message rather than private backend details.

## Backend Readiness

Live mode requires the private directory service to publish a public response matching
`DirectoryResponse`. The current app placeholder remains
`https://api.guide.example.org` and must be replaced with the reviewed staging or
production origin when that service is ready.

Until then, CI and normal development should use `USE_FIXTURE_DIRECTORY=true`.
