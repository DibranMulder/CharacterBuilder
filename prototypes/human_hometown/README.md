# Wendmere Crossroads, the King's Keep and the Princess's Tower

The fifteen Human hometown maps from [DESIGN-0014](../../docs/game/0014-hometown-maps.md), playable in the local Godot build. Choose **Human hometown** in the character builder, or launch:

```sh
godot --path . prototypes/human_hometown/human_hometown.tscn
```

The six village districts are Village Square, Market Row, Apothecary Lane, Trainers' Yard, Hearth Inn and Stronghold Approach. Six keep districts lead from Gatehouse Court through Warden Barracks and Service District to Great Hall, the King's Room, and Treasury and Archive. The quest opens Tower Base, Winding Stair, and the Solar. Every connection in the design's Human graph has a physical, reciprocal portal. Village Square retains its eastern Willow Trail connection.

Walk with A/D or arrows; jump with Space. Stand on a glowing portal and press **Up** to travel. Hover its arrow icon to see the destination. Raised side roads have successive 70-unit landings; the tower has ten ascending landings and an alternate rope. Use Up/Down to climb ladders and ropes. **E** talks, **M** opens the world atlas; open a region to inspect its maps, **I** opens the pouch, **L** opens skills, **H/P** use health/mana potions. The existing touch movement, jump and interaction buttons remain available. Training maps use the same M map and P mana shortcuts.

The Human moodboard guides thirteen new district paintings, a stone ledge sprite, a dedicated Waystone Guardian construct, and ambient Meadow Puffkins and Brookskip Otters. Existing square, market and veteran sentry artwork remains in use. The district art has individually aligned walking surfaces; visible landings and ropes share the simulation's coordinates.

## Residents and the tower story

The town has 33 named residents plus Elder Rowan and the roadside sentries. Brann, Tessa and Orin retain their working equipment shops. Six trainers represent Vanguard, Ravager, Ranger, Duelist, Arcanist and Warden and open the existing skill overview. The innkeeper opens the Hero overview. The broker, quartermaster, provisioner and apothecary explain their services; new Provisions have explicitly read-only catalogue previews. Fixed prices are local design values. This repository has no connected Exchange or server-owned economy, so no Exchange orders or stash deposits are offered.

Speak to **Elowen** in the square, then **Meriel** in the Archive, then **Captain Aldren** in the barracks. The captain's key opens the Great Hall's elevated tower portal. Climb to **Lyra** in the Solar and return her message to Elowen. The route remains open afterwards. Additional guards, couriers, stewards, cooks, smiths and attendants provide directions and hooks for further quest lines. A distant Hillkeep Gargoyle watches the outer wall as a future encounter hook; it does not attack the peaceful town route.

Outer districts welcome every lineage. The Waystone Guardian repels Dark-aligned heroes at the keep boundary; all keep and tower destinations enforce the same restriction. The tower also requires the story key. Travel requires a living, grounded hero with no active attack or projectiles, and menus prevent transfers. Arrivals stand outside portal triggers on supported landings.

Each human resident has a dedicated painted identity and a matching conversation portrait. The 32 figures are in six chroma-key sprite sheets, documented in [resident-prompts.json](../../assets/npcs/wendmere/resident-prompts.json). Elder Rowan, the sentries and the Waystone Guardian retain their dedicated artwork.

The [world atlas](../../src/world/README.md) opens at world scale, showing all twelve regions, eight strongholds, four dungeons and fifteen connecting roads. Select a region and open it to inspect its submaps. Site headings and **Inside stronghold** zoom into the internal graph. Scroll or use +/− to zoom, drag to pan, **World** to return, and **You** to find the current map. Muted markers and mist distinguish unexplored public maps. Browsing never reveals or loads them; exploration comes from the existing saved journey visits.

NPC hints show icons, with Chronicle-framed text only on hover (tap toggles details on touch): a coin pouch identifies working traders, an exclamation mark identifies quest NPCs (bright gold for the current objective), and a speech bubble identifies other conversations.

Map travel preserves possessions and resources and enforces the same allegiance and quest gates as physical portals. Selecting maps never travels. The explicit **Travel to discovered map** button retains existing travel between visited playable hometown districts; choosing the current district closes the atlas.

Soft golden ground light marks the exact travel triggers; subdued amber light identifies sealed entrances. Ground signs point toward raised routes. Village Square's Trainers' Yard entrance is above Elowen. In the Great Hall, Tower Base is on the raised eastern landing; the ground-level east exit leads to the King's Room. The original painted platform appearance is retained. Up/Down on ladders and ropes uses the character's climbing animation.

## Local journey checkpoints

Builder entry resumes a saved hometown journey for the selected lineage, including an excursion into the existing four-map training route. A first visit starts in the square. Checkpoints preserve map and position together, possessions, equipment, resources, cooldowns, quest stage, training objectives and visited map state. Invalid positions use that map's anchor; dead heroes resume that map's death/recovery flow. Expired wards and invulnerability are not restored. Unavailable maps report an error rather than teleporting home.

Files are `user://wendmere_<lineage>_v1.save`, written through a temporary file and atomic rename. Script-driven tests and captures never read or write player checkpoints. These are local prototype profiles, not networked Hero IDs or authoritative multiplayer persistence. Shops retain the existing local transaction model.

## Verification

```sh
godot --headless --path . --script res://tests/human_hometown_regression.gd
godot --headless --path . --script res://tests/market_row_regression.gd
godot --headless --path . --script res://tests/world_interaction_regression.gd
godot --headless --path . --script res://tests/hometown_network_regression.gd
godot --headless --path . --script res://tests/hometown_traversal_regression.gd
godot --headless --path . --script res://tests/hometown_journey_regression.gd
godot --headless --path . --script res://tests/hometown_save_regression.gd
godot --headless --path . --script res://tests/hometown_climbing_regression.gd
godot --headless --path . --script res://tests/hometown_presentation_regression.gd
godot --headless --path . --script res://tests/hometown_map_travel_regression.gd
godot --path . --script res://prototypes/human_hometown/capture_districts.gd
godot --path . --script res://prototypes/human_hometown/capture_journey.gd
godot --path . --script res://prototypes/human_hometown/capture_feedback.gd
```

The traversal test discovers reachable surfaces using actual jump/gravity/collision simulation and climbs every rope. The journey test walks through the real portal controller, completes the story through NPC interactions, and checks guardian and quest refusal. Rendering outputs are `artifacts/hometown_*.png`. Generation prompts and asset provenance are recorded in [hometown-prompts.json](../../assets/maps/wendmere/hometown-prompts.json) and [generation notes](../../assets/maps/wendmere/generation-notes.md).

## Upper exploration routes

Market awnings, herb terraces, the trainers' course, orchard walls, workshop galleries, tower landings, upper archive stacks and the Solar balcony now have optional jump routes. Each ends in a one-time 20-coin remedy cache per journey. Tall routes offer a rope back down; ordinary jump rises are 70 px. Existing raised exits and the Winding Stair remain connected. The scenery scales to cover the highest camera position with the district's painted background. `tests/hometown_traversal_regression.gd` simulates every exit and climbing-reward route and checks one-time collection.

**Teleport here (test)** in the atlas jumps directly to any of the 58 implemented maps, including undiscovered or gated destinations. It preserves the character and does not complete quests. Unbuilt maps have this action disabled. Ordinary map travel continues to enforce its usual gates.
