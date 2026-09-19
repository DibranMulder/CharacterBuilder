# Tidekin SVG implementation — 2026-09-19

All 39 Tidekin maps now consume the reviewed SVG layouts rather than the earlier
independent platform arrangements. The world atlas uses the regional SVG's
geography and graph. The moodboard supplies the painted frog residents, Mireback
guardian, coastal furniture and dock surfaces; NPC rendering has no dependency
on the character builder.

Built-in imagegen assets: [resident atlas](../assets/npcs/tidekin/residents.png)
and [prop atlas](../assets/maps/tidekin/props.png). Final prompts and asset
provenance are recorded in the [resident notes](../assets/npcs/tidekin/README.md)
and [environment notes](../assets/maps/tidekin/README.md).

`tools/build_tidekin_runtime.py` reads the reviewed manifest without changing the
source SVGs. It maps their coordinates into the existing map widths and the
shared y=480 combat floor, with a 0.9 vertical scale. It compiles landings,
climb endpoints, furniture collision tops, water-care stations, portals,
scenery and atlas positions together. Existing encounter populations and
allegiance/quest gates remain in the runtime catalog.

## Traversal and life

- All 281 authored stairs, ladders and ropes support Up/Down traversal. Connector
  selection respects travel direction at shared landings and does not get
  displaced by furniture crossed during descent.
- All 531 jumpable furniture surfaces accept the ordinary jump. Upper galleries
  use their authored climb connections. The former regression's assumption that
  every tall gallery must be reachable solely by jumping no longer describes the
  SVG design; jump tests now cover furniture and separate tests cover every climb
  in both directions. Rendering budgets are unchanged.
- Every exit retains its SVG position, including elevated shrine entrances.
  Traveling arrives at the reciprocal portal with the camera positioned there
  immediately; recovery and test teleport use
  the map's sheltered floor anchor.
- Twenty-five residents use seven painted civilian/service silhouettes and the
  Mireback guardian. They breathe, face approaching heroes, pause for dialogue,
  and take short walks in clear floor spaces between props. Service, trade and
  investigation interactions remain functional. These are transform-animated
  paintings, not frame-by-frame walk-cycle sheets.
- Creatures and their effects are culled vertically as well as horizontally in
  high galleries, with their full visual margins. Hidden resident simulation continues while visual transforms are skipped;
  re-entry displays the current pose. Foreground scenery and prop commands live
  for one map. The shared atlases avoid per-frame mesh generation or uploads.
- The approved gold portal glow and hoverable icon hints remain visible. Painted
  backgrounds continue behind upper galleries; the atlas artwork and markers
  use the same SVG overview coordinates.

## Verification

Passed on the final implementation:

- `tools/map_layouts/validate.py`: reviewed SVG coverage and supported routes.
- `tests/tidekin_svg_regression.gd`: all 39 layouts, atlas edges, portal positions,
  reciprocal arrivals, 281 ascents and descents, safe returns, NPC routines and
  hidden/resumed sprite rendering without a builder rig or viewport.
- `tests/tidekin_height_regression.gd`: 531 furniture jumps and 39 floor returns.
- Tidekin playtest, town, save, level-balance and contact regressions.
- Offscreen rendering, world interactions, Up-portal input, world-map input/UI,
  You-marker, and cross-map testing teleport regressions.
- Tutorial retained-UI regression, rendered Chronicle panel, rendered map-opening
  test and graphical gameplay benchmark.

`tools/capture_tidekin_svg.gd` rendered all 39 maps, the atlas and NPC dialogue.
Inspected landing, market, guardian, shrine galleries, mangroves, storm coast,
confluence and atlas captures against the reference. The selected updated
screenshots are tracked as `artifacts/tidekin_updated_*.png`; the full regenerated
set is `artifacts/tidekin_svg_*.png` (ignored, reproducible).

## Matched performance

Godot 4.7.2, Compatibility/OpenGL, Apple M1, 1152×648, identical fixed-step
harness with VSync disabled only by the benchmark. Runs were sequential, with
no concurrent test loads. Raw before/after values are in
[tidekin-svg-performance.json](tidekin-svg-performance.json).

| Scenario | Mean ms before → after | p95 ms before → after | Mean draws before → after |
| --- | --- | --- | --- |
| Tidekin landing | 13.08 → 13.41 | 15.32 → 16.34 | 615.7 → 617.7 |
| Tidekin combat | 13.20 → 14.50 | 15.66 → 18.37 | 618.4 → 621.9 |
| Wendmere square | 19.66 → 15.02 | 24.92 → 17.14 | 811.3 → 811.8 |
| Training combat | 12.28 → 12.19 | 14.53 → 14.30 | 527.7 → 527.7 |
| Sparring | 15.67 → 13.53 | 21.58 → 15.30 | 620.1 → 620.0 |

The baseline failed its 20 ms p95 gate for Wendmere and sparring; the final run
passed all five scenarios. Unchanged scenes also varied, so those timing gains
cannot be attributed to Tidekin changes. This is not a stable 60 FPS claim:
some final p95 values still exceed the 16.7 ms frame budget. Tidekin texture
accounting increased from about 154 MiB to 183 MiB with the additional atlases
and foreground. This is not total application memory or a mobile validation.

The decorated panel remains at 13 draw calls. Map opening measured **100.7 ms
cold, 32.5 / 27.8 ms warm**, within the existing 250 / 150 ms budgets. No budget
was raised and no effect was removed to pass.

Existing production boundaries still apply: mechanical tides, full Regent
choreography, player Exchange listings and durable bank services are separate
from this SVG/layout and moodboard implementation.
