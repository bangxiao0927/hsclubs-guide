# HSclubs Guide Backend-Informed Development Plan

## 1. Planning Basis

This plan is based on a code audit of HSclubs 1st repo commit
`78e4b828688e0ad5a406b0f2b5f770d69c5c5ec1`. The source backend already implements a
public `GET /api/summary`; Guide is not waiting for a new endpoint. It is waiting for
that endpoint to become a tested, versioned, public-only production contract.

The detailed findings are in [1st Repo Backend Audit](FIRST_REPO_BACKEND_AUDIT.md).

## 2. Product Boundary

HSclubs Guide is the public discovery frontend for independent single-school HSclubs
sites. Each 1st repo instance continues to own:

- Club details and search.
- Student login and profile.
- Membership applications and rosters.
- President and administrator workflows.

Guide owns only:

- A verified registry of school sites.
- Collection of validated aggregate summaries.
- School discovery, status, freshness, and canonical outbound links.

Guide must not copy club records, authenticate students, or become a shared multi-tenant
club database.

## 3. Backend Findings That Change the Plan

Previous planning assumed school identity was hardcoded. The audit found that name,
short name, and slug already use `APP_SUMMARY_*` configuration with generic defaults.
The actual work is to validate and document that configuration, not invent another
school model.

The implemented route is `/api/summary`. The conflicting `/api/clubs/summary` proposal
in the issue document is stale. Guide will use only `/api/summary` and must not encourage
parallel routes.

The main blockers are now specific:

1. No schema version or contract-specific tests.
2. `LocalDateTime` has no UTC offset.
3. Active clubs are counted without checking `visibility = 'public'`.
4. Generic school identity can be published silently.
5. `status` is hardcoded and `memberCount` semantics are unclear.
6. No canonical site URL is provided by the source response.
7. No summary test covers anonymous access or absence of private fields.

## 4. Source Summary Contract v1

### Route

```text
GET /api/summary
```

This remains unauthenticated. Guide's private collector calls it server-to-server, so
the 1st repo does not need to add the Guide browser origin to CORS.

### Proposed Response

```json
{
  "schemaVersion": "1.0",
  "schoolName": "Mountain View High School",
  "shortName": "MVHS",
  "slug": "mvhs",
  "canonicalUrl": "https://clubs.example.edu",
  "status": "active",
  "clubCount": 42,
  "categories": {
    "Academic": 12,
    "Arts": 8
  },
  "memberCount": 350,
  "lastUpdatedAt": "2026-07-19T20:15:30Z",
  "generatedAt": "2026-07-19T20:20:00Z",
  "dataHash": "sha256-hex"
}
```

### Field Rules

- `schemaVersion` is required and uses a documented major/minor version.
- Identity and `canonicalUrl` are required, configurable, and validated at startup.
- `slug` is lowercase and matches `^[a-z0-9]+(?:-[a-z0-9]+)*$`.
- `status` is a configured site state, not inferred from one request.
- Counts include only clubs with `status=active` and `visibility=public`.
- `categories` excludes blank categories and contains nonnegative integer values.
- `memberCount` remains optional for Guide publication until its source semantics are
  confirmed. The collector may validate but drop it.
- `lastUpdatedAt` means the newest public active club update. It may be `null` when no
  public club exists.
- `generatedAt` is the UTC time when the response was generated.
- `dataHash` is computed from a canonical representation of source fields that should
  trigger collection changes. Its algorithm and normalization are documented.
- No person-level, contact, advisor, OAuth, membership-request, or admin data is allowed.

### Compatibility Policy

- The current unversioned response is named `legacy-v0` in Guide fixtures.
- A collector adapter may parse `legacy-v0` in local and staging environments only.
- Production publication requires v1 unless a time-limited exception is documented.
- Unknown major versions fail closed and retain the last known good summary.
- Additive unknown fields are ignored; missing or invalid required fields reject the
  collection attempt.

## 5. Authority and Trust Model

The private Guide registry is authoritative for:

- Internal school ID and public Guide slug.
- Verified source endpoint and exact HTTPS hostname/path.
- Canonical school URL, location, ownership contact, and verification state.
- Publication, suspension, and removal decisions.

The source endpoint is authoritative only for validated aggregate club statistics,
source timestamps, and its hash. Source identity is treated as a claim and must match
the registry before publication. URLs returned by a source are never followed by the
collector.

## 6. Technology and Repository Split

### Public `hsclubs-guide` Repository

- Vue 3 Composition API, Vite, and TypeScript.
- Vue Router for list and school detail routes.
- Zod for runtime public API validation.
- Composables first; Pinia only if cross-route state requires it.
- Vitest, Vue Test Utils, MSW, and Playwright.
- Plain CSS with custom properties.
- Cloudflare Pages deployment.

### Private `hsclubs-guide-service` Repository

- TypeScript, Hono, and Cloudflare Workers.
- D1 for the verified registry, last-known-good summaries, and collection attempts.
- Cron Triggers for conservative scheduled polling.
- Zod schemas generated from or checked against the source JSON Schema.
- Cloudflare Access or CLI-only registry mutation for the MVP.

Do not place the verified ownership contacts, operational errors, mutation endpoints,
or collector secrets in the public frontend repository.

## 7. Private Service Data Model

```text
schools
  id, slug, name, short_name
  canonical_url, summary_url, expected_host
  city, region, country
  verification_status, publication_status
  expected_schema_major
  created_at, updated_at

school_summaries
  school_id
  source_schema_version
  club_count, categories_json
  source_updated_at, source_generated_at
  source_data_hash
  last_success_at
  normalized_payload_json

collection_attempts
  id, school_id
  started_at, completed_at
  outcome_code, http_status
  response_bytes, duration_ms
  private_error_detail
```

The public API is produced from an explicit field allowlist. It never serializes D1 rows
or source payloads directly.

## 8. Delivery Tracks

### Track A - 1st Repo Contract Readiness

These tasks are completed in `HSclubs` and block live production collection:

1. Reconcile docs around the single `/api/summary` route.
2. Introduce validated summary configuration and document every environment variable.
3. Filter summary data to public active clubs in a dedicated mapper query.
4. Implement v1 DTO fields and UTC timestamp semantics.
5. Document hash and empty-directory behavior.
6. Add service, serialization, MockMvc authorization, and privacy tests.
7. Update API, issue, execution, and production deployment documentation.
8. Deploy one correctly configured HTTPS reference instance.

Exit gate:

- Anonymous v1 request returns `200` and the reviewed schema.
- Private or inactive clubs do not change counts, categories, timestamps, or hash.
- Production cannot silently publish generic identity.
- The 1st repo test suite and new summary tests pass.

### Track B - Public Frontend Foundation

This track can start immediately with fixtures:

1. Initialize Vue, Vite, TypeScript, Router, linting, and formatting at repo root.
2. Add Zod source/public schemas plus valid and invalid contract fixtures.
3. Configure MSW as the default local data source.
4. Build the application shell, design tokens, and route-level errors.
5. Add CI for lint, type-check, unit tests, Playwright smoke tests, and build.

Exit gate:

- A new maintainer can run and test the frontend without any live endpoint.
- CI proves valid fixtures parse and invalid/private fields are not displayed.

### Track C - Fixture-Driven Discovery MVP

1. Build school list, school card, and `/schools/:slug` detail view.
2. Search normalized full name, short name, and location.
3. Display verified, fresh, stale, unavailable, and suspended states.
4. Add loading, empty, partial-failure, and malformed-response states.
5. Make the registry canonical URL the primary outbound action.
6. Complete 320 px mobile, keyboard, focus, label, and contrast checks.

Exit gate:

- Search-to-school navigation passes Playwright at phone and desktop sizes.
- No UI feature depends on a direct request to a 1st repo instance.

### Track D - Private Collector and Public Directory API

1. Create D1 migrations for the three core tables.
2. Add protected workflows to verify, add, pause, and remove schools.
3. Fetch only a stored, exact, allowlisted HTTPS summary URL.
4. Reject IP-literal hosts, credentials in URLs, nonstandard schemes, redirects, invalid
   content types, oversized responses, timeouts, and schema mismatches.
5. Match claimed identity against the verified registry.
6. Normalize v1 into last-known-good storage in one transaction.
7. Keep failed attempt details private and retain the last successful summary.
8. Expose cacheable `GET /api/v1/schools` and `GET /api/v1/schools/:slug` responses.
9. Add rate limiting, structured logs, health monitoring, and collection alerts.

Exit gate:

- Security tests prove arbitrary URLs and redirects cannot turn collection into an SSRF
  proxy.
- Invalid data never overwrites a valid summary.
- Public responses contain only allowlisted directory fields.

### Track E - Integration, Pilot, and Release

1. Connect staging frontend to the staging directory API.
2. Keep fixtures and MSW for local and CI use.
3. Onboard the audited reference instance through the verification process.
4. Onboard a second independently deployed instance before declaring readiness.
5. Simulate timeout, malformed v1, identity mismatch, and source outage.
6. Pilot school discovery with students and one registry maintainer.
7. Complete CSP, dependency/secret scanning, accessibility, and performance checks.
8. Document correction, suspension, deletion, rollback, and incident procedures.

Exit gate:

- Two verified schools are discoverable and open their canonical sites.
- One source outage does not break the directory or erase last-known-good data.
- Release and rollback checks in `docs/DEPLOYMENT.md` pass.

## 9. Ordered Backlog

| Order | Repository | Work item | Blocks |
|---|---|---|---|
| 1 | 1st repo | Approve `/api/summary` v1 schema and semantics | Live collection |
| 2 | 1st repo | Public-only query and validated site configuration | Live collection |
| 3 | 1st repo | Summary contract, privacy, and anonymous-access tests | Live collection |
| 4 | Guide | Initialize Vue frontend, schemas, fixtures, and CI | Discovery UI |
| 5 | Guide | Build school list, search, cards, and detail route | Pilot UI |
| 6 | Guide | Add all freshness/failure states and accessibility tests | Pilot UI |
| 7 | Private service | Create registry/D1 migrations and protected operations | Collection |
| 8 | Private service | Implement strict v1 fetch, validation, and storage | Collection |
| 9 | Private service | Publish sanitized list/detail API | Integration |
| 10 | Both | Integrate staging and run failure matrix | Pilot |
| 11 | Operations | Verify and onboard two independent school sites | Release |
| 12 | All | Harden, document, release, and verify rollback | Production |

## 10. Test Matrix

### 1st Repo

- Valid configured identity and v1 serialization.
- Empty directory and null source update time.
- Public active club included.
- Private, inactive, and malformed clubs excluded.
- Deterministic hash under query-order changes.
- Anonymous `GET /api/summary` allowed; mutation routes remain protected.
- No identity-level user, member, contact, request, or admin fields.

### Collector

- Valid v1 success and unchanged hash.
- Unknown major version and missing required fields.
- Identity/hostname mismatch.
- Redirect, IP literal, non-HTTPS URL, timeout, oversized body, wrong content type.
- Last-known-good retention after every failure class.
- Public allowlist and private error redaction.

### Frontend

- Contract parsing and defensive fallback.
- Case/whitespace-tolerant search and filters.
- Fresh, stale, unavailable, suspended, empty, and partial-failure rendering.
- Safe canonical outbound links.
- Mobile and desktop browser flow plus keyboard accessibility.

## 11. Definition of Done

Every issue requires:

- Acceptance criteria written before implementation.
- Automated coverage for behavior and risky failure modes.
- CI passing in the affected repository.
- Manual mobile/accessibility smoke checks for visible UI changes.
- Contract and deployment docs updated with behavior changes.
- No secrets or private operational data in this public repository.
- No duplication of school-owned club or user workflows.

## 12. Indicative Schedule

Tracks A and B can run in parallel. The estimate assumes one part-time frontend/service
developer and access to a 1st repo maintainer.

| Week | 1st repo | Guide/service |
|---|---|---|
| 1 | Approve v1, filtering, configuration | Initialize frontend, schemas, fixtures, CI |
| 2 | Implement and test v1 | Build list, cards, search, and detail route |
| 3 | Deploy verified reference endpoint | Finish UI states, mobile, and accessibility |
| 4 | Support integration fixes | Build D1 registry, strict collector, and public API |
| 5 | Verify source behavior | Integrate staging and onboard second school |
| 6 | Close documentation gaps | Pilot, harden, release, monitor, and test rollback |

Do not replace a failed source gate with permissive collector behavior to preserve the
schedule. Use fixtures until the source contract is safe.
