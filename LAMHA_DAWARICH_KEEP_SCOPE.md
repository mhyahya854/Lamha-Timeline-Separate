# Lamha — Dawarich KEEP Scope

**Status:** Canonical scope decision  
**Purpose:** Define exactly which Dawarich capabilities Lamha will retain/adapt.  
**Rule:** We are keeping selected **location-history capabilities**, not Dawarich as a product, UI, database, server stack, or permanent dependency.

---

# 1. Google Maps Timeline Importer

## KEEP

Lamha will retain/adapt the Google Maps Timeline import capability so historical location data can be moved out of Google and into Lamha.

The importer must support:

- Google Maps / Google Timeline exports used by Dawarich.
- Detection of relevant Google Timeline export structures rather than assuming one fixed format.
- Importing historical location records from Google Timeline.
- Importing more than once over time.
- Recognizing already-imported location data so repeat imports do not create uncontrolled duplicates.
- Preserving enough source metadata to identify where imported records came from.
- Import verification before the user decides whether to delete the corresponding history from Google.
- Safe handling of partial, malformed, unsupported, or wrong Google export files.
- Preservation of the original imported source data or an equivalent recoverable raw representation.

## LAMHA-SPECIFIC RESULT

The Google import becomes part of Lamha's own archival model.

Example:

```text
Google Timeline Export
        ↓
Lamha Import
        ↓
Raw Imported Location Evidence
        ↓
Cleanup / Normalization
        ↓
Canonical Location History
        ↓
Days / Visits / Places / Routes / Journeys
```

The user may repeat this process whenever a new Google Timeline export is available.

---

# 2. Location Cleanup and Normalization

## KEEP

Lamha will retain/adapt Dawarich-style location cleanup and normalization.

This includes:

- Duplicate-point detection.
- Duplicate-record detection across repeated imports.
- Timestamp normalization.
- Coordinate normalization.
- Ordering records chronologically.
- Handling overlapping imports.
- Handling low-quality or suspicious GPS points.
- Detecting obviously impossible jumps or movement.
- Avoiding silent corruption of location history.
- Creating a cleaned/canonical timeline from imported evidence.

## ARCHIVAL RULE

Raw imported evidence must not be silently destroyed just because a cleaned version exists.

The system should conceptually retain:

```text
RAW LOCATION EVIDENCE
        ↓
CLEANED / CANONICAL LOCATION HISTORY
```

This allows future rebuilding if cleanup logic improves or an earlier interpretation was wrong.

---

# 3. Reverse Geocoding

## KEEP

Lamha will retain/adapt reverse-geocoding capability.

Coordinates can be translated into useful geographic information such as:

- Place name.
- Street/address information where available.
- Locality/neighborhood.
- City.
- Region/state/province.
- Country.
- Other geographic labels useful to the location archive.

## PERMANENCE RULE

Reverse geocoding must never replace the original coordinates.

A durable Lamha location/place record must preserve:

```text
Coordinates
+ Place name
+ Address / locality
+ City / region / country
+ Any later user corrections
```

Coordinates remain the durable geographic anchor even if external place names, businesses, addresses, or geocoding services change.

---

# 4. Visit Detection

## KEEP

Lamha will retain/adapt Dawarich's visit-detection concept.

Location points should be interpretable as meaningful stays.

Example:

```text
Raw GPS points
      ↓
Possible Visit
      ↓
Cafe
14:20–16:05
```

Visit detection should support:

- Start time.
- End time.
- Duration.
- Coordinates / geographic center.
- Associated source points.
- Suggested place association.
- Confidence or equivalent uncertainty information.
- User confirmation.
- User correction.
- User rejection where the detected visit is wrong.

## IMPORTANT

Detected visits are not automatically authoritative merely because an algorithm produced them.

Lamha should be able to distinguish between:

- Suggested.
- Confirmed.
- Corrected.
- Rejected / ignored.

---

# 5. Place Detection and Place Association

## KEEP

Lamha will retain/adapt the ability to associate visits with real-world places.

A place may contain:

- Stable Lamha place identity.
- Coordinates.
- Name.
- Address.
- City.
- Region.
- Country.
- Category/type.
- Visit history.
- First visit.
- Most recent visit.
- Number of visits.

## LAMHA EXTENSION

Lamha will store additional personal information independently of Dawarich, including:

- Personal rating.
- Personal review.
- Personal opinion.
- Notes.
- Memories associated with the place.
- Relevant people.
- Relevant events.
- Relevant journeys.
- Relevant photos/videos through Lamha's own media model.

## APP-INDEPENDENT STORAGE

Each meaningful saved place must be able to exist independently of the Lamha application through durable files such as:

```text
Places/
└── Country/
    └── City/
        └── Place/
            ├── place.json
            └── place.md
```

The exact final filesystem layout can be refined later, but the durability requirement is locked.

---

# 6. Route and Movement Reconstruction

## KEEP

Lamha will retain/adapt the ability to reconstruct movement between visits/places.

This includes:

- Chronological paths.
- Movement segments.
- Start and end times.
- Start and end locations.
- Route geometry when available.
- Distance.
- Duration.
- Transportation/activity information when present or reliably inferable from imported data.
- Connections between one visit/place and the next.

Example:

```text
Home
 ↓ drive
University
 ↓ walk
Cafe
 ↓ drive
Mall
 ↓ drive
Home
```

Routes are part of the durable life-location archive and must not exist only as ephemeral visual lines in a database-backed map UI.

---

# 7. Trips — Capability Kept, Dawarich Product Model Replaced

## KEEP THE CONCEPT AND GEOGRAPHIC LOGIC

Lamha retains the useful Dawarich trip capability:

- Select/group a date range.
- Visualize travel during that period.
- Show routes.
- Show places.
- Calculate distance.
- Calculate time spent.
- Summarize countries/cities/locations involved.

## REPLACE WITH LAMHA JOURNEYS

The final Lamha concept is **Journey**, not a direct copy of Dawarich's Trip model or Trip UI.

A Lamha Journey may connect:

- Dates.
- Countries.
- Cities.
- Places.
- Visits.
- Routes.
- Events.
- People.
- Photos.
- Videos.
- Memories.
- Notes/reviews where appropriate.
- Geographic statistics.

Example:

```text
Journey: Istanbul 2026
│
├── Days
├── Places
├── Visits
├── Routes
├── Events
├── People
├── Photos / Videos
└── Memories
```

A normal day or hangout does not need to become a Journey.

---

# 8. Geographic Statistics

## KEEP

Lamha will retain/adapt Dawarich-style geographic statistics generated from the user's location history.

This includes useful statistics such as:

- Countries visited.
- Cities visited.
- Places visited.
- Distance traveled.
- Time spent.
- Time spent by city/country where derivable.
- Days spent in countries.
- Statistics by year.
- Statistics by month.
- Travel history over time.
- Most visited places where useful.
- Other directly derived geographic summaries that use the same underlying location archive.

The statistics layer is derived from the permanent location archive. It must not become the only place where the underlying information exists.

---

# 9. Limited Saved Locations / Minimal Geofence Concept

## KEEP — REDUCED VERSION ONLY

We do **not** retain Dawarich's full geofencing/area-management feature.

We keep only the useful concept of deliberately saving important locations.

Examples:

- Home.
- University.
- Hospital.
- Grandma's house.
- Workplace.
- Airport.
- Frequently visited location.

A saved location may contain:

- Name.
- Coordinates.
- Optional radius/tolerance for matching nearby GPS points.
- User-defined category or label.
- Personal metadata as supported by Lamha.

The purpose is simple location recognition and saving — not an advanced automation/geofencing system.

---

# 10. Durable Day-Based Location Archive

## KEEP AS A LAMHA REQUIREMENT BUILT AROUND THE DAWARICH-DERIVED DATA

Every day with location history should be able to exist independently of the application.

Preferred archival representation:

```text
YYYY/
└── MM/
    └── YYYY-MM-DD/
        ├── day.json
        ├── day.md
        └── route / related durable data
```

The exact folder layout can be refined, but the principle is fixed:

- JSON provides structured machine-readable data.
- Markdown provides human-readable durable data.
- The app database/index is not the only source of truth.

## MIDNIGHT RULE

Calendar days are storage/timeline containers.

Real experiences do not have to end at midnight.

A hangout/event may start on one date and finish after midnight on the next date while remaining one coherent event.

---

# 11. Dawarich Behaviors We Are Retaining as Design Principles

The following behavioral ideas are retained wherever they support the features above:

- Location imports can be repeated.
- Imported records must be deduplicated/reconciled.
- Location evidence is chronological.
- Visits can be suggested rather than automatically treated as unquestionable truth.
- Places are connected to visits.
- Routes connect movement over time.
- Geographic statistics are derived from the same canonical history.
- Original coordinates remain available.
- Location processing should be rebuildable from durable source information.

---

# 12. Explicit Boundary

What we are keeping from Dawarich is essentially:

```text
DAWARICH LOCATION-HISTORY INTELLIGENCE
│
├── Google Timeline import
├── repeat-import handling
├── import/source detection needed for Google Timeline
├── location cleanup
├── normalization
├── deduplication
├── reverse geocoding
├── visit detection
├── place association
├── route reconstruction
├── movement / transportation information
├── trip geographic logic
├── geographic statistics
└── minimal saved-location matching
```

Everything is re-expressed inside Lamha's own architecture and durable-file philosophy.

We are **not** keeping Dawarich as a permanent application or dependency.

---

# 13. Important Lamha Additions That Are NOT Dawarich Features

These belong to the final Lamha plan but should not be misidentified as Dawarich features:

- Offline OpenStreetMap-based map downloads.
- Day folders with JSON + Markdown.
- Permanent Place JSON + Markdown.
- Personal place reviews/opinions.
- Lamha Events.
- Lamha People.
- Lamha photo/video ownership and provenance.
- Weather stored with relevant historical day/location data.
- Lamha Memories.
- Lamha Journey integration with photos, people and events.

These are Lamha-native additions around the Dawarich capabilities retained above.

---

# FINAL KEEP DECISION

**Keep Dawarich's location import, cleanup, interpretation, visit/place/route logic, trip geography, geographic statistics, and a very small saved-location concept.**

**Rebuild/adapt those capabilities inside Lamha rather than preserving Dawarich itself.**
