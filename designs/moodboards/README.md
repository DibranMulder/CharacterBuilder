# Lineage and world moodboards

Open [the visual atlas](index.html) to browse the eight lineage boards and Babylon, filter by allegiance or World, or open a full-resolution image.

These are art-direction proposals generated with the built-in imagegen tool. They are not new implemented maps, NPCs or boss encounters. The existing lineage anatomy and assigned bosses guide the boards; civilian outfits and prop studies are exploratory, not new equipment rules. Aeralith anatomy remains exploratory; Tidekin gender presentation remains undecided.

| Lineage | Hometown | Stronghold boss | Board |
| --- | --- | --- | --- |
| Humans | Wendmere Crossroads | The Oathbound King | [View](humans-v2.png) |
| Tidekin | Tidewharf | The Mireback | [View](tidekin.png) |
| Grove Centaurs | Rootway Commons | The Hollow Crown | [View](grove-centaurs.png) |
| Aeralith | Lowdock | The Storm Roc | [View](aeralith.png) |
| Crag Trolls | Hoistyard | The Ironhorn | [View](crag-trolls.png) |
| Deep Goblins | Lampcap Junction | The Underdeep Rat | [View](deep-goblins.png) |
| Sunscour | The Caravanserai | The Dune Elephant | [View](sunscour.png) |
| Rimeborn | Thawcamp | The Ice Queen | [View](rimeborn.png) |

Each board includes a settlement, hero, three NPC roles (including a stronger guard), boss, equipment/material studies, and palette. Guard proportions are intentionally broader than heroes. Nimrod belongs to the additional Babylonian Tower encounter, not a ninth lineage.

## Babylon and its depths

[View the Babylon moodboard](babylon.png): abandoned city, Tower of Babylon, Nimrod, flooded dungeon vaults, swamp canals, caves beneath the foundations, wandering NPCs and material studies.

The ruined city, Broken Concourse, tower, Flooded Vaults and summit observatory follow [DESIGN-0015](../../docs/game/0015-world-map-layout.md). Swamp canals and foundation caves are new visual explorations requested for this board; they do not change the established dungeon route or move Gloamfen into Babylon. NPC appearances are proposals. Nimrod follows the existing boss reference. See the [exact Babylon prompt](babylon-prompt.md); this board was generated with the built-in imagegen tool.

The original v1 moodboard direction is restored. The Babylon v2 style experiment was rejected and is retained only as an unused draft. All nine gallery boards use the original art direction; the Human board retains its role-label correction.

## Sources and reproducibility

- [Lineage art direction](../../docs/game/0008-playable-lineage-art-direction.md)
- [Hometowns](../../docs/game/0014-hometown-maps.md)
- [Assigned boss concepts](../bosses/README.md)
- [Current playable silhouettes](../../artifacts/current_lineage_showcase.png)
- [Exact prompts](prompts.json), one built-in generation call per lineage. Each uses the current silhouette sheet and its relevant boss sheet as visual references.

All final PNGs are saved in this directory. `humans-v2.png` corrects Tessa and Orin's role labels; the initial Human render is retained as `humans.png`. The correction prompt is included in the prompt set. `.gdignore` keeps these art boards out of Godot imports. No game runtime dependency is added by this gallery.
