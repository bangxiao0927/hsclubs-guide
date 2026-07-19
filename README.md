# HSclubs Guide

HSclubs Guide is the planned public school-discovery frontend for independent,
single-school HSclubs sites. Students use it to find a verified school and then open
that school's own club directory.

This project corresponds to the optional **2nd repo** in the
[HSclubs reference plan](https://github.com/bangxiao0927/HSclubs). It does not own
clubs, memberships, applications, user accounts, or school administration.

## Status

Planning and contract preparation. The reference backend already provides a public,
configurable `GET /api/summary`, but live integration remains blocked on contract
versioning, public-only filtering, UTC timestamp semantics, summary-specific tests, and
a verified production URL. Frontend work may proceed against versioned fixtures.

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

## Documentation

- [Development plan](docs/DEVELOPMENT_PLAN.md)
- [1st repo backend audit](docs/FIRST_REPO_BACKEND_AUDIT.md)
- [Deployment guide](docs/DEPLOYMENT.md)

## Project Rules

- School sites stay independent and own all club and user data.
- Only manually verified HTTPS endpoints may be collected.
- Never collect or expose student, member, president, or administrator identity data.
- Keep private collector code, credentials, and operational metadata out of this public
  repository.
- Keep all project documentation and user-facing copy in English.
