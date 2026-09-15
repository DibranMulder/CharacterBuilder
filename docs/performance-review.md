# Gameplay performance review — 2026-09-15

## Outcome

Rendering was the main bottleneck. These changes reduced mean frame time by 42–65% in five local scenarios. Smooth 60 FPS is not yet assured: two scenarios still exceeded the benchmark's 20 ms p95 budget (60 FPS needs 16.7 ms per frame).

## Changes

- Batch decorative panel grain into one triangle command instead of up to 600 circle commands. Cache geometry in a bounded 32-entry cache; draw commands own their array data so eviction cannot invalidate displayed geometry. Keep the seeded grain pattern, colors, and borders.
- Skip offscreen portal and creature rendering in Tidekin, and offscreen portals in training.
- Stop rebuilding Rowan's animated mesh while hidden. Keep animation time and game simulation advancing; resume mesh updates when visible. Include camera visibility in the hometown override.

A standalone decorated panel went from 612 to 13 draw calls. The offscreen NPC regression failed before the fix and passes afterward. Portal glow itself is unchanged.

## Matched measurements

Apple M1, macOS, Godot 4.7.2, Compatibility/OpenGL renderer, 1152×648 window, VSync disabled in the harness only. Both versions used the same harness; baseline runtime files came from commit `82288a5` and were restored immediately afterward. Runs were sequential. Each scenario uses 120 fixed 1/60-second simulation updates with scripted movement/attacks, discards 30 warmup frames, then records 90 frames. Explicit rendering avoids window-occlusion stalls.

Frame timings are wall-clock frame costs including process-frame scheduling and forced rendering, not isolated GPU timestamps. These short scenarios are smoke benchmarks, not exhaustive boss fights or long-session/mobile profiling. Draw-call reductions are more stable than wall-clock timing on a shared machine.

| Scenario | Mean frame ms, before → after | p95 frame ms, before → after | Mean draw calls, before → after |
| --- | --- | --- | --- |
| tidekin_landing | 35.7 → 16.2 | 39.1 → 18.5 | 1563 → 717 |
| tidekin_combat | 31.3 → 18.0 | 34.0 → 20.7 | 1398 → 633 |
| wendmere_square | 38.9 → 19.3 | 42.1 → 22.0 | 2605 → 811 |
| training_combat | 29.1 → 14.2 | 31.0 → 15.9 | 1268 → 528 |
| sparring | 38.7 → 13.6 | 42.6 → 16.1 | 1540 → 620 |

## Remaining limits

- The full gameplay benchmark still reports a budget failure; Tidekin combat and Wendmere p95 are above 20 ms. Do not interpret the gains as a locked 60 FPS guarantee.
- World-map opening measured 315 ms initially (above its 250 ms budget), then 36 and 56 ms (within the 150 ms warm budget). This used the existing map test with explicit forced rendering to avoid occlusion stalls. Initial atlas loading remains a follow-up optimization target.
- Reported texture memory across these scenes is approximately 153–184 MiB. This is renderer texture accounting, not total process memory, and does not establish mobile suitability.
- Visible character/Rowan rendering still has measurable cost. A larger rig/shader rewrite was not needed for these improvements.

## Validation

Passed: decorated-panel rendering budget; offscreen rendering regression; shared Chronicle UI; Rowan life and trading; tutorial steady-state performance; Tidekin playtest; world interactions; arena combat regression. Inspected a rendered hometown capture: UI frames, visible NPCs, icon hints, and bright portal glow remain intact.

Run gameplay measurements with a graphics display:

```sh
Godot --path . --script tools/benchmark_gameplay.gd -- /tmp/gameplay-performance.json
Godot --path . --script tests/chronicle_render_performance.gd
Godot --headless --path . --script tests/offscreen_render_regression.gd
```

The gameplay harness exits nonzero if any scenario exceeds 20 ms p95. Keep timing checks separate from other test processes to reduce contention. Raw paired results are in `artifacts/performance-review.json`.
