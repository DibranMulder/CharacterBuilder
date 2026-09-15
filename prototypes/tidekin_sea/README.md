# Tidekin Sea playable region

Run the project to spawn at Tidewharf Landing, or select **Tidekin Sea** in the builder. The region contains all 39 connected maps from [DESIGN-0023](../../docs/game/0023-tidekin-sea-region.md), using eight painted environment kits and all sixteen creature designs. These are playable prototype encounters; the design document remains the target for final content and balance.

**A/D** move, **Space** jumps, **J** attacks, **Shift** guards, **H** heals, **E** uses nearby ground-light exits or tends a marked channel. **M** opens the current regional atlas; **World** navigates outward. Unvisited maps stay under fog. **Esc** opens the menu and Builder. **R** recovers at the current map's refuge.

Stand on a portal and press **Up** to travel. **E** handles water-care and other interactions. The landing connects the village, starter coast and higher-level return routes; inspect the map levels before choosing a route. Citadel access respects allegiance. Completing the landing's three water-care stations opens the shrine investigation. The longer named-NPC quest, trading services and mechanical tides from the design are not implemented yet.

Combat maps contain six regular creatures, spaced along the combat lane outside arrival refuges. Each defeated creature returns after **30 seconds**, with a **two-second warning** when the map is occupied. Spawns wait while the hero is within **240 px**. Timers keep running in previously visited maps during active play, so neighboring-map farming loops work. Each new defeat awards XP and loot. Helpful species are noncombat aid encounters; Crowncrabs attack only after provocation. The optional Undertow Regent does not respawn during a session.

Thirteen maps have tall routes, rising up to 640 px above the floor. Other maps mix low reef ledges, five-platform routes and open paths. Upper water-care objectives reward exploration; all rises fit an ordinary jump. Every route retains a safe floor beneath it, and recovery stays on the same map. Three-station jobs can be repeated after 90 seconds on the active map.

The sixteen cleaned PNGs are single poses, with runtime facing and hit feedback; they are not frame-animated sprite sheets. Enemy attacks have visible windup, attack areas and recovery. Late-level tuning and the Regent's complete encounter choreography still need playtesting. Tide display/water are cosmetic. Progress and farming populations persist between maps during the current session; restarting the application starts a fresh Tidekin session and does not alter Wendmere saves.

Checks:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/tidekin_playtest_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/tidekin_height_regression.gd
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tools/capture_height_routes.gd
```

Data: [runtime map and creature catalog](region.json), [base art prompts](../../assets/maps/tidekin/prompts.json), [expanded environment prompts](../../assets/maps/tidekin/expansion-prompts.json), [creature manifest](../../assets/monsters/tidekin/manifest.json).

World hints show icons; hover for text, or tap to toggle on touch. The atlas has **Teleport here (test)** for jumping directly to any playable map.
