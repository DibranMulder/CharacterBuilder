---
id: DESIGN-0024
title: Region presentation and playability checklist
status: implementation-checklist
updated: 2026-09-13
---

# Rules to check for every region

Apply this checklist when adding a region, changing its map or producing its art. A painted map or creature sprite does not make an encounter playable. Record map presentation, art readiness and gameplay readiness separately.

## Map opening and navigation

- [ ] **M** and the Map button open the hero's current **whole region**, with the current map selected. They do not start at the world overview or zoom straight into a building.
- [ ] Opening from an uncharted training scene falls back to Open Lands without inventing a current-map marker.
- [ ] **World** and zooming below the region minimum open the world overview. Region selection then returns to the chosen region.
- [ ] **You** selects and frames the actual current map. **Fit**, +/−, wheel zoom and drag pan work after every navigation step.
- [ ] Closing with M, Escape or Close restores the prior pause state. Inventory, skills and movement cannot operate behind the open atlas.
- [ ] Opening, zooming, selecting or inspecting a map never teleports the hero, completes a quest or grants exploration.
- [ ] Any explicit travel action is limited to discovered playable destinations and checks allegiance and quest restrictions at the travel controller.

## Geography and discovery

- [ ] Region ID, map IDs, names, village, stronghold, story site and routes match the authored catalog and region design.
- [ ] Every playable map has an exact runtime-to-atlas mapping. The current marker moves correctly after a physical portal crossing.
- [ ] Every path shown by the interactive graph uses catalog edges; the background illustration never defines navigation or collision.
- [ ] Unvisited maps retain mist and an Unexplored state. Physical visits reveal only the visited map; browsing never removes fog.
- [ ] Public names and connections may remain visible under mist; undisclosed secrets must not be added to this public catalog.
- [ ] Unbuilt maps explicitly say they are not open for play. Peaceful locations are not presented as combat maps.
- [ ] Level ranges and enemy names, when displayed, come from implemented encounter data. Do not present proposed balance as verified runtime statistics.

## Region-map artwork

- [ ] Each region has its own project-local PNG in `assets/maps/regions/`, plus an exact prompt and reference entry in the manifest.
- [ ] Use the approved regional moodboard. Frontier interpretations name their reference and remain clearly identified as interpretations where no dedicated board exists.
- [ ] The PNG is a high-angle regional terrain illustration, not a side-scrolling gameplay backdrop, poster, moodboard, screenshot or unlabeled placeholder rectangle.
- [ ] Do not bake location names, buttons, routes, level numbers, fog or selection markers into the PNG. Those belong to the interactive UI.
- [ ] Terrain, architecture, materials and palette identify the region. Use the theme table below; shared controls keep their familiar placement.
- [ ] Map pins are anchored to recognizable features of the terrain painting, not arranged in boxed diagrams. Landmark headings and zoom-dependent labels stay readable over bright and dark terrain.
- [ ] Check whole-region, village, stronghold and story/dungeon focus at 1152×648. No marker overlap, cropped labels, unreadable routes or clipped buttons.
- [ ] Verify World → region → group → World repeatedly. Inspect all 12 regions, not only the starting one.

## Gameplay scenery and portals

- [ ] Playable backgrounds are generated painted environments based on the region moodboard, matching the hometown's rendering style.
- [ ] Align the observed painted walking surface with the simulation floor; check both map edges, platforms, camera movement and jumping.
- [ ] Keep characters, monsters, hints, effects and portals separate from the background painting.
- [ ] Portals use soft ground light; restricted entrances use subdued amber plus a clear reason. Do not replace them with glowing doorway arches.
- [ ] Both portal directions work, arriving outside the receiving trigger with a safe standing area. No immediate bounce-back.
- [ ] Death and reload recover on the same map. Unexplored art and unavailable destinations never become travel shortcuts.
- [ ] Ordinary routes work with every supported body type and movement kit. Optional hazards or encounters cannot block the required return path.

## Height and farming

- [ ] Mix flat roads with low platforms and tall routes suited to local architecture; place a useful objective or reward upstairs.
- [ ] Simulate every raised exit and reward using ordinary jump/gravity/collision rules; visual proximity alone does not prove reachability.
- [ ] Keep a safe return route, verify ladder ascent/descent, and cover the highest camera view with painted scenery.
- [ ] Combat maps support a repeatable farming loop with documented spawn density and respawn interval.
- [ ] Respawns never occur on top of the player; show a return warning and keep portal arrival areas clear.
- [ ] Timers continue in previously visited maps during active play; pause freezes the loop.
- [ ] Each new defeat rewards the player once. Dead bodies cannot be harvested repeatedly.
- [ ] Helpful/neutral wildlife and optional bosses keep their authored behavior instead of joining generic hostile farming spawns.

## Monsters and wildlife

- [ ] Expand the regional art direction with a separate creature moodboard. Preserve the original settlement/culture board.
- [ ] Use authored species names, level cohorts, dispositions and roles. Benevolent wildlife stays helpful; neutral wildlife is not automatically aggressive.
- [ ] Each creature has a distinct silhouette and attack anatomy that match its design. Materials and palette agree with the regional board.
- [ ] Sprite exports have **real alpha transparency**. A visible checkerboard is an export failure, not transparency; inspect the PNG's alpha channel and composite it over actual scenery.
- [ ] Sprites contain no labels, frames, environment fragments or neighboring creatures. Every atlas region has adequate margins and a documented pivot.
- [ ] Validate facing, feet/hover height, visible scale, hit flashes, telegraph, attack and recovery against actual hitboxes. Mirroring must not change damage direction.
- [ ] Keep telegraphs and interaction icons legible against the finished painted background. Hostile attacks, helpful wildlife, traders and quest contacts must be distinguishable.
- [ ] A static sprite is an art asset, not a complete animation set. Record which creatures have runtime behavior, which have static art only and which need animation work.
- [ ] Defeat, reward, aid completion, respawn and save behavior are checked independently of sprite appearance.

## Theme reference by region

| Region | Palette and defining terrain/materials | Reference | Extra visual check |
| --- | --- | --- | --- |
| Open Lands | Field green, ivory, royal blue, brass; orchards, roads and castles | `humans-v2.png` | Wendmere's familiar village and keep identity remains recognizable |
| Tidekin Sea | Teal, sea green, pearl, coral, bronze; channels, shell docks, reef and kelp | `tidekin.png` | Water never hides the current marker or merges with route highlights |
| Elder Forests | Fern green, bark brown, bronze; canopy, roots and Heartgrove | `grove-centaurs.png` | Dense foliage does not swallow paths or settlement markers |
| Sky Reaches | Cloud ivory, blue, lavender, gold; floating islands, bridges and observatory | `aeralith.png` | Pale clouds retain enough contrast behind text and mist |
| Broken Mountains | Slate, basalt, iron, forge amber; quarries, hoists and mountain passes | `crag-trolls.png` | Passes and stronghold groups remain readable against crags |
| Underdeep | Soot, copper, violet, cavern cyan; tunnels, rails, mushrooms and gears | `deep-goblins.png` | Underground scene stays bright enough for fog and route distinctions |
| Ember Desert | Sandstone, ember red, turquoise, bronze; dunes, oasis and aqueducts | `sunscour.png` | Bright sand does not wash out level labels or border highlights |
| Ice Lands | Midnight blue, glacial blue, white, aurora green, hearth amber | `rimeborn.png` | Snow, unexplored mist and explored highlights remain distinguishable |
| Shattered March | Sandstone, lapis, tarnished gold, marsh green; Babylon ruins and broken canals | `babylon.png` | Use the approved board, not the rejected Babylon v2 style experiment |
| Gloamfen | Moss teal, peat, silver; drowned reeds and mirror pools | Tidekin-derived frontier interpretation | Looks like a marsh frontier, not a copy of Tidewharf |
| Ashen Scar | Charcoal, rust, muted gold; volcanic gullies, fissures and Cinder Vault | Crag-derived frontier interpretation | Lava remains a background motif, not a false selectable route |
| Verdant Maw | Dark green, ochre; strangler vines, coil roots and buried ruins | Grove-derived frontier interpretation | Distinct wild overgrowth rather than a peaceful forest settlement |

## Verification record

For a region change, record the date, tested revision, region/current-map pair, explored-map fixture, viewport size, screenshots and check results. Leave untested boxes unchecked. Do not mark all gameplay gates passed because atlas tests pass.

```sh
python3 tools/check_world_atlas.py
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/world_atlas_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/world_map_input_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/world_map_ui_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/hometown_map_travel_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/tidekin_playtest_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tools/capture_world_atlas.gd
```

Related: [world plan](0022-world-map-level-plan.md), [Tidekin region design](0023-tidekin-sea-region.md), [atlas implementation](../../src/world/README.md), [regional moodboards](../../designs/moodboards/README.md).
