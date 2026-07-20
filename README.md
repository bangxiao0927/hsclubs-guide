# HSclubs Guide

HSclubs Guide is the planned public school-discovery frontend for independent,
single-school HSclubs sites. Students use it to find a verified school and then open
that school's own club directory.

This project corresponds to the optional **2nd repo** in the
[HSclubs reference plan](https://github.com/bangxiao0927/HSclubs). It does not own
clubs, memberships, applications, user accounts, or school administration.

## Status

Frontend foundation development is underway against versioned fixtures. The Vue
application, strict runtime contracts, default MSW data source, test tooling, and CI are
available. Live integration remains blocked on source contract versioning, public-only
filtering, UTC timestamp semantics, summary-specific tests, and a verified production
URL.

## MVP

- Search verified schools by name, abbreviation, and location.
- Show school identity, availability, freshness, club count, and category counts.
- Open the canonical club site owned by each school.
- Remain usable when one source site is unavailable.
- Work accessibly on phone and desktop.

## Technology

- Public frontend: Vue 3, Vite, TypeScript, Vue Router, Vitest, and Playwright.
- Private collector/API: TypeScript, Hono, Cloudflare Workers, D1, and Cron Triggers.
- Hosting: Cloudflare Pages for this repository; Cloudflare Workers/D1 from a separate
  private repository for collection and the sanitized public API.

The TypeScript-only stack keeps the small team workflow simple and avoids maintaining
a server for an application that only performs scheduled collection and public reads.

## Local Development

Node.js 22 or newer is required. Local development uses MSW contract fixtures by
default, so no live API or credentials are needed.

```bash
npm ci
cp .env.example .env.local
npm run dev
```

Run all validation steps with:

```bash
npm run lint:check
npm run type-check
npm run test:unit -- --run
npm run test:e2e
npm run build
```

## Documentation

- [Development plan](docs/DEVELOPMENT_PLAN.md)
- [Frontend foundation](docs/FRONTEND_FOUNDATION.md)
- [1st repo backend audit](docs/FIRST_REPO_BACKEND_AUDIT.md)
- [Deployment guide](docs/DEPLOYMENT.md)

## Project Rules

- School sites stay independent and own all club and user data.
- Only manually verified HTTPS endpoints may be collected.
- Never collect or expose student, member, president, or administrator identity data.
- Keep private collector code, credentials, and operational metadata out of this public
  repository.
- Keep all project documentation and user-facing copy in English.
