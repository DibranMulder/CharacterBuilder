# Working on this game

Read `CONTEXT.md` for project terminology and `docs/performance-review.md` for
measured rendering bottlenecks and known remaining limits.

## Keep rendering inexpensive

- Batch decorative UI geometry. Do not reintroduce hundreds of individual
  circle or line commands for panel grain: one panel previously cost 612 draw
  calls; the batched version costs 13. Preserve the visible design.
- Cache reusable geometry with a bounded lifetime. Evicting a cache entry must
  not invalidate a resource still referenced by a retained draw command.
- Avoid rebuilding or uploading unchanged meshes every frame. Hidden NPCs
  should not rebuild animation meshes; resume rendering when they become visible.
- Cull offscreen portal and creature visuals with enough margin for their full
  glow, sprites, and effects. Check visibility overrides in derived scenes too.
- Keep simulation separate from visibility: offscreen combat, respawns, timers,
  and animation clocks must continue according to gameplay rules.
- Refresh retained UI and layouts when their displayed state changes. Avoid
  unnecessary redraws, repeated resource loading, and layout work in frame loops.
- Preserve the approved bright gold portal glow and icon hints with hover text
  when optimizing. Check rendered screenshots for visual regressions.

## Verify performance changes

- Measure before and after with the same harness, renderer, resolution, and
  scenario. Run timing benchmarks sequentially, without concurrent test loads.
- Use a graphics display for rendering measurements; headless tests cannot
  establish frame rate or GPU rendering cost. Keep benchmark-only rendering
  settings out of normal gameplay defaults.
- Record mean and p95 frame time, draw calls, and cold versus warm menu opening.
  Do not claim stable 60 FPS from an average alone: its frame budget is 16.7 ms.
- Run the relevant checks after rendering changes (replace `Godot` with the local
  executable):

  ```sh
  Godot --path . --script tools/benchmark_gameplay.gd -- /tmp/gameplay-performance.json
  Godot --path . --script tests/chronicle_render_performance.gd
  Godot --headless --path . --script tests/offscreen_render_regression.gd
  ```

- For UI or map changes, also check `tests/tutorial_performance_regression.gd`
  and the rendered `tests/world_map_open_performance.gd` as applicable. Run
  gameplay regressions for affected systems, especially when changing culling.
- Investigate budget failures; do not raise thresholds or remove effects merely
  to make checks pass. The documented baseline still has gameplay p95 and cold
  map-opening failures, so distinguish existing limits from new regressions and
  report unresolved failures explicitly.
