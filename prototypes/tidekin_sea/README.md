# Tidekin Sea playable region

Run the project to spawn at Tidewharf Landing, or select **Tidekin Sea** in the builder. The region contains all 39 connected maps from [DESIGN-0023](../../docs/game/0023-tidekin-sea-region.md), using eight painted environment kits and all sixteen creature designs. These are playable prototype encounters; the design document remains the target for final content and balance.

**A/D** move, **Space** jumps, **J** attacks, **Shift** guards, **H** heals, **E** talks to residents or tends a marked channel. **M** opens the current regional atlas; **World** navigates outward. Unvisited maps stay under fog. **Esc** opens the menu and Builder. **R** recovers at the current map's refuge.

Stand on a portal and press **Up** to travel. **E** handles water-care and other interactions. The landing connects the village, starter coast and higher-level return routes; inspect the map levels before choosing a route. Citadel access respects allegiance. Tidewharf now has 25 residents: the named regional NPCs, six class trainers, shops, a wandwright, broker, quartermaster and sentries. Vendors use the shared purchase/sale system; trainers open skills, and the innkeeper opens the Hero overview. The broker and quartermaster explain their future Exchange and bank services. Mechanical tides remain a separate prototype limitation.

Combat maps contain six regular creatures, spaced along the combat lane outside arrival refuges. Each defeated creature returns after **30 seconds**, with a **two-second warning** when the map is occupied. Spawns wait while the hero is within **240 px**. Timers keep running in previously visited maps during active play, so neighboring-map farming loops work. Each new defeat awards XP and loot. Helpful species are noncombat aid encounters; Crowncrabs attack only after provocation. The optional Undertow Regent does not respawn during a session.

All 39 maps now use the reviewed SVGs' landings, furniture, stairs, ladders,
ropes and portal locations. **Up/Down** climbs while beside a connector; **Space**
jumps onto crates, benches and other furniture. There are 281 supported climbs
and 531 jumpable props. Town and wilderness walking routes retain a continuous
safe floor beneath the galleries. Ordinary travel arrives at the matching portal
in the destination, including raised shrine entrances; **R** returns to the
map's sheltered recovery anchor. The atlas uses the SVG regional overview's
positions and exact connections.

Residents use new moodboard-derived frog townspeople paintings and a moss-backed
Mireback guardian, independently of the character builder. Residents take short
walks within clear work areas, breathe, turn toward approaching heroes, and stop
for conversations. Hidden residents continue their simulation but skip visual
updates. Props and dock surfaces use a matching painted atlas. Map-lifetime
retained scenery avoids rebuilding geometry each frame. Upper galleries retain
the painted coastal or submerged background.

The sixteen cleaned PNGs are single poses, with runtime facing and hit feedback; they are not frame-animated sprite sheets. Enemy attacks use body anticipation, thin ground brackets and coral/cyan strikes instead of filled yellow hitboxes. Equal-level Common enemies generally take 4–6 ordinary reference hits. A five-level cohort remains approachable; resistance increases beyond it, and monsters at least 25 levels above the Hero cannot be damaged or controlled by the Hero. Their attacks become substantially more dangerous. The Regent's complete encounter choreography remains a separate prototype limitation. Tide display/water are cosmetic. Separate per-Lineage Tidekin checkpoints retain current map and position, inventory, progression, visited populations, repairs, quest state and lens consumption across application restarts. Saves occur on map transfer, story actions, every ten active seconds and scene exit. They do not alter Wendmere saves. SceneTree test harnesses do not read or write player checkpoints.

Checks:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/tidekin_playtest_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/tidekin_height_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tools/capture_height_routes.gd
```

Data: [runtime map and creature catalog](region.json), [base art prompts](../../assets/maps/tidekin/prompts.json), [expanded environment prompts](../../assets/maps/tidekin/expansion-prompts.json), [creature manifest](../../assets/monsters/tidekin/manifest.json).

World hints show icons; hover for text, or tap to toggle on touch. The atlas has **Teleport here (test)** for jumping directly to any playable map.

## The Salt in the Wells

Talk to Sera in Tidal Lagoon, then clear all three runnels in Siltbank Shallows. Bring the sample to Mero in Cistern Works, obtain Coru's rubbing in Deepvault, and show both records to Amaya in Pearl Hall. Her authorization opens the Light-only shrine route. Repair the three Flooded Nave sluices, align **Shell → Wave → Pearl** in the Coral Reliquary, install the unique lens in the Pearl Sanctum, and report to Sera. The lens and completion reward cannot be duplicated. Landing chores no longer bypass the investigation.

Additional regressions: `tests/tidekin_town_regression.gd`, `tests/tidekin_save_regression.gd`, `tests/tidekin_level_balance_regression.gd`, and `tests/tidekin_contact_regression.gd`. Rendered review captures come from `tools/capture_tidekin_town.gd`.


SVG integration checks: `tests/tidekin_svg_regression.gd` verifies all 39 source
layouts, atlas edges, portal positions, reciprocal arrivals, climbing in both
directions, safe floor returns and resident culling/routines.
`tests/tidekin_height_regression.gd` verifies ordinary jumps onto every authored
jumpable prop. Rebuild scenery/data with `python3 tools/build_tidekin_runtime.py`.
Capture all maps and the atlas with `tools/capture_tidekin_svg.gd`.

Implementation, image-generation provenance and matched performance evidence:
[SVG implementation review](../../docs/tidekin-svg-review.md).
