# HSclubs Guide Development Plan

## 1. Product Boundary

The reference project defines this product as the second of three possible repositories:

1. A public single-school site owns club browsing, applications, memberships, and administration.
2. A discovery product lists verified, independent school sites and their public summaries.
3. A mobile entry point may be considered only after the responsive web workflow succeeds.

This repository is the public frontend for item 2. It must link to school-owned sites
rather than copying their club-management features or private data.

## 2. Readiness Review

The current repository contains no application code. The reference repository already
documents and implements a prototype `GET /api/summary`, but its planning documents
still mark that work as partial because the school identity is hardcoded and two routes
are mentioned (`/api/summary` and `/api/clubs/summary`).

Live collection must wait until the reference project resolves the route and meets this gate:

- School name, short name, slug, canonical URL, and status are configurable.
- The payload has a versioned, documented schema and UTC timestamps.
- `dataHash` is deterministic and its inputs are documented.
- The endpoint returns no user identities, rosters, applications, or admin data.
- Contract, hash, and privacy tests pass.
- A production HTTPS endpoint and ownership verification process exist.

Frontend implementation does not need to wait. It should use committed fixtures that
match the proposed contract.

## 3. MVP Outcome

A student should be able to open the guide, find a school by full name, abbreviation,
or location, understand whether its directory is current and available, and open the
canonical school site in less than one minute.

The MVP includes:

- Landing and school search pages.
- School cards and a stable school detail route.
- Name, short-name, and optional location filtering.
- Verified, fresh, stale, unavailable, and suspended states.
- Club and category counts from sanitized summaries.
- Safe external navigation to the canonical school site.
- Responsive and accessible loading, empty, and partial-failure states.

The MVP excludes:

- Shared authentication and student profiles.
- Club lists, applications, memberships, rosters, and admin tools.
- Ratings, comments, recommendations, feeds, maps, and native apps.
- Automatic crawling or public submission of arbitrary URLs.

## 4. Technology Choice

### Public Frontend in This Repository

| Area | Choice | Reason |
|---|---|---|
| Language | TypeScript | Strong API contracts and consistency across the product |
| Framework | Vue 3 Composition API | Matches the reference project and existing team experience |
| Build | Vite | Fast local development and static production output |
| Routing | Vue Router | Stable list and school-detail URLs |
| State | Composables first; Pinia only for shared state | Avoid unnecessary global state |
| Validation | Zod | Reject malformed collector responses at runtime |
| Unit tests | Vitest + Vue Test Utils | Matches the Vue/Vite toolchain |
| API mocks | MSW | Same behavior in local development and tests |
| Browser tests | Playwright | Covers search, mobile layout, links, and failure states |
| Styling | Plain CSS with custom properties | Small bundle and maintainable theme tokens |
| Package manager | npm with committed lockfile | Matches the reference repository |

### Private Collector/API in a Separate Private Repository

| Area | Choice | Reason |
|---|---|---|
| Runtime | Cloudflare Workers | No server maintenance and inexpensive scheduled work |
| Language/API | TypeScript + Hono | Small typed HTTP and scheduled-worker surface |
| Storage | Cloudflare D1 | Enough for a verified registry and cached summaries |
| Scheduling | Cron Triggers | Polling without a long-running process |
| Validation | Zod | Shared schema package or generated JSON Schema |
| Migrations | Wrangler D1 migrations | Repeatable staging and production changes |
| Tests | Vitest + Miniflare/Workers test pool | Local worker and storage coverage |

The collector does not need Spring Boot, OAuth, or MySQL because it has no student
workflow. A TypeScript serverless backend is cheaper to operate and lets the small team
use one language. If Cloudflare cannot be used, the fallback is a small Spring Boot
scheduled service with PostgreSQL/MySQL, but two backend stacks should not be built.

## 5. Repository and Deployment Boundary

```text
hsclubs-guide (public)
  Vue frontend
  public API types and JSON Schema
  fixtures
  frontend tests
  Cloudflare Pages workflow/config

hsclubs-guide-service (private)
  verified source registry
  collector and scheduler
  D1 migrations
  private operational endpoints and alerts
  sanitized GET /api/v1/schools API
  Cloudflare Worker deployment config
```

The public frontend never receives collector credentials or source-management APIs.
The private service may expose public read endpoints, but its registry mutation and
operational routes remain protected by Cloudflare Access or are CLI-only in the MVP.

## 6. Proposed Frontend Structure

```text
src/
  app/
    router.ts
  assets/
  components/
    AppHeader.vue
    SchoolCard.vue
    SchoolStatusBadge.vue
    SearchFilters.vue
  composables/
    useSchoolSearch.ts
  contracts/
    school.ts
  data/
    fixtures/
  layouts/
    DefaultLayout.vue
  services/
    directoryApi.ts
  styles/
    tokens.css
    base.css
  views/
    HomeView.vue
    SchoolDetailView.vue
    NotFoundView.vue
  App.vue
  main.ts
e2e/
public/
docs/
```

## 7. Contracts and Data Model

The collector should normalize source responses into a public model rather than passing
unknown source fields directly to the browser.

```ts
type SchoolDirectoryEntry = {
  id: string
  slug: string
  name: string
  shortName: string
  canonicalUrl: string
  location?: {
    city?: string
    region?: string
    country: string
  }
  verificationStatus: 'verified' | 'suspended'
  availabilityStatus: 'online' | 'stale' | 'unavailable'
  clubCount: number
  categories: Record<string, number>
  sourceUpdatedAt: string
  lastCheckedAt: string
  dataHash: string
}
```

Initial public endpoints:

```text
GET /api/v1/schools?q=&region=&status=&cursor=
GET /api/v1/schools/{slug}
```

Do not expose source error messages, internal URLs, retry counts, ownership contacts,
or unverified registry records.

## 8. Coding Phases

### Phase 0 - Lock Scope and Contracts

1. Resolve the source summary route and add `schemaVersion` and `canonicalUrl`.
2. Make source school identity configurable in the first repository.
3. Write valid, stale, unavailable, and malformed response fixtures.
4. Define freshness: suggested `stale` after 48 hours without a valid check and
   `unavailable` after repeated failures, while retaining the last known good data.
5. Confirm Cloudflare accounts, domains, and the private service repository owner.

Exit: contracts are reviewed and frontend work can rely on versioned fixtures.

### Phase 1 - Initialize the Frontend

1. Create the Vue 3 + Vite + TypeScript application in the repository root.
2. Add Router, Zod, Vitest, Vue Test Utils, MSW, Playwright, ESLint, and Prettier.
3. Add CSS tokens, the application shell, and route-level error handling.
4. Add CI for lint, type-check, unit tests, browser smoke tests, and build.
5. Document local commands and environment variables.

Exit: a new maintainer can clone, run, test, and build without a live backend.

### Phase 2 - Build the Fixture-Driven MVP

1. Implement the school list, school card, and detail view.
2. Implement normalized full-name and short-name search.
3. Add location/status filters only when data is available.
4. Add loading, empty, invalid, stale, unavailable, and suspended states.
5. Add safe canonical links using allowlisted `https:` URLs.
6. Test 320 px mobile width, keyboard navigation, focus, labels, and color contrast.

Exit: the complete student workflow passes unit and Playwright tests using fixtures.

### Phase 3 - Build the Private Collector

1. Create D1 tables for verified schools, collection attempts, and current summaries.
2. Implement CLI/protected workflows to add, verify, pause, and remove a school.
3. Poll only allowlisted HTTPS endpoints on a conservative schedule.
4. Validate DNS/IP, redirects, content type, response size, timeout, and schema to
   reduce SSRF and resource-abuse risk.
5. Keep last-known-good data when a request or validation fails.
6. Publish only allowlisted fields through `/api/v1/schools` endpoints.
7. Add logs, health checks, rate limits, and failure alerts.

Exit: one reference instance is collected safely and source failure does not erase its
last valid public summary.

### Phase 4 - Integrate and Pilot

1. Configure staging frontend to use the staging collector API.
2. Preserve MSW fixtures for local and automated tests.
3. Verify CORS, caching, pagination, partial failure, and error handling.
4. Add two independently deployed school sites through the verification process.
5. Test with students and one maintainer; record task success and confusion points.
6. Document correction, suspension, deletion, and incident procedures.

Exit: users can find both schools and one source outage does not break the guide.

### Phase 5 - Production Hardening

1. Add production CSP, security headers, dependency scanning, and secret scanning.
2. Set performance budgets and run Lighthouse/accessibility checks.
3. Add privacy-preserving aggregate analytics only if a specific metric is needed.
4. Test D1 backup/export and restore procedures.
5. Reassess maps or PWA support only after pilot evidence.

Exit: release, monitoring, rollback, recovery, and ownership are documented.

## 9. Testing and Definition of Done

Every feature must include acceptance criteria and the appropriate checks:

- Unit tests for search normalization, filtering, status mapping, and contract parsing.
- Component tests for cards, empty states, and unavailable states.
- Contract tests shared between fixture, collector output, and frontend parsing.
- Playwright tests for search-to-school navigation at desktop and mobile sizes.
- Accessibility checks for keyboard use, focus, headings, labels, and contrast.
- Collector tests for SSRF defenses, redirects, timeouts, oversized payloads, invalid
  schemas, last-known-good behavior, and privacy field allowlisting.
- Documentation updates for changed contracts, setup, scope, or deployment.

An issue is not done merely because it builds. CI must pass and the user-visible behavior
must be verified against its failure states.

## 10. Recommended Issue Order

| Order | Work item | Dependency |
|---|---|---|
| 1 | Finalize source summary v1 contract | Reference repository |
| 2 | Make source identity configurable and add privacy tests | 1 |
| 3 | Commit schemas and frontend fixtures | 1 |
| 4 | Initialize Vue frontend and CI | None |
| 5 | Build school cards, list, and detail route | 3, 4 |
| 6 | Add search, filters, and all status states | 5 |
| 7 | Complete mobile, accessibility, and browser tests | 5, 6 |
| 8 | Create private collector repository and D1 schema | 1 |
| 9 | Implement safe polling and sanitized API | 8 |
| 10 | Integrate staging frontend with live API | 7, 9 |
| 11 | Pilot with two verified schools | 10 |
| 12 | Harden and release production | 11 |

## 11. Main Risks

| Risk | Mitigation |
|---|---|
| Source API changes | Version schemas and validate every response |
| Incorrect school identity | Configurable source identity plus manual ownership verification |
| Private data leakage | Explicit public-field allowlist and privacy contract tests |
| Collector SSRF | Allowlist hosts, validate DNS/IP and redirects, enforce limits |
| Source outages | Keep last-known-good data and display freshness |
| Scope grows into club management | Enforce repository boundaries and non-goals |
| Public/private code confusion | Separate repositories and deployment credentials |

## 12. Indicative Delivery Schedule

This is a six-week target for one part-time developer. Contract or account delays move
the dependent week rather than encouraging live integration against an unstable API.

| Week | Target |
|---|---|
| 1 | Lock contracts, initialize Vue, add fixtures and CI |
| 2 | Complete list, cards, search, filters, and detail route |
| 3 | Complete status states, mobile, accessibility, and frontend staging |
| 4 | Build private Worker, D1 schema, safe polling, and contract tests |
| 5 | Integrate staging and onboard two verified school instances |
| 6 | Pilot fixes, security/performance checks, production release, and runbooks |

If only one developer is available, frontend Phase 2 and collector Phase 3 should stay
sequential. Do not reduce security validation to preserve the date.
