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

