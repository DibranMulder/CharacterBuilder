# Character designs

Use the working Lineage names in [DESIGN-0008](../game/0008-playable-lineage-art-direction.md).
Lineage is independent of Combat Class. This pass changes names, not anatomy,
equipment permissions, gender availability, or animation behavior.

| Previous label | Lineage | Stable rig ID | Surface notes |
| --- | --- | --- | --- |
| Bogkin | Tidekin | `bogkin` | Shared amphibious rig |
| Human | Humans | `human` | [Human](human-surface-rig.md) |
| Centaur | Grove Centaurs | `centaur` | [Grove Centaur](centaur-surface-rig.md) |
| Fae | Aeralith | `fae` | [Aeralith](fae-surface-rig.md) |
| Frost Troll | Crag Trolls | `frost_troll` | [Crag Troll](troll-surface-rig.md) |
| Goblin | Deep Goblins | `goblin` | [Deep Goblin](goblin-surface-rig.md) |
| Duneborn | Sunscour | `duneborn` | [Sunscour](duneborn-surface-rig.md) |
| Frostling | Rimeborn | `frostling` | [Rimeborn](frostling-surface-rig.md) |

DESIGN-0006 still lists “Sunscour Legion”; DESIGN-0008 explicitly clarifies
that Sunscour is the people and the Legion is one military organization.

Existing filenames, code class names, command flags, rig IDs, and loadout keys
are retained for compatibility. New previews should obtain display names from
`CharacterCatalog.race(id).name`, not capitalize a rig ID. Previously rendered
images may retain historical labels until regenerated.

The game docs describe a broader game than this standalone character prototype.
In particular, Aeralith anatomy remains an open art decision there; this
prototype's existing wings do not settle that decision.
