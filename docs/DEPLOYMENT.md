# HSclubs Guide Deployment Guide

## 1. Release Target

The first release is a responsive website, not an App Store or Google Play application.
The reference plan explicitly defers native mobile work until the web experience has
been validated. The website can later add PWA installation without changing the core
architecture.

Recommended production layout:

```text
guide.example.org       Cloudflare Pages (public Vue application)
api.guide.example.org   Cloudflare Worker (sanitized public read API)
                        Cloudflare D1 (private registry and cached summaries)
school-a.example.org    Independent school-owned HSclubs instance
```

Use separate Cloudflare Pages projects, Workers environments, D1 databases, and secrets
for staging and production.

## 2. Environments

| Environment | Frontend | API | Data |
|---|---|---|---|
| Local | Vite dev server | MSW fixtures or local Wrangler | Local fixtures/local D1 |
| Preview | Cloudflare Pages PR preview | Staging Worker | Staging D1 |
| Staging | `staging-guide` Pages project/domain | Staging Worker | Staging D1 |
| Production | Custom guide domain | Production Worker | Production D1 |

Frontend environment variable:

```bash
VITE_DIRECTORY_API_BASE_URL=https://api.guide.example.org
```

Only variables prefixed with `VITE_` reach the browser. They must never contain secrets.

Private Worker configuration should use Wrangler variables for non-secret settings and
`wrangler secret put` for secrets. Production values must not be committed.

## 3. One-Time Setup

### Accounts and Repositories

1. Keep this `hsclubs-guide` repository public for the frontend.
2. Create a private `hsclubs-guide-service` repository for the collector and API.
3. Create a Cloudflare account with Pages, Workers, D1, and the target DNS zone.
4. Enable branch protection on `main` in both repositories.
5. Require CI checks and pull-request review before merge.
6. Enable GitHub Dependabot and secret scanning.

### Domains

1. Choose the production frontend and API domains.
2. Add the frontend custom domain to Cloudflare Pages.
3. Add the API custom domain/route to the production Worker.
4. Keep staging on separate subdomains.
5. Enforce HTTPS and do not collect from HTTP source endpoints.

### D1

From the private service repository:

```bash
npx wrangler d1 create hsclubs-guide-staging
npx wrangler d1 create hsclubs-guide-production
npx wrangler d1 migrations apply hsclubs-guide-staging --remote
npx wrangler d1 migrations apply hsclubs-guide-production --remote
```

Record database IDs in the appropriate Wrangler environments. Never point preview or
staging deployments at production D1.

## 4. Local Development Workflow

After Phase 1 initializes the frontend, the normal commands should be:

```bash
npm ci
cp .env.example .env.local
npm run dev
npm run lint
npm run type-check
npm run test:unit
npm run test:e2e
npm run build
```

The default local mode should use MSW fixtures. A developer must opt in explicitly to a
local or staging API so development is not blocked by source sites.

The private service should provide:

```bash
npm ci
npx wrangler d1 migrations apply hsclubs-guide-local --local
npm run dev
npm test
npm run deploy:staging
```

## 5. CI Requirements

### Public Frontend Repository

Every pull request and `main` push must run:

```text
npm ci
npm run lint:check
npm run type-check
npm run test:unit -- --run
npm run test:e2e
npm run build
```

Also run dependency review and secret scanning. Browser tests should use fixtures, not
live school endpoints.

### Private Service Repository

Every pull request and `main` push must run:

```text
npm ci
npm run lint:check
npm run type-check
npm test
npm run test:contract
npm run test:security
npx wrangler deploy --dry-run
```

Security tests must cover exact-host allowlisting, IP-literal rejection, redirect
rejection, timeout, response size, malformed schemas, and public-field allowlisting.

## 6. Frontend Deployment to Cloudflare Pages

### Create the Project

1. Open Cloudflare Dashboard -> Workers & Pages -> Create -> Pages.
2. Connect the public GitHub repository.
3. Select framework preset `Vue` or configure manually.
4. Use build command `npm run build`.
5. Use output directory `dist`.
6. Use a Node.js version supported by the committed `package.json` engines.
7. Add `VITE_DIRECTORY_API_BASE_URL` separately for preview and production.

### SPA and Security Configuration

Add `public/_redirects` during implementation:

```text
/* /index.html 200
```

Add `public/_headers` with a tested Content Security Policy and at least:

```text
/*
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  X-Frame-Options: DENY
```

The final CSP should allow only the frontend itself, the production API, required image
origins, and explicitly approved analytics. Test it in staging before enforcement.

### Promotion

1. Each pull request receives a Pages preview URL.
2. Run automated checks and manually smoke-test the preview at phone and desktop widths.
3. Merge only after required checks pass.
4. Cloudflare Pages deploys `main` to production.
5. Verify `/`, a school detail deep link, an empty search, and an API failure state.

## 7. Private Worker Deployment

### Staging First

1. Apply pending migrations to staging D1.
2. Deploy the Worker staging environment.
3. Seed only approved test/reference schools.
4. Run collection manually once and inspect validation output.
5. Run API contract and privacy smoke tests against staging.
6. Point the staging frontend at the staging API.

Typical commands, finalized by the private repository scripts:

```bash
npx wrangler d1 migrations apply hsclubs-guide-staging --remote
npx wrangler deploy --env staging
npm run smoke:staging
```

### Production

1. Export/backup production D1 before a risky migration.
2. Apply backward-compatible D1 migrations.
3. Deploy the production Worker.
4. Run public API smoke tests before enabling scheduled collection.
5. Add the first verified school and run an on-demand collection.
6. Confirm the sanitized response contains only the documented fields.
7. Enable a conservative Cron Trigger, initially no more than hourly.
8. Watch errors, duration, D1 usage, and source failure rates.

```bash
npx wrangler d1 migrations apply hsclubs-guide-production --remote
npx wrangler deploy --env production
npm run smoke:production
```

The frontend should use cacheable public reads. Collector writes and registry mutations
must not be public or protected only by a browser-hidden link.

## 8. First School Onboarding

Do not accept an arbitrary URL directly into the collector. A maintainer should:

1. Verify control of the school site through an official school contact or a temporary
   verification token at the source site.
2. Confirm the exact HTTPS endpoint is `GET /api/summary` and returns source contract v1.
3. Confirm configured identity, canonical URL, UTC timestamps, and hash behavior.
4. Run privacy and schema validation without publishing the record.
5. Add the hostname and exact summary path to the collector allowlist.
6. Run the first collection and review the normalized public output.
7. Publish the school entry, then verify it in staging and production frontends.
8. Record an owner contact privately for corrections; never expose it publicly.

Add the second school before declaring the product ready. One source cannot prove that
the aggregator handles independent deployments correctly.

## 9. Production Release Checklist

- Source contract v1 readiness gate and the 1st repo summary test suite pass.
- At least two verified schools pass collection and privacy validation.
- Frontend and service CI are green on the release commits.
- Production domains, HTTPS, CORS, caching, and security headers are verified.
- Deep links work after a direct browser refresh.
- Search, empty, stale, unavailable, and partial-failure states are smoke-tested.
- 320 px mobile, keyboard, and screen-reader basics are checked.
- No secrets appear in frontend bundles, logs, or repository history.
- D1 backup/export, rollback, suspension, correction, and removal procedures are tested.
- Monitoring has a named owner and an alert destination.
- Terms/privacy copy accurately describes the limited public data and analytics used.

## 10. Rollback and Incident Flow

### Frontend

1. Use Cloudflare Pages deployment history to roll back to the last known good build.
2. If the API is failing, show cached/maintenance behavior rather than bypassing validation.
3. Fix forward through a reviewed pull request.

### Worker

1. Disable the Cron Trigger if collection is causing damage or excess traffic.
2. Pause affected school records without deleting last-known-good summaries.
3. Roll back the Worker to the previous version.
4. Restore D1 only when data is corrupt; prefer a forward migration otherwise.
5. Rotate any exposed secret and review access logs.
6. Document impact, timeline, remediation, and prevention.

## 11. Store Release Decision

No Apple App Store or Google Play submission belongs in the MVP. After real users prove
the responsive website is useful, evaluate in this order:

1. Keep the responsive site only.
2. Add a PWA manifest and install guidance.
3. Build a native shell or separate mobile repository only if device capabilities or
   distribution requirements cannot be met by the PWA.

This prevents maintaining a second UI before the school-discovery workflow is stable.
