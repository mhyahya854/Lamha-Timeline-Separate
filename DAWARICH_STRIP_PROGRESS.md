# Dawarich Strip Progress

**Status:** Active execution state for the Dawarich stripping plan.
**Authority:** `LAMHA_DAWARICH_KEEP_SCOPE.md` (keep boundary) and `LAMHA_DAWARICH_REMOVE_SCOPE.md` (removal boundary).

## Repository Note

This directory was an extracted source tree with **no `.git` metadata** until the 2026-08-10
bootstrap run. Status as of that run:

- Git initialized on branch `main`.
- `origin` configured to `git@github.com:mhyahya854/Lamha-Timeline-Separate.git` (verified).
- `upstream` configured to `https://github.com/Freika/dawarich.git` (reference only).
- Baseline commit created locally: `686feb6` (`chore: establish Dawarich baseline for Lamha Timeline stripping`).
- Baseline **push is BLOCKED**: GitHub rejects OAuth-token pushes that create/update
  `.github/workflows/*` without the `workflow` scope. The local `gh` token has scopes
  `admin:public_key, gist, read:org, repo` and no `workflow` scope.
- SSH push is not possible either: `~/.ssh/id_ed25519` is passphrase-protected, no ssh-agent is
  running, and the passphrase is not available in this environment.
- Workaround applied for future pushes: local `git config url."https://github.com/".insteadOf
  "git@github.com:"` so `git push origin main` uses HTTPS with the `gh` credential helper.
  **Retry the baseline push on the next run**; until the push succeeds, the bootstrap is
  incomplete and no strip task may run.

## Execution State

- Initialized: 2026-08-10
- Bootstrap run: repository initialized, baseline committed locally, push BLOCKED
  (missing GitHub `workflow` scope for OAuth token)
- No source code changed; no strip task performed
- `## Next Task`: `STRIP-001` (see below)

## Removal Queue (ordered)

Ordering rationale: remove self-contained, low-dependency product surfaces first; remove
deeply entangled subsystems (auth, UI shell, API surface, deployment) last so the repository
stays bootable and retained location-history capabilities stay testable throughout.

| ID | Task | Boundary notes | Status |
| --- | --- | --- | --- |
| STRIP-001 | Remove Fog of War | Remove feature controllers/views/routes/services/models/tests and settings surface. No KEEP dependency. | pending |
| STRIP-002 | Remove Family Sharing subsystem | Family accounts, memberships, invitations, location requests/sharing, family locations API, shared digests/stats for family. Keep nothing from family model. | pending |
| STRIP-003 | Remove Overland live-tracking endpoint | `api/v1/overland` batches controller + routes + tests. Live tracking is rejected. | pending |
| STRIP-004 | Remove OwnTracks live-tracking endpoint and import pipeline | `api/v1/owntracks` points endpoint, OwnTracks import service/UI references. Google Timeline import must remain untouched. | pending |
| STRIP-005 | Remove Traccar live-tracking endpoint | `api/v1/traccar` points controller + routes + tests. | pending |
| STRIP-006 | Remove mobile tracking-app surface | iOS/Android auth controllers, `settings/mobile`, mobile-specific settings API. Live/continuous tracking is rejected. | pending |
| STRIP-007 | Remove Strava import pipeline | Strava importer service, controller/UI, API routes, fixtures/tests. Non-Google importers are rejected. | pending |
| STRIP-008 | Remove Polarsteps import pipeline | Polarsteps importer service, controller/UI, API routes, fixtures/tests. Non-Google importers are rejected. | pending |
| STRIP-009 | Remove photo integrations and Dawarich photo handling | Immich/PhotoPrism controllers/services/settings, shared photos API, photo UI, photo-related models/serializers. Preserve retained location features (no KEEP dependency). | pending |
| STRIP-010 | Remove Notes / journaling layer | Trip notes, place notes UI, API notes, notes models/services. Lamha owns journaling; nothing kept. | pending |
| STRIP-011 | Remove Dawarich Trips product surface | Trip page/UI, trip share links, trip notes/photo integration, Trip product model/API as final model. **Preserve** trip geographic calculation logic (distance/time/country-city summaries) used by retained location history. Exact model/service boundary to be resolved during the task. | pending |
| STRIP-012 | Reduce full Areas/geofencing to minimal saved locations | Remove complex area management, geofence workflows/automation, areas API/UI; retain only a minimal saved-location concept (name, coordinates, optional matching radius). | pending |
| STRIP-013 | Remove Insights product surface | Insights controller/views/API; preserve underlying geographic statistics services that derive from location archive. | pending |
| STRIP-014 | Remove public share links / shared stats surface | Share links (timeline/points/trips/lives/shares/hubs), shared stats/digests controllers/views. Not in KEEP scope; do not touch retained location data. | pending |
| STRIP-015 | Remove web app UI: map screens | Leaflet/Maplibre map screens, map residency/timeline-feeds pages, map controls/layers/heatmap UI. Preserve underlying routes/geometry data. | pending |
| STRIP-016 | Remove web app UI: timeline screen and application shell | Timeline screen, home screen, main navigation/layout, Dawarich branding/product structure. Preserve timeline data/API only if still needed by retained logic. | pending |
| STRIP-017 | Remove web app UI: statistics, insights, settings, import-management screens | Stats/insights/settings/account/onboarding screens and import-management UI as-is. Preserve Google import backend and statistics services. | pending |
| STRIP-018 | Remove authentication / user account system | Devise users, sessions/registrations/omniauth/two-factor, account deletion, trial/subscription controllers, API auth. Remove only after UI/API surfaces that depend on accounts are gone; retained features stop requiring `current_user` scoping. | pending |
| STRIP-019 | Remove Dawarich API/JSON server surface | `ApiController`, `api/v1` routes/controllers not already removed, serializers, API docs in `swagger/`. Preserve any internal data behavior required to prevent loss of retained location history. | pending |
| STRIP-020 | Remove deployment stack and cloud/hosted model | `docker/`, Procfile* deployment configs, `.env*` templates, deployment docs, Dawarich Cloud/subscription config. Retained features must not depend on the server stack. | pending |
| STRIP-021 | Remove remaining Dawarich product remnants | Posters, notifications, tags, digests, exports UI/product surfaces not covered above **only if** they are not required to prevent loss of retained location history; re-audit before each removal. | pending |

## Completed Tasks

None yet.

## Decisions

- **Git:** The directory was not a git repository; bootstrap initialized it on `main` with
  `origin` = `git@github.com:mhyahya854/Lamha-Timeline-Separate.git`.
- **Push credentials:** Local SSH key is passphrase-protected with no usable agent; HTTPS via the
  authenticated `gh` token works for normal refs but the OAuth token lacks the `workflow` scope,
  which GitHub requires to push `.github/workflows/*`. A token refresh/PAT with `workflow` scope
  (or removal of the workflows from the pushed baseline after explicit user approval) is required
  before the baseline push can succeed. This is recorded as a blocker, not a completed bootstrap.
- **Baseline content:** The baseline commit contains the untouched Dawarich source tree plus the
  three planning/state documents, preserving `LICENSE` (AGPL-3.0) and upstream attribution.
- **Queue derivation:** The queue is derived solely from `LAMHA_DAWARICH_REMOVE_SCOPE.md`, ordered so retained
  location-history capabilities (Google Timeline import, cleanup/normalization/deduplication, reverse geocoding,
  visit/place detection, route reconstruction, trip geography, statistics, minimal saved locations) remain bootable
  and testable after every task.
- **Validation standard:** Every task runs the repository's established checks where the environment permits:
  `bundle exec rspec`, `bundle exec rubocop`, `npx prettier --check app/javascript`, boot check via
  `bundle exec rails runner`/`rails routes` or equivalent, plus a stale-reference search for the removed symbols.
- **Database safety:** Historical migrations are not casually deleted; each task prefers safe forward migrations
  and must preserve migration-chain integrity for fresh installs and existing upgrade paths.
- **Boundary review:** If a task proves a later task's stated boundary incorrect, update that task's boundary notes
  in the queue and document why.

## Next Task

`STRIP-001` — Remove Fog of War
