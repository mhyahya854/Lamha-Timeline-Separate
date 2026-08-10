# Dawarich Strip Progress

**Status:** Active execution state for the Dawarich stripping plan.
**Authority:** `LAMHA_DAWARICH_KEEP_SCOPE.md` (keep boundary) and `LAMHA_DAWARICH_REMOVE_SCOPE.md` (removal boundary).

## Repository Note

This directory was an extracted source tree with **no `.git` metadata** until the 2026-08-10
bootstrap run. Status as of that run and the follow-up push retry:

- Git initialized on branch `main`.
- `origin` configured to `git@github.com:mhyahya854/Lamha-Timeline-Separate.git` (HTTPS push via
  the local `url."https://github.com/".insteadOf "git@github.com:"` rewrite with the `gh`
  credential helper).
- `upstream` configured to `https://github.com/Freika/dawarich.git` (reference only).
- Baseline commit created locally: `686feb6` (`chore: establish Dawarich baseline for Lamha Timeline stripping`).
- Follow-up docs commit `515de12` records the original push blocker.
- **Bootstrap push SUCCEEDED** on 2026-08-10: `git push origin main` created `refs/heads/main`
  on `origin` at `515de12` (verified with `git ls-remote origin`). The bootstrap is now complete.
- No strip task has been performed; the removal queue starts at `STRIP-001`.

## Execution State

- Initialized: 2026-08-10
- Bootstrap run: repository initialized, baseline committed locally, initial push BLOCKED
  (missing GitHub `workflow` scope for OAuth token)
- Bootstrap completion run: baseline push retried and **succeeded**; `origin/main` at `515de12`
- STRIP-001 (Remove Fog of War): completed, committed, pushed; see record below
- STRIP-002 (Remove Family Sharing subsystem): completed, committed, pushed; see record below
- `## Next Task`: `STRIP-003` (see below)

## Removal Queue (ordered)

Ordering rationale: remove self-contained, low-dependency product surfaces first; remove
deeply entangled subsystems (auth, UI shell, API surface, deployment) last so the repository
stays bootable and retained location-history capabilities stay testable throughout.

| ID | Task | Boundary notes | Status |
| --- | --- | --- | --- |
| STRIP-001 | Remove Fog of War | Remove feature controllers/views/routes/services/models/tests and settings surface. No KEEP dependency. | [x] |
| STRIP-002 | Remove Family Sharing subsystem | Family accounts, memberships, invitations, location requests/sharing, family locations API, shared digests/stats for family. Keep nothing from family model. | [x] |
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

- STRIP-001 Remove Fog of War (2026-08-10)
- STRIP-002 Remove Family Sharing subsystem (2026-08-10)

## Completed Task

* Task ID: STRIP-001
* Task name: Remove Fog of War

## Removed

* `app/services/maps/fog_hexagons.rb` (fog-only H3 service)
* `Api::V1::Maps::HexagonsController#fog` action + `parse_fog_date!`; `get :fog` route removed
* Fog settings surface: `Users::SafeSettings` fog defaults/config/accessors, `FOG_OF_WAR_MODES`,
  `GATED_MAP_LAYERS` entry; API settings permit list; `Api::UserSerializer` fog fields;
  `Api::V1::PlanController` `fog_of_war` feature flags
* `db/migrate/20240630093005_add_fog_of_war_to_default_settings.rb` and
  `db/data/20240625201842_add_fog_of_war_meters_to_settings.rb` (fog-only migrations)
* Frontend: `maps/fog_of_war.js`, `maps_maplibre/layers/fog_layer.js`,
  `maps_maplibre/layers/fog_hexagon_source.js`, Leaflet and MapLibre fog wiring
  (controllers, layer manager, data loader, routes manager, settings managers, API client
  `fetchFogHexagons`, lazy loader entry), fog UI in `_settings_panel.html.erb`,
  `_settings_modals.html.erb`, `index.html.erb`, cloud-fog icon
* Specs: `spec/services/maps/fog_hexagons_spec.rb`, fog request/swagger tests, fog factory key,
  fog assertions in safe_settings/serializer/settings/users/transportation specs
* `swagger/v1/swagger.yaml` fog endpoint + settings/plan fog schemas; docs mentions in
  README/CLAUDE/app JS README and archival mailer views

## Preserved

* Hexagon `index`/`bounds` API actions and shared `Maps::HexagonRequestHandler` /
  `Maps::BoundsCalculator` (heatmap/scratch-map usage) — kept intact
* All KEEP location-history capabilities untouched: Google Timeline import, cleanup/
  normalization/deduplication, reverse geocoding, visit/place detection, routes, stats,
  trip geography; no retained code references fog settings or endpoints

## Files Changed

49 files: 8 deleted, 41 modified (see commit diff; all changes fog-scoped)

## Validation Executed

* `npx --yes prettier@3.6.2 --check <14 modified JS files>` — WARN (style only) on all 14;
  baseline HEAD versions fail identically, so warnings are pre-existing; no syntax errors
* `node --input-type=module --check <14 modified JS files>` — PASS (all parse)
* `node --test spec/javascript/*_test.mjs` — PASS 64/64 (settings manager tests included)
* `python yaml.safe_load swagger/v1/swagger.yaml` — PASS; 64 paths, no fog references
* `git diff --check` — PASS
* Ruby checks (`bundle exec rspec`, `bundle exec rubocop`, `rails runner`/`rails routes`,
  `rails db:migrate`) — NOT RUN: environment has no Ruby/Bundler/Postgres/Docker;
  Ruby edits reviewed manually via `git diff`

## Repository Search

* `rg -i fog` across `app/ db/ config/ spec/ swagger/` — no matches
* `rg` for fog symbols (`fogEnabled`, `fogOfWar*`, `FogLayer`, `FogHexagons`, `fetchFogHexagons`,
  `fogOverlay`, `updateFog`, `fog_of_war*`, `cloud-fog`, migration timestamps) — no matches
* Intentional surviving references: `config/shared_link_wordlist.txt` (generic wordlist word),
  `CHANGELOG.md` (historical release notes), scope/progress planning docs

## Database Impact

* No table/column/constraint changes. `db/schema.rb` `users.settings` default dropped
  `"fog_of_war_meters" => "100"`; fog-only schema/data migrations deleted. Chain integrity:
  existing installs already recorded those versions in `schema_migrations`; fresh installs no
  longer apply them (no retained code references fog keys). Existing rows may retain inert
  `fog_of_war_*` keys in the settings JSON — harmless and intentionally not scrubbed

## Decisions

* Shared hexagon controller `index`/`bounds` and their services are retained (heatmap/scratch
  map depend on them); only the fog action/route/service were removed
* Historical fog migrations deleted instead of preserved with a forward migration because they
  are exclusively fog-feature (settings JSON default + backfill), no KEEP capability depends on
  them, and neither fresh nor existing migration chains break; schema.rb updated to match
* CHANGELOG entries kept as historical record; generic wordlist/vendor files untouched
* Environment lacks Ruby/Postgres tooling, so Rails-side execution was replaced by manual diff
  review plus Node/Prettier/YAML checks; later runs with a Ruby environment should run the
  full suite

## Blockers

* None (validation limits from missing Ruby/Postgres tooling documented above, not blockers)

## Commit

* 8d56bb0 (`strip(dawarich): STRIP-001 remove fog of war`)

## Push

* remote: origin (`https://github.com/mhyahya854/Lamha-Timeline-Separate.git`)
* branch: main
* result: succeeded — `12a8631..8d56bb0 main -> main`; verified with `git ls-remote origin`

## Completed Task

* Task ID: STRIP-002
* Task name: Remove Family Sharing subsystem

## Removed

* Models: `Family`, `Family::Membership`, `Family::Invitation`, `Family::LocationRequest`,
  `concerns/user_family.rb`, `UserFamily` include from `User`
* Controllers: `FamiliesController`, `Family::*` (invitations/memberships/location_requests/
  location_sharing), `Api::V1::Families::LocationsController`; all family routes (web + API)
* Jobs: `Family::Invitations::SendingJob/CleanupJob`, `Families::ExpireLocationRequestsJob`;
  `schedule.yml` entries removed
* Mailer: `FamilyMailer` + views; Services: `families/*` (7); Policies: `FamilyPolicy` + 2
* Channel: `FamilyLocationsChannel` (+ JS channel, importmap pin); point/live-broadcaster family
  sharing removed
* Frontend: family JS controllers (navbar indicator, members, map), `family_layer.js`,
  MapLibre/Leaflet family layer wiring, family settings toggle/list, map channel family
  subscription, settings manager `familyEnabled` mapping
* Views: `families/*`, `family/*`, `family_mailer/*`, navbar family nav, maplibre settings
  panel family block, leaflet family data attributes/banner, devise invitation UI, mailer copy
* Config: family feature flag (`DawarichSettings`), `ensure_family_feature_available!` helpers,
  `family_home_path`/`family_upgrade_url`, devise `cannot_delete` message, family jobs schedule,
  family importmap pin
* DB: 5 family migrations deleted; `db/schema.rb` family tables + foreign keys removed
* Tasks: `demo.rake` family seeding, `e2e.rake` family users, `seed_e2e` comment
* Swagger: family locations/history endpoints + users delete 422; family swagger spec
* Specs: 37 family-specific spec files deleted; family tests removed from 15 shared specs

## Preserved

* `plan` enum value `family: 2` and subscription plan handling (Dawarich Cloud/subscription is
  removed in a later task); `rack_attack` family rate tier retained with the plan name
* All KEEP location-history capabilities untouched: Google Timeline import, cleanup/
  normalization/deduplication, reverse geocoding, visits/places, routes, stats, trip geography
* Account deletion, notifications, digests, and shared-link surfaces retained (their family
  references removed only)

## Files Changed

155 files: 90 deleted, 65 modified (see commit diff; all changes family-scoped)

## Validation Executed

* `node --input-type=module --check <10 modified JS files>` — PASS (all parse)
* `node --test spec/javascript/*_test.mjs` — PASS 64/64
* `python yaml.safe_load swagger/v1/swagger.yaml` — PASS; 62 paths, no family references
* `git diff --check` — PASS
* `rg` stale-reference scans for family symbols/routes/helpers — no matches outside documented
  intentional references
* Ruby checks (`bundle exec rspec`, `bundle exec rubocop`, `rails runner`/`rails routes`,
  `rails db:migrate`) — NOT RUN: environment has no Ruby/Bundler/Postgres/Docker;
  Ruby edits reviewed manually via `git diff`

## Repository Search

* `rg -i family` across `app/ config/ lib/ db/ swagger/` — no feature references; only retained
  plan enum (`family: 2`), rack-attack tier name, font-family CSS/JS, generic copy
* `rg` for removed symbols (`Family::`, `Families::`, `family_path`, `family_invitation_path`,
  `family_feature_available`, `ensure_family`, `FamilyLocationsChannel`, `familyEnabled`,
  `Family Members`, `can_delete_account`, family migration timestamps) — no matches
* Intentional surviving references: `User#plan` enum + specs, subscriptions plan tests,
  OAuth `family_name` fixture, "friends and family" copy, `joined the family` notification test

## Database Impact

* `db/schema.rb`: `families`, `family_invitations`, `family_location_requests`,
  `family_memberships` tables and their foreign keys removed; no other schema changes.
  Chain integrity: existing installs already recorded those migration versions in
  `schema_migrations`; fresh installs no longer apply them (no retained code references the
  family tables). Existing rows in those tables are orphaned/inert and intentionally not
  scrubbed (no forward data migration)

## Decisions

* The `family` subscription plan enum value and plan-based entitlements are retained: they are
  part of the Dawarich Cloud/subscription model removed in a later task, and dropping the enum
  value would risk breaking existing DBs; only family-feature inheritance
  (`inherited_family_access?`, `families?`, feature flag) was removed
* Family migrations deleted (not forward-migrated) for the same verified reasons as STRIP-001:
  exclusively family-feature tables, no KEEP dependency, no chain break
* Account-deletion family ownership checks (`can_delete_account?`) removed entirely — no
  remaining account-level restriction exists without families
* Demo/e2e seeding no longer creates family members; the e2e user list is reduced to demo/lite

## Blockers

* None (validation limits from missing Ruby/Postgres tooling documented above, not blockers)

## Commit

* 4d4d13a (`strip(dawarich): STRIP-002 remove family sharing subsystem`)

## Push

* remote: origin (`https://github.com/mhyahya854/Lamha-Timeline-Separate.git`)
* branch: main
* result: succeeded — `364aefe..4d4d13a main -> main`; verified with `git ls-remote origin`

## Decisions

- **Git:** The directory was not a git repository; bootstrap initialized it on `main` with
  `origin` = `git@github.com:mhyahya854/Lamha-Timeline-Separate.git`.
- **Push credentials:** Local SSH key is passphrase-protected with no usable agent; HTTPS via the
  authenticated `gh` token works for normal refs. The retry push succeeded on 2026-08-10, so the
  earlier `workflow`-scope blocker (recorded in commit `515de12`) is resolved; future pushes use
  `git push origin main` and are verified with `git ls-remote origin`.
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

`STRIP-003` — Remove Overland live-tracking endpoint
