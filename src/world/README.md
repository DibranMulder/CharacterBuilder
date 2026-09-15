# The Veiled Realms atlas

**M** or **Map · M** opens the current region in hometown, Tidekin and training scenes, with the current map selected when charted. Uncharted training falls back to Open Lands. Use **World** to navigate outward. **P** defaults to a mana potion; **Bindings · B** configures actions and potions. The world overview shows eight homelands, four neutral frontiers, all eight strongholds, four dungeon sites, and fifteen connecting roads. It uses the existing `designs/design-0015-world-map-v2-kids.png` illustration.

Select a region to read its roads and sites. Double-click it or choose **Open region** to inspect its submaps. **Inside stronghold**, **Story site / Dungeon depths**, and the region's site headings zoom into their locations on the terrain. Scroll or use +/− to zoom, drag to pan, **Fit** to frame the chart, **World** to return to the overview, and **You** to find the current map. Zooming out past the region's minimum returns to the world; zooming into a selected world region opens it.

The atlas is a chart, not a level loader. Public geography stays visible so every region can be browsed. Mist and muted markers indicate unexplored maps; names, access, and connections can be inspected without granting discovery. No secret locations are included. Existing saved hometown/training visits supply exploration state. The existing hometown travel feature is an explicit **Travel to discovered map** action, available only for visited playable hometown maps and subject to the existing quest/allegiance gates. Ordinary clicks and double-clicks only navigate or inspect the atlas.

`atlas.json` contains 210 public submap entries:

- Twenty-two playable Tidekin wilderness additions from DESIGN-0023.
- 127 hometown maps and their exact portal graphs from DESIGN-0014.
- The four currently playable training maps in Open Lands.
- 57 frontier entries: the two named seam approaches per frontier; Babylon's five city maps; and an entrance plus ten consecutive depths in each of four dungeons.

The 15 world roads follow DESIGN-0015. Labels for its seven unnamed homeland connections are descriptive working names. The three non-Babylon dungeons use numbered depth placeholders because their rooms have no authored names. The atlas does not create scenes, collision geometry or encounters. Access requirements are displayed independently from chart visibility.

`region_layouts.json` anchors every map to normalized coordinates on its region painting. `world_catalog.gd` provides cached geography lookup and terrain positions. `src/ui/world_map.gd` owns selection, navigation, zoom, and input. `world_map_chart.gd` paints the terrain, curved catalog routes and exploration mist. `world_map_marker.gd` draws compact pins with labels that stay readable while zooming. Hometown's `town_map.gd` remains a thin alias for older entry points.

## Verification

```sh
python3 tools/check_world_atlas.py
godot --headless --path . --script res://tests/world_atlas_regression.gd
godot --headless --path . --script res://tests/world_map_input_regression.gd
godot --headless --path . --script res://tests/world_map_ui_regression.gd
godot --headless --path . --script res://tests/hometown_map_travel_regression.gd
godot --path . --script res://tools/capture_world_atlas.gd
```

The capture produces `artifacts/world_atlas.png`, twelve `region_*.png`, eight `stronghold_*.png`, and `babylon_depths.png`.

The [detailed map and monster-level proposal](../../docs/game/0022-world-map-level-plan.md) expands the 188 atlas entries into a reviewable 408-map, level 1–120 plan in Markdown/Mermaid. Most additions and level assignments remain proposals; all 39 Tidekin maps are now charted and playable in the regional prototype.

The next region is developed in the [Tidekin Sea design](../../docs/game/0023-tidekin-sea-region.md): all 39 maps, creatures and attack patterns, tide-safe routes, a shrine quest and an optional finale. All 39 Tidekin maps have connected prototype encounters with all sixteen creatures and mixed-height routes. Final quest content, tides and encounter polish remain planned.

Regional PNG backgrounds live in `assets/maps/regions/`; `region_art.gd` supplies per-region colors without mutating the shared Chronicle theme. The [region quality checklist](../../docs/game/0024-region-quality-rules.md) defines the required presentation and gameplay checks.

## Terrain atlas and opening performance — 2026-09-15

All twelve region layouts use their painted landmarks: settlements surround the
illustrated village, stronghold rooms sit over the keep, and story locations
follow the shrine, tower or ruin. There are no boxed group diagrams. Region
landmark headings focus the same terrain; individual map names appear on zoom
or selection, with overlap suppression. Crossings sit toward neighboring regions
and avoid landmark headings. The underlying catalog connections, discovery and
explicit travel gates remain authoritative.

The opening delay was reproduced by timing the actual gameplay M action through
`RenderingServer.frame_post_draw`, rather than timing control creation alone.
On the local Apple M1, the original first frame took 784 ms and repeated opens
388–441 ms. Removing decorated marker frames in a diagnostic probe roughly
halved the delay. Compact pins and atlas frames without procedural grain reduced
the first open to 133–189 ms and repeats to 42–68 ms across verification runs.
Regional themes share font resources and duplicate only the styles they modify.
The rest of the game's Chronicle frames retain their texture.

Run `godot --path . --script tests/world_map_open_performance.gd` **with a graphics
display** to measure the complete first-frame latency (250 ms cold / 150 ms warm local budget).
Headless runs explicitly skip this rendering benchmark. Other atlas regressions
remain headless-compatible. Captures cover all twelve regions, eight strongholds
and Babylon's dungeon; timings depend on hardware and graphics drivers.

## Test teleport

Select an individual map pin, then **Teleport here (test)**. This explicit test
shortcut supports all 58 implemented maps (15 hometown, 39 Tidekin, four
training), bypassing discovery, adjacency, allegiance and quest entry gates.
The target scene loads at a safe recovery anchor, preserving gear, possessions,
progression and living-player resources. A dead character recovers on arrival.
The shortcut does not complete quests; unbuilt destinations are disabled.
Ordinary **Travel to discovered map** retains its existing rules.

`test_map_travel.gd` resolves supported destinations; the gameplay controller
carries the character across scenes and each scene chooses its safe spawn.
Regression checks: `tests/map_test_teleport_regression.gd` and
`tests/portal_up_input_regression.gd`. Physical portal travel uses **Up**;
**E** continues to handle NPCs and world interactions.
