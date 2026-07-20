# Frontend Foundation

## Scope

This milestone implements Track B from `docs/DEVELOPMENT_PLAN.md`. It establishes the
public Vue application without connecting a browser to a school-owned HSclubs instance
or adding any private collector behavior.

## Acceptance Criteria

- The repository runs Vue 3, Vite, TypeScript, and Vue Router from the repository root.
- ESLint, Prettier, type checking, Vitest, Playwright, and production builds have npm
  scripts and run in CI.
- Strict Zod schemas accept reviewed source and public directory fixtures while rejecting
  malformed responses and undeclared private fields.
- Local development and browser tests use MSW fixtures by default and require no live
  school or directory API.
- The application has a responsive shell, visible loading behavior, a not-found route,
  keyboard focus styles, a skip link, and Cloudflare Pages SPA/security configuration.
- No fixture, rendered view, or public contract contains person-level, ownership-contact,
  membership, application, authentication, or administrative data.

## Contract Fixture Policy

`src/fixtures/source-summary.valid.json` represents the proposed source summary v1
contract. It is test data only and does not indicate that the source readiness gate has
passed. `src/fixtures/directory-schools.valid.json` represents the sanitized response the
future private directory service will expose to this frontend.

Both source and public Zod schemas are strict. Unknown fields fail validation rather than
being silently copied into application state. The invalid fixtures intentionally include
malformed values and a private ownership contact to prove rejection behavior.

## Local Data Modes

MSW starts automatically in Vite development mode. Use the default fixture mode for
normal development:

```bash
cp .env.example .env.local
npm run dev
```

Connecting to an approved local or staging directory API is always explicit:

```bash
VITE_USE_MSW=false
VITE_DIRECTORY_API_BASE_URL=https://api.staging-guide.example.org
```

The browser must never set this base URL to an individual school's `/api/summary`
endpoint. Live source collection belongs only in the separate private service.
