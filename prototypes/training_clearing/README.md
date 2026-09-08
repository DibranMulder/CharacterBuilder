# First clearing — local gameplay experiment

Question: do movement, jumping, a committed sword swing, frontal Guard and one
mana-costing skill feel readable and enjoyable on keyboard and touch?

Run from the repository root:

```sh
godot --path . prototypes/training_clearing/training_clearing.tscn
```

The character builder remains the default project scene. This separate
scene is also available through its **Play training clearing** button. The
in-memory prototype loads the builder's exact Lineage, weapon, offhand, clothing,
accessories, and facing. No equipment is substituted. Returning to the builder
restores the original configuration; restarting combat keeps the equipment. Selection
lasts only for this running session. Direct launch defaults to Humans. Terrain and
creatures are placeholders, not production map art. Nothing persists or grants
real progression. No account, server, Exchange, village or complete tutorial is
implemented yet.

## Local loot and pouch

Walk within 75 world units of a dropped bag to collect it. Ordinary enemies drop
8 coins and one potion of each type; the second kill also drops a crossbow.
The elite drops 30 coins, both potions, and an axe. Drops are deterministic for
testing, not a final loot table. Coins have no spending destination yet.

Press **I** (or Pouch) to pause combat and inspect the pouch and equipped slots.
Select an item to compare weapon damage, then Equip; the previous item returns
to the pouch. Equipped slots can also be unequipped. Appearance and weapon/guard
behavior update immediately; armor does not grant combat stats yet. Centaurs
still cannot wear pants or boots. Finish an attack/projectile before swapping.
Closing the pouch restores the previous pause state. Builder retains its original
selection; loot and clearing gear swaps do not overwrite that selection.

Start with three HP and three mana potions. **H** restores up to 40 HP and **M**
up to 40 mana, with matching on-screen buttons and a shared one-second cooldown.
Full resources, empty stacks, death, and cooldown never consume a potion.
Potions and collected loot survive local death. Restart resets coins, pouch and
potions but keeps the current equipped outfit. Leaving the clearing ends this
local inventory session; disk saving and backend authority remain deferred.

`inventory.gd` owns item transactions and lineage validation; `encounter.gd`
owns rewards, pickup distance, equipment action gates and potion effects;
`inventory_panel.gd` only presents state and invokes those actions.

The full-screen pouch follows `designs/gear-pouch-drag-drop.png`: parchment
6×4 item grid, painted equipment icons, live equipped character, surrounding
slot cards and a navy comparison panel. Drag gear onto its highlighted matching
slot, or drag equipped gear to a pouch cell to unequip; clicking and the action
button remain available. Filters, sorting and paging do not discard items.
24 is the page size, not a new inventory capacity restriction. Potion stacks
are inspectable here and remain usable via H/M after closing the paused pouch.
Only the eight implemented equipment slots and real prototype stats are shown;
the mockup's future talents, rarity system and extra slots are not implied.

Move with A/D or arrows; Space jumps; J/1 attacks with the equipped weapon;
hold Shift/2 to Guard when a shield is equipped. K/3 powers up the equipped
weapon's attack (25 mana, four-second cooldown). Basic staff spells cost 8 mana;
ordinary physical attacks are free. Mana regenerates at 5/second after a 1.2-second
spending delay, up to 100. Rejected attacks spend nothing. All actions also have
on-screen controls. Esc pauses, R resets the entire experiment, and Builder
returns to character design. Losing window focus pauses automatically.

Move, jump, block a hit and defeat two ordinary crawlers to finish the practice
objectives. Continue right for the optional Elder Briar. Gold warns of an attack;
red marks its strike. Enemies lock their facing when warning, then recover.
Guard mitigates frontal damage by 80%, costs stamina, and does not protect the
back. The block objective is omitted without a shield. Power attacks stagger
and deal 2.1× basic damage (rounded). Basic damage is sword 20, axe 28, spear 18,
bow 18, crossbow 26, and staff 22, with distinct attack timings. Sword and axe use a melee sweep;
spear uses a longer jab. Bow, crossbow, staff and branch staff fire moving,
non-piercing prototype projectiles from the visible weapon tip, aimed once toward
the nearest enemy ahead. An empty weapon slot disables attacks rather
than secretly supplying a sword. These damage values are testing values,
not production equipment stats or Class permissions.

Death recovers in the same clearing after two seconds. Defeated enemies stay
defeated; surviving enemies reset their encounter. R explicitly resets all state.
The platforms are one-way landing surfaces. Jump motion is driven by gameplay
physics, not the character-builder's self-contained jump animation.

The brass/navy HUD follows `designs/ui-system-board.png`: red HP, blue mana,
green XP, and a separate smaller Guard meter. Ordinary kills award 40 XP and the
elite 100, once per enemy. The temporary Adventure Level curve is 100 × current
level, capped at 120; excess XP carries forward. It grants no stats or talents
and is reset with R or leaving the clearing, not saved progression.

Field Notes combat text uses bold sans-serif lettering with ink outlines:
ivory outgoing hits, gold POWER hits, ember-red HP loss and cyan BLOCK chip damage.
Numbers pop, drift apart and fade above the rig; impact rings, enemy flashes,
and a brief red player tint/edge flash reinforce contact. Labels distinguish
damage categories without relying on color. No camera shake is used.

Observe: can players recognize and block the warning without instruction? Does
attack commitment feel fair? Can touch users move and act simultaneously? Does
Power Strike create a worthwhile mana choice? Is recovery understandable?
The verdict is pending hands-on play, especially on physical mobile devices.

The play screen intentionally omits the practice checklist, debug counters,
instructional signs and persistent tutorial prose, following the uncluttered
world presentation in `designs/npc-interaction-mockup.png`. Action hotkeys and
resource/cost information remain; Builder and Restart are exposed while paused.
The practice conditions still run in the local model. Controls are documented
here rather than overlaid on the world. The pouch shows item details and errors,
not a permanent drag-and-drop instruction banner.

The top-left resource HUD follows the NPC mockup's compact portrait medallion,
overlapping level badge, name, red/blue numeric bars and slim green XP percentage.
The portrait renders the equipped character (including headgear) once per outfit
change through `src/ui/character_portrait.gd`; it is not a continuously animated
second character. `capture_hud.gd` produces an eight-lineage visual audit.
