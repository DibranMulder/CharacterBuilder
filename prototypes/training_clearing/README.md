# First clearing — local gameplay experiment

Question: do movement, jumping, a committed sword swing, frontal Guard and one
stamina-costing skill feel readable and enjoyable on keyboard and touch?

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

Move with A/D or arrows; Space jumps; J/1 attacks with the equipped weapon;
hold Shift/2 to Guard when a shield is equipped. K/3 powers up the equipped
weapon's attack (25 stamina, four-second cooldown). All actions also have
on-screen controls. Esc pauses, R resets the entire experiment, and Builder
returns to character design. Losing window focus pauses automatically.

Move, jump, block a hit and defeat two ordinary crawlers to finish the practice
objectives. Continue right for the optional Elder Briar. Gold warns of an attack;
red marks its strike. Enemies lock their facing when warning, then recover.
Guard mitigates frontal damage by 80%, costs stamina, and does not protect the
back. The block objective is omitted without a shield. Power attacks stagger
and deal 42 damage versus a basic attack's 20. Sword and axe use a melee sweep;
spear uses a longer jab. Bow, crossbow, staff and branch staff fire moving,
non-piercing prototype projectiles. An empty weapon slot disables attacks rather
than secretly supplying a sword. These shared damage values are testing values,
not production equipment stats or Class permissions.

Death recovers in the same clearing after two seconds. Defeated enemies stay
defeated; surviving enemies reset their encounter. R explicitly resets all state.
The platforms are one-way landing surfaces. Jump motion is driven by gameplay
physics, not the character-builder's self-contained jump animation.

Observe: can players recognize and block the warning without instruction? Does
attack commitment feel fair? Can touch users move and act simultaneously? Does
Power Strike create a worthwhile stamina choice? Is recovery understandable?
The verdict is pending hands-on play, especially on physical mobile devices.
