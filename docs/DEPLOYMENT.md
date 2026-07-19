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

Security tests must cover blocked IP ranges, DNS/redirect validation, timeout, response
size, malformed schemas, and public-field allowlisting.

