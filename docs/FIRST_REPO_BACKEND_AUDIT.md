# 1st Repo Backend Audit

## Audit Snapshot

- Repository: `bangxiao0927/HSclubs`
- Audited commit: `78e4b828688e0ad5a406b0f2b5f770d69c5c5ec1`
- Commit date: 2026-07-11
- Audit focus: the backend contract and operational readiness needed by HSclubs Guide
- Verification: `backend/mvnw test` completed successfully with 10 tests

This document records code behavior at the audited commit. Planning should be updated
when the source backend changes.

## Implemented Backend Baseline

The 1st repo is a Spring Boot 4.0.1 and Java 17 application using MyBatis 4.0.0. It uses
MySQL in normal development and H2 in tests. The backend includes OAuth2 login, club
management, local uploads, Instagram avatar caching, and a public summary package.

The summary implementation already has three dedicated classes:

- `backend/src/main/java/com/example/demo/summary/controller/SummaryController.java`
- `backend/src/main/java/com/example/demo/summary/model/SummaryResponse.java`
- `backend/src/main/java/com/example/demo/summary/service/SummaryService.java`

`GET /api/summary` is explicitly public in `SecurityConfig`. No browser CORS access is
required for Guide collection because the private collector calls this endpoint
server-to-server.

## Current Summary Contract

The endpoint currently returns:

```json
{
  "schoolName": "HS Clubs",
  "shortName": "HS Clubs",
  "slug": "hsclubs",
  "status": "active",
  "clubCount": 42,
  "categories": {
    "Academic": 12
  },
  "memberCount": 350,
  "lastUpdatedAt": "2026-07-01T12:00:00",
  "dataHash": "sha256-hex"
}
```

Observed behavior:

- The route implemented in code, security configuration, and `docs/API.md` is
  `GET /api/summary`.
- `docs/ISSUES.md` still proposes `/api/clubs/summary`; that is stale and must not create
  a second route.
- School name, short name, and slug are configurable through `APP_SUMMARY_SCHOOL_NAME`,
  `APP_SUMMARY_SHORT_NAME`, and `APP_SUMMARY_SLUG` in `application.yaml`.
- Generic defaults remain enabled, and the variables are not documented in
  `backend/.env.example` or the production checklist.
- `status` is always the literal `active`.
- The service calls `ClubMapper.findAll()`, which filters `status = 'active'` but does
  not filter `visibility = 'public'`.
- `memberCount` is the sum of denormalized `clubs.member_count`, not a live count from
  `club_member`.
- `lastUpdatedAt` is the maximum club `updated_at`; it is `null` for an empty directory.
- The timestamp uses `LocalDateTime`, so the response does not identify a timezone or
  UTC offset.
- The hash sorts by database ID and hashes ID, name, category, and member count.
- There are no cache headers, ETag behavior, schema version, canonical site URL, or
  generated-at timestamp in the response.

## Test and Documentation Findings

The backend test suite passes, but none of the 10 tests exercises `SummaryController`,
`SummaryService`, summary serialization, public endpoint authorization, or privacy.
Current test coverage is concentrated on application startup, OAuth mapping and
serialization, and Instagram avatar caching.

The planning documents correctly require summary privacy tests before starting the 2nd
repo. The issue tracker, however, understates the current implementation and conflicts
with the actual route. Documentation needs to be reconciled with code before Guide uses
the endpoint as a stable source contract.

## Blocking Gaps for Live Guide Collection

### P0 - Contract Correctness

1. Declare `GET /api/summary` as the only source summary route.
2. Add a `schemaVersion` field and publish a JSON example or JSON Schema.
3. Add `canonicalUrl` or make the verified collector registry explicitly authoritative
   for canonical URLs.
4. Replace ambiguous `LocalDateTime` output with an ISO-8601 UTC instant.
5. Define empty-directory behavior and the meaning of `lastUpdatedAt`.
6. Define whether `memberCount` is maintained data or a live membership count.

### P0 - Privacy and Data Selection

1. Aggregate only clubs where `status = 'active'` and `visibility = 'public'`.
2. Keep all user, member, president, advisor, contact, request, and admin identity fields
   out of the summary response.
3. Decide whether aggregate `memberCount` is necessary for the Guide MVP. The collector
   should drop it if the public frontend does not use it.

### P0 - Configuration Safety

1. Document all `APP_SUMMARY_*` variables in `.env.example` and deployment docs.
2. Validate a nonblank school name, short name, slug, and canonical URL at startup.
3. Avoid silently publishing generic identity in production.
4. Add a configurable site status or remove the hardcoded status claim.

### P0 - Verification

1. Unit-test category counts, member counts, timestamps, empty data, and hash stability.
2. Integration-test the exact JSON contract and anonymous `200` response.
3. Verify inactive and non-public clubs do not affect any public summary field or hash.
4. Add an explicit test that no private identity fields are serialized.
5. Update `docs/API.md`, `docs/ISSUES.md`, execution criteria, and production checklist.

## Non-blocking Improvements

- Return `Cache-Control` and an ETag derived from `dataHash` to reduce unchanged polling.
- Compute the hash from a documented canonical representation rather than database IDs.
- Remove duplicate Spring MVC dependencies and production SQL/MyBatis debug logging as
  general backend maintenance; these do not block contract fixtures.
- Add a health endpoint only if operations need it. The collector should not infer
  summary validity from a generic health check.

## Integration Decision

The collector registry, not an untrusted source payload, is authoritative for:

- Guide school ID and slug.
- Verified canonical and summary URLs.
- Location and ownership verification.
- Publication, suspension, and removal state.

The source summary is authoritative only for validated aggregate directory statistics
and source update/hash values. A claimed source identity must match the expected
registry record before a collection can be published.

Guide frontend development can continue with fixtures immediately. Production
collection remains blocked until the P0 source contract, privacy, configuration, and
verification items pass.
