# Skill concept gallery

Eight lineages and all **70 weapon-skill entries** are represented in eleven
illustrated boards. These are concept studies, not in-game captures, animation
atlases or implemented combat effects. The preferred painted Troll treatment
sets the benchmark for material weight, clear silhouettes and forceful poses.
Other families retain their own colors, materials and combat identities.

## All eight lineages

[Open the complete eight-lineage board](lineages-all-eight.png).

Top row: Tidekin — Springwater; Humans — Second Wind; Grove Centaurs — Grove
Renewal; Aeralith — Zephyr Veil. Bottom row: Crag Trolls — Mountain Charge;
Deep Goblins — Siphon Dart; Sunscour — Mirage Guard; Rimeborn — Winter Halo.

This is one signature illustration per lineage, **not all 32 lineage skills
illustrated individually**. The written full kit remains in
[DESIGN-0020](../../docs/game/0020-lineage-skill-catalog.md).
The earlier [six-panel study](../lineage-skill-effects-concept.png) is retained
as an archive, not the complete lineage roster or current gallery cover.

## All ten weapon families

Each board contains seven labelled panels: top row proficiency 1, 5, 15;
middle row 30, 50, 75; full-width bottom panel 99. Levels are **weapon
proficiency**, not Overall Level. Every entry includes the character, weapon
pose and effect treatment rather than only an icon or text description.

| Open visual sheet | Skills, in proficiency order |
| --- | --- |
| [Sword](sword-mastery.png) | Basic Slash → Quick Cut → Heavy Cut → Pommel Strike → Sweeping Edge → Guarded Riposte → Blade Rhythm |
| [Axe](axe-mastery.png) | Hew → Committed Chop → Raking Edge → Pursuing Hew → Broad Reap → Split Decision → Headsman's Measure |
| [Spear](spear-mastery.png) | Straight Thrust → Tip Strike → Withdrawn Point → Set the Point → Driving Lunge → Turning Shaft → Three-Point Measure |
| [Polearm](polearm-mastery.png) | Long Sweep → Narrow End → Hook and Draw → Clearing Wheel → Low Harvest → Overhead Reach → Reaper's Circuit |
| [Bow](bow-mastery.png) | Draw and Loose → Snap Arrow → Retreating Loose → Hampering Arrow → Forked Volley → Lofted Shot → Running Cadence |
| [Crossbow](crossbow-mastery.png) | Shouldered Bolt → Braced Bolt → Combat Reload → Disrupting Bolt → Bodkin Bolt → Measured Pair → Siege Measure |
| [Wand](wand-mastery.png) | Lumen Pin → Stitchlight → Needle Hex → Threadward → Unravel → Steady Thread → Returning Light |
| [Staff](staff-mastery.png) | Spark → Firebolt → Frost Bind → Arcane Ward → Chain Spark → Steady Channel → Spell Weave |
| [Dagger](dagger-mastery.png) | Close Prick → Double Prick → Retreating Nick → Held Point → Tendon Touch → Patient Answer → Needle Sequence |
| [Blunt](blunt-mastery.png) | Weighted Blow → Knocking Blow → Checking Tap → Grounded Swing → Roommaker → Bracebreaker → Bellfall |

[Machine-readable coverage manifest](catalog.json) lists the exact seventy
names, proficiency levels and image paths. Sword/Staff mechanics are proposed
in [DESIGN-0018](../../docs/game/0018-xp-and-weapon-proficiency-balance.md);
other families in [DESIGN-0019](../../docs/game/0019-weapon-skill-catalog.md).
The shared [visual direction](../../docs/game/0021-skill-visual-direction.md)
defines anticipation, contact, aftermath, map reactions and accessibility.

## Reading a concept sheet correctly

- Ghosted poses show sequential moments, not extra bodies, summons or clones.
  Measured Pair's small reload inset is a storyboard step, not another actor.
- Extended streaks depict motion and effect shape, not permission to turn melee
  into ranged damage. Use authored attack reach and collision geometry from the
  skill catalog. Spear's mastery diagram is a sequence, not a screen-long beam.
- Foliage curls on Hampering Arrow and decorative frost do not add roots or
  extra damage. Lofted Shot's feather streaks are decorative, not extra arrows.
- Stone fragments and cracked ground sell impact; platforms stay intact and
  collision does not move. The apparent destruction in a hero panel is not a
  gameplay promise. Early effects need reduced debris at actual play scale.
- A pictured lineage is a presentation example, not an exclusive weapon
  permission. All permitted lineages need their own builder-gesture adaptation;
  these ten boards do not claim 560 lineage-by-weapon-skill animations.
- Healing is readable and gentle, guards remain transparent, and actual enemy
  telegraphs/platform rims take priority over decorative effects. Screen shake,
  flashes and lighting changes have the reduced-effect options in DESIGN-0021.
- Printed labels and static artwork are concept references, not production UI
  assets. Rebuild names/levels as real text and separate character, VFX, scenery
  and telegraph layers when turning these into runtime assets.

## Production handoff

Keep the existing builder rigs and equipment constraints: Trolls have no
scarves, Centaurs have one coherent horse body, Crossbows fire horizontally from
the shoulder, Staff casts point forward, and a two-handed weapon stays one
weapon with the appropriate grip. Use separate anticipation/release/contact/
aftermath frames; a beautiful impact still needs a valid attack pose.

The boards establish an art direction. Production still requires motion tests,
final socket placement, actual-size readability, exact hit-area matching,
resource/animation timing and crowded-arena performance checks. No runtime or
save data changed in this illustration pass.
