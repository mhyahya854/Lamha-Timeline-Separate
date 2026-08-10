# Lamha — Dawarich REMOVE / DO-NOT-PORT Scope

**Status:** Canonical scope decision  
**Purpose:** Define exactly which Dawarich capabilities, product features, infrastructure and integrations are excluded from Lamha.

Anything in this file should **not** be carried into Lamha merely because Dawarich has it.

---

# 1. Dawarich as a Standalone Product

## REMOVE

Do not retain Dawarich itself as a permanent fourth application.

Remove/do not port:

- Dawarich as a separately running daily-use app.
- Dawarich as Lamha's permanent backend.
- Dawarich as Lamha's permanent database.
- Dawarich as an always-running dependency.
- Dawarich navigation/application shell.
- Dawarich branding/product structure.
- Dawarich account-centric product model.

Lamha should natively own the retained location-history capabilities.

---

# 2. Dawarich Web Application UI

## REMOVE

Do not port Dawarich's existing web interface as Lamha's location interface.

This includes Dawarich-specific:

- Main navigation.
- Map screen implementation.
- Timeline screen implementation.
- Trips screen implementation.
- Statistics screen implementation.
- Insights screen implementation.
- Family screen implementation.
- Settings/account screens.
- Import-management UI as-is.
- Existing web layout/component structure.

Lamha will build its own interface around its existing media, event, people, memory and map architecture.

---

# 3. Dawarich Online/Interactive Map Frontend as the Final Map System

## REMOVE

Do not use Dawarich's own map frontend as Lamha's permanent map implementation.

Do not port merely because Dawarich provides:

- Points layer UI.
- Lines-between-points layer UI.
- Heatmap UI.
- Existing Dawarich map controls.
- Existing Dawarich map navigation.
- Dawarich-specific interactive map page behavior.

Lamha's final map system will be its own system and is planned to support offline OpenStreetMap-based map data.

Underlying coordinates/routes retained from location history remain useful; Dawarich's particular map frontend does not.

---

# 4. Fog of War

## REMOVE

Do not port Fog of War.

Reason:

- It is visually cute but not important to the core Lamha location/memory archive.
- It adds scope without adding enough value to the current plan.

This is explicitly excluded.

---

# 5. Dawarich Family Sharing

## REMOVE COMPLETELY

Do not port Dawarich's family-location-sharing model.

This includes:

- Family accounts.
- Sharing live/current location with family members.
- Viewing another Dawarich user's shared location.
- Per-user sharing permissions.
- Family map feature.
- Consent toggles built around Dawarich users/accounts.

Lamha's Mum/Dad/friend model is different.

Lamha needs people, devices, assets and provenance inside one private personal archive — not a family live-location-sharing network.

---

# 6. Live / Continuous Location Tracking

## REMOVE FROM THE CURRENT PLAN

Do not port Dawarich's live tracking capability.

This includes integrations/workflows for continuous location updates from:

- Dawarich iOS tracking.
- Dawarich Android tracking.
- Dawarich Community Android tracking.
- Overland.
- OwnTracks live tracking.
- GPSLogger.
- PhoneTrack.
- Home Assistant location tracking.
- Other live HTTP/device tracking endpoints.

The current Lamha plan is based on importing historical Google Timeline data.

Continuous Lamha-native tracking could be reconsidered in a future project phase, but it is **not part of the current Dawarich keep scope**.

---

# 7. Non-Google Location Import Sources

## REMOVE FROM CURRENT SCOPE

Do not port Dawarich's broad importer ecosystem merely because it exists.

The current plan keeps the **Google Maps / Google Timeline importer**.

Do not currently port dedicated Dawarich import pipelines for:

- OwnTracks.
- Strava.
- Polarsteps.
- Generic third-party live trackers.
- Fitness tracking sources.
- Other location services that are not required for the Google Timeline archive.

Generic file formats such as GPX/GeoJSON/KML may remain useful for future interoperability, but they are **not part of the currently locked Dawarich-derived feature scope unless separately approved later**.

---

# 8. Dawarich Photo Integrations

## REMOVE COMPLETELY

Do not port Dawarich's external photo-management integrations.

This includes:

- Immich integration.
- PhotoPrism integration.
- Dawarich photo display system.
- Dawarich map-photo integration architecture.
- Dawarich dependence on external photo-management systems.
- Importing photo geodata through Dawarich's external photo integrations.

Reason:

Lamha itself is the photo/video system.

Photos, videos, EXIF metadata, faces, people, events and memories belong natively to Lamha.

---

# 9. Dawarich Photo Handling as a Separate Location Feature

## REMOVE

Do not build a parallel Dawarich-style photo system inside Lamha.

Do not duplicate:

- Photo records solely for Dawarich/location purposes.
- Separate photo libraries for the map.
- Separate trip-photo databases.
- Separate geotagged-photo indexing that competes with Lamha's own asset model.

Location features should reference Lamha's canonical assets.

---

# 10. Dawarich Trip Product/UI

## REMOVE / REPLACE

Do not port Dawarich Trips as-is.

Remove:

- Dawarich Trip database model as the final Lamha trip model.
- Dawarich Trip page/UI.
- Dawarich-specific trip notes implementation.
- Dawarich photo integrations within Trips.
- Dawarich's trip product assumptions.

Only the useful geographic trip logic is retained.

The Lamha-native concept is **Journey**.

---

# 11. Dawarich Notes / Journaling Layer

## REMOVE

Do not port Dawarich as a journal or notes application.

Do not retain:

- Dawarich trip notes as the canonical journal.
- Dawarich-specific notes storage.
- Dawarich-specific place notes UI as authoritative.
- Any separate Dawarich journaling database.

Lamha's durable Markdown/JSON archive, Memories, Events, Journeys and personal Place records handle this instead.

---

# 12. Full Dawarich Areas / Geofencing System

## REMOVE / REDUCE

Do not port the full Dawarich Areas feature.

Do not retain:

- Complex user-drawn geographic-area management as a major subsystem.
- Advanced geofence workflows.
- Automation triggered by entering/leaving geofences.
- A separate heavy Areas product surface.

The only retained piece is a **minimal saved-location concept**:

```text
Saved location
+ coordinates
+ optional matching radius
```

That is enough for locations such as Home, University, Hospital, Grandma's house, etc.

---

# 13. Dawarich Cloud / Hosted-Service Model

## REMOVE

Do not port or depend on:

- Dawarich Cloud.
- Dawarich-managed hosting.
- SaaS assumptions.
- Remote-hosted account requirements.
- Cloud dependency for the location archive.

Lamha's location archive is local-first and designed to remain readable without the application.

---

# 14. Dawarich Authentication and User Account System

## REMOVE

Do not port Dawarich's account/authentication model into Lamha for the location feature.

This includes:

- Dawarich login system.
- Dawarich user accounts.
- Default account model.
- Multi-user assumptions.
- User-specific sharing permissions from Dawarich.

Lamha's people such as Mum, Dad or friends must not be modeled as Dawarich-style application users merely because photos or memories involve them.

---

# 15. Dawarich Deployment Stack

## REMOVE

Do not carry over Dawarich's deployment architecture simply to obtain location-history features.

This includes avoiding Dawarich-specific dependence on:

- Dawarich Docker Compose setup.
- Separate Dawarich web server.
- Separate Dawarich database stack.
- Separate Dawarich worker stack.
- Separate Dawarich environment-variable/deployment configuration.
- Reverse-proxy setup required only to operate Dawarich as a server product.
- Synology/server deployment instructions specific to Dawarich.

The retained capabilities should be implemented to fit Lamha's existing desktop/local-first architecture.

---

# 16. Dawarich Server/API Surface as a Permanent Requirement

## REMOVE

Do not make Lamha depend on Dawarich's existing web/API endpoints.

No permanent requirement for:

- Dawarich REST/API surface.
- Dawarich server routes.
- Dawarich API authentication.
- Dawarich background service as a network dependency.
- HTTP connection from Lamha to a separately running Dawarich instance.

Dawarich may be studied as a reference implementation, but the final Lamha location system should not require it to be running.

---

# 17. Dawarich Database as the Source of Truth

## REMOVE

Do not make Dawarich's database the authoritative archive.

Do not depend on:

- Dawarich-specific database records being the sole copy of history.
- Dawarich-specific IDs as permanent Lamha identities.
- A Dawarich database being required to recover visits, places, routes or journeys.

Lamha's direction is durable, application-independent files plus Lamha's own derived/indexed database where appropriate.

---

# 18. Database-Only Location History

## REMOVE

Do not allow location history to exist only inside an opaque application database.

Specifically reject an architecture where losing the app/database means losing:

- Daily movement.
- Coordinates.
- Routes.
- Visits.
- Places.
- Place reviews.
- Journey history.

The durable JSON/Markdown/archive representation remains a Lamha requirement.

---

# 19. Dawarich Insights as a Separate Product Surface

## REMOVE AS A SEPARATE SUBSYSTEM

Do not port an independent Dawarich Insights product/page merely because it exists.

Useful factual geographic statistics may still be derived inside Lamha, such as:

- Most visited places.
- Time spent in a city.
- Countries/cities visited.
- Distance traveled.

But they belong to Lamha's geographic-statistics experience rather than a copied Dawarich Insights subsystem.

---

# 20. Anything That Duplicates Lamha's Existing Domains

## REMOVE

Any Dawarich feature that creates a second competing version of a domain Lamha already owns is excluded.

Examples:

```text
Dawarich photos      → REMOVE; Lamha owns assets.
Dawarich people/users → REMOVE; Lamha owns people/provenance.
Dawarich trip journal → REMOVE; Lamha owns Journeys/Memories.
Dawarich map UI       → REMOVE; Lamha owns its map.
Dawarich notes        → REMOVE; Lamha owns archival notes/memories.
Dawarich app database → REMOVE; Lamha owns its canonical architecture.
```

The location subsystem must strengthen Lamha, not create a mini-Dawarich inside Lamha.

---

# 21. Features Explicitly Outside the Current Decision

The following should not quietly enter the Dawarich keep scope:

- Fog of War.
- Family sharing.
- Live tracking.
- Mobile tracking apps.
- Home Assistant tracking.
- OwnTracks live integration.
- GPSLogger integration.
- PhoneTrack integration.
- External photo managers.
- Dawarich Cloud.
- Multi-user location sharing.
- Full geofence/Areas system.
- Dawarich web UI.
- Dawarich deployment infrastructure.
- Dawarich authentication.
- Dawarich database.
- Dawarich API as a permanent dependency.
- Dawarich-specific Trip implementation.
- Dawarich-specific journaling/notes.
- Broad third-party importer ecosystem beyond the approved Google Timeline requirement.

If any of these are wanted later, they must be consciously reconsidered as a **new Lamha feature decision**, not inherited automatically from Dawarich.

---

# 22. Not Dawarich: Do Not Misclassify These as Removed

These are part of the Lamha plan and are **not** being removed merely because Dawarich does not provide them in the same form:

- Offline OpenStreetMap-based map downloads.
- Durable daily JSON + Markdown files.
- Durable Place JSON + Markdown files.
- Personal place ratings and reviews.
- Weather attached to historical day/location records.
- Lamha Events.
- Lamha People.
- Lamha media provenance.
- Lamha Memories.
- Lamha Journeys.
- Cross-midnight event/hangout handling.

They are Lamha-native requirements, not Dawarich features.

---

# FINAL REMOVE DECISION

The rule is:

```text
KEEP:
Dawarich's useful location-history processing intelligence.

REMOVE:
Dawarich as an application, server, account system, sharing system,
photo integration layer, UI, database, deployment stack, live tracker,
and any feature that duplicates Lamha.
```

Dawarich is a **reference/source of selected capabilities**, not a subsystem that survives inside the final Lamha architecture.
