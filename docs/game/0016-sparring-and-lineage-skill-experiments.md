---
id: DESIGN-0016
title: Local sparring and lineage skill experiments
status: prototype
updated: 2026-09-09
---

# The Proving Ring

**Progression update:** DESIGN-0017 adds clearing Discipline XP and skill
requirements. The arena remains an all-skills, no-XP sandbox; its four lineage
actions are joined by shared Power Strike [7] and Arcane Bolt [8].

An offline 1v1 arena for testing character-versus-character combat before building
the online PvP service or more maps. Enter from **Sparring arena** in the builder.
The player keeps the selected lineage and exact equipped outfit; the opponent
uses its lineage's reference outfit. Select any of the other seven lineages and
one of three bot difficulties. Changing either selection starts a fresh round.

This supplements DESIGN-0005, not the production Class system in DESIGN-0012.
These are deliberately exaggerated lineage-flavored skill experiments, not
Class permissions, talent unlocks, or permanent balance commitments. Every
lineage can still choose every Combat Class. Allegiance remains unchanged;
sparring against Light or Dark opponents does not switch it.

## Skill identities

Four active prototype skills per lineage. All cost mana, including physical
special attacks. Each has a visible windup, recovery, and individual cooldown.
The same definitions drive the player's hotbar and the bot's decisions.

| Lineage | Skill 3 | Skill 4 | Skill 5 | Skill 6 |
| --- | --- | --- | --- | --- |
| Tidekin | Tongue Snap: long melee poke | Lily Leap: forward rush | Bog Spit: slowing projectile | Springwater: heal |
| Humans | Crosscut: committed strike | Shield Rush: forward burst | Rally: absorption ward | Second Wind: heal |
| Grove Centaurs | Gallop Strike: long rush | Rearing Stomp: radial knockback | Briar Bind: rooting projectile | Grove Renewal: heal |
| Aeralith | Gale Needle: fast ranged pressure | Slipstream: backward escape | Cyclone: radial knockback | Zephyr Veil: absorption ward |
| Crag Trolls | Boulder Fist: heavy windup strike | Faultline: wide knockback burst | Stonehide: large absorption ward | Mountain Charge: forward rush |
| Deep Goblins | Scrap Shot: cheap projectile | Snare Canister: rooting projectile | Smoke Hop: backward escape | Siphon Dart: damage and lifesteal |
| Sunscour | Searing Thrust: long melee strike | Dune Step: quick forward burst | Sandglass: slowing projectile | Mirage Guard: absorption ward |
| Rimeborn | Ice Shard: ranged pressure | Rime Prison: rooting projectile | Aurora Mend: heal | Winter Halo: radial knockback |

Exact power, mana, cooldown, reach and windup values live in
`prototypes/sparring_arena/lineage_skills.gd`; skill button tooltips expose them.
Each skill explicitly selects a lineage gesture from the character builder.
The shared combat visual adapter plays its full-body pose, footwork, wings and
decorative effects in both the clearing and arena, including for bots. The
builder has three gestures per lineage, so some of the four skills reuse the
closest gesture. Skill names, damage and resource rules remain unchanged.
Anticipation/contact timing is fitted to the skill's windup, with recovery fitted
to its recovery time; the builder's original timing stays unchanged. Cosmetic
Gallop Shot arrows and Snap Shot bolts are suppressed in gameplay so they cannot
duplicate or outlive authoritative projectiles. Basic attacks retain their
equipped-weapon animations. Bespoke animation/art per skill remains future work.
Shield Rush is currently a lineage burst, not a shield requirement.

## Shared combat rules

- Both fighters start with 100 HP, 100 mana and 100 guard stamina. Mana regenerates
  at 4/s. No hidden bot health, damage, mana or cooldown bonuses.
- Basic attacks use the clearing's weapon feel table. Staff basic attacks cost
  8 mana; physical basic attacks are free. An empty weapon slot disables basics.
- Guard requires an equipped shield, blocks only frontal hits, reduces damage
  by 75%, and spends stamina. Guard prevents the projectile root/slow effects.
- Roots last 0.8s; slows reduce speed by 45% for 2s. Wards absorb damage for 5s
  and replace rather than stack. Lifesteal restores half the actual HP damage.
- Melee checks facing and height; radial bursts hit both directions. Projectiles
  are aimed once, have finite range and use swept collision to avoid tunneling.
- Rushes/escapes are short prototype bursts, bounded by the ring, and grant no
  invulnerability. Jumping changes the combat collider's height. Collider sizes
  are standardized for comparison despite different painted silhouettes.
- Hits give visible character flashes, Field Notes damage numbers, impact rings,
  cast labels and windup bars. Round results show time, damage dealt and received.
- Feedback distinguishes HP damage (warm flash and small directional visual
  recoil), shield blocks (cyan shield), ward absorption (violet shield and an
  explicit absorbed amount), and healing (green rising crosses). Partial ward
  absorption reports absorbed and HP damage separately; fully absorbed hits do
  not pretend the character lost HP. Lifesteal reports the actual healing.
  Recoil does not move colliders or cancel actions. The clearing shares this
  feedback treatment; balance numbers and hit-stun rules remain unchanged.
- Projectile skills start at their builder gesture's effect anchor; basic
  attacks still use the equipped weapon muzzle. Headless rules tests use a
  deterministic fallback origin when no rendered rig is supplied.
- Defeat freezes the round; simultaneous lethal releases can draw. Rematch
  restores resources and clears projectiles, cooldowns and temporary effects.
- No XP, item, coin or rating rewards. No persistence, matchmaking or networking.
  The inherited XP display remains at zero. These reward restrictions apply to
  the arena; the clearing retains its normal monster XP and loot.

## Bot behavior

Melee bots close distance; ranged bots try to maintain space. Bots choose heals
when hurt, wards under pressure, escapes when crowded, and offensive skills when
in reach. They share `Fighter.request` with the player, including resource and
commitment checks. Difficulty changes decision frequency and reaction delay;
experienced bots can jump against a visible close attack windup. Bots do not
read future player inputs. They are heuristics, not finished competitive AI.

## Controls and test goals

A/D or arrows move; Space jumps; J or 1 attacks; hold Shift or 2 to guard;
3–6 activate lineage skills; 7–8 activate shared skills; R rematches; Escape pauses and reveals navigation and
opponent settings. Only skill tiles are buttons on the active play screen;
the old movement/action button strip is hidden and has no touch hit regions.
Movement and basic combat use the keyboard. Skill tiles remain clickable.
The six illustrated skill tiles sit directly beneath the player's HP/mana/XP
bars, following `npc-interaction-mockup.png`: brass frames, key badges below,
small mana costs and live cooldown shading. `SkillTile` is reused in the HUD and
the Chronicle skill overview rather than maintaining separate icon treatments.

**Skills · L** opens the parchment-and-ink overview. It shows all 32 implemented
lineage skills, including effects, power, mana, cooldown, windup and reach. Browse
other lineages without changing the player's outfit. This is an overview, not
the Class Talent unlock tree; no points or unlock levels are invented. The same
overview is accessible beside the clearing's pouch and from its Gear & Pouch
screen. Gear & Pouch and Skills share the same Chronicle header, fixed tab
positions, active-tab treatment, parchment panels and ink detail panel.
The clearing also exposes its four lineage skills on keys 3–6, with the same
mana, cooldown and effect definitions. K retains the legacy weapon power strike;
H/M use potions and E talks to Rowan without an on-screen interaction button.
The overview pauses gameplay, consumes combat/restart shortcuts, and restores
the prior paused/playing state on close. Pouch/skills tabs preserve that state.

Focus loss pauses and clears held inputs. The builder button returns to the same
outfit. Full touch-only movement is not supported by this keyboard-first layout.

Test whether windups are readable, whether melee can catch ranged kits, whether
roots leave enough agency, and whether mana forces meaningful choices. Compare
matchups and equipment before committing to final maps, skills or balance.

Run `godot --headless --path . --script tests/arena_regression.gd` for the
deterministic rules/UI checks. `prototypes/sparring_arena/capture.gd` captures the
rendered arena. Start directly with
`godot --path . prototypes/sparring_arena/arena.tscn` or use the builder entry.
