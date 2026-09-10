---
id: DESIGN-0018
title: Overall Level, Discipline XP and Weapon Proficiency
status: proposed-balance
updated: 2026-09-10
---

# Level by doing, unlock ways to play

User direction: Overall Level caps at 120; using weapons builds proficiency
and unlocks weapon-specific actions; physical and magical activity train distinct
Disciplines; lineage abilities remain separate, with lineage training affinities,
physical differences and weapon synergies. This document designs that
system. Numerical curves, award ratios and unlock catalogs below are proposed
starting values, not measured live-game balance. No runtime changes accompany it.

## 1. Three progression tracks, not three character levels

| Track | Cap | Earned through | Purpose |
| --- | --- | --- | --- |
| Overall Level | 120 | Encounters, quests, discoveries and authored world activities | Hero/encounter scale, equipment tiers, Class Talent Points |
| Each Discipline | 99 | Relevant successful activity | Broad capabilities and ability requirements |
| Each Weapon Proficiency | 99 | Effective use of that Weapon Family | Weapon techniques and weapon-delivered spells |

Use **Overall Level** as the player-facing name of the old Adventure Level.
Do not scale the average of twelve Disciplines to 120: that would force unwanted
activities onto specialists. Retire the old averaged Overall Level; keep **Total
Discipline Level**, 12–1,188, as a breadth summary. Proficiency is not included
in that total. A level-120 sword specialist can still have Crafting 1.

This revises the terminology in DESIGN-0007/0011/0017, not the existing campaign
scale. Zones and equipment remain on the same 1–120 axis. Class Talents retain
one point per ten hero levels, maximum twelve; DESIGN-0013's row levels and
prerequisites do not change. Weapon unlocks do not spend those points.

## 2. XP curves and pacing

All tracks begin at level 1 with zero XP. The formulas below give XP **from
level L to L+1**, not cumulative thresholds. Cumulative XP is their sum from
level 1. Stop awarding progression XP at the cap; no hidden level 121 or 100.
Use positive half-up rounding consistently on each step.

```text
Overall:     next(L) = round(120 + 18L + 2L²)       L = 1…119
Discipline:  next(L) = round( 50 +  8L + 0.6L²)     L = 1…98
Proficiency: next(L) = round(40 +  6L + 0.5L²)      L = 1…98
```

Initial sustained earning benchmarks: 120 Overall XP/minute of productive
activity, 60 XP/minute for the actively used Weapon Family, and around 50
XP/minute for a primary trained Discipline. These are tuning benchmarks, not
unconditional per-minute grants. Secondary Disciplines progress more slowly.

| Level reached | Overall cumulative XP | Overall active hours | Proficiency active hours | Primary Discipline active hours |
| ---: | ---: | ---: | ---: | ---: |
| 10 | 2,460 | 0.34 | 0.22 | 0.33 |
| 20 | 10,640 | 1.48 | 0.87 | 1.32 |
| 40 | 59,800 | 8.31 | 4.59 | 6.84 |
| 60 | 179,360 | 24.91 | 13.36 | 19.75 |
| 80 | 401,320 | 55.74 | 29.41 | 43.24 |
| 99 | 736,176 | 102.25 | 53.42 | 78.28 |
| 120 | 1,280,440 | 177.84 | — | — |

Thus the first interesting weapon ability should arrive within about five
minutes of effective use, while late mastery remains a long-term pursuit.
Overall 120 targets roughly 160–220 productive hours before testing adjusts
the benchmark. These are not estimates of real elapsed playtime: travel,
socializing, failed encounters, build choice and player efficiency change it.
Training happens concurrently, so do not add these hours together.

## 3. Reward budgets, not XP per inflated damage point

Author an expected completion time and recommended Overall Level for each
encounter/activity. At matching level, its Overall reward budget is:

```text
B = 2 × authored expected seconds
```

A 30-second ordinary encounter therefore budgets 60 Overall XP. Its active
weapon-training budget is `0.5B`, or 30 Proficiency XP. Quest rewards and their
required kills share the authored objective budget rather than paying twice
for the same expected time. First-discovery rewards are explicitly one-time.
World objectives target comparable Overall XP/minute to combat, not free XP
for moving back and forth. Running itself primarily trains Disciplines.

Use actual effects to allocate training, but normalize to those budgets:

- Attack/Arcana primary pool: at most `5B/12` each per encounter, earned in
  proportion to relevant effective physical/magical output, including valid
  support effects for Arcana. A pure matching-level user targets 50 XP/minute.
- Strength secondary pool: at most `B/4`, proportional to effective melee
  output. Ranged physical output trains Attack, not Strength by default.
- Focus secondary pool: at most `B/4`, proportional to effective magical
  activity. A physical special attack costing mana does not become a spell.
- Defense pool: up to `5B/12` for actively preventing threatening attacks;
  validate block/parry events and prevented damage against the threat budget.
- Stamina pool: up to `B/6` for surviving meaningful pressure; add valid
  traversal training below. Good defense can qualify as endurance, so being
  hit deliberately must not train faster than competent blocking.
- Willpower pool: up to `B/4`, earned from qualifying control recovery,
  cleansing and effective spellcasting under threat. Ordinary safe casting
  does not consume this pool.

These are separate finite pools, not a flat award to every stat. Track credited
fractions, accumulate fractional XP, and round only on payout: ten tiny hits
must not out-earn one equal larger hit. Normalize effective output to the
authored enemy HP and pressure budget; higher gear damage must not multiply
XP per kill. Overkill, overhealing and unused shields have no effective value.
Shielding trains only when the shield actually absorbs an eligible attack.

An encounter's training budget cannot refill through healing, leashing or
resetting the same enemy. Damage-over-time and channel ticks share their
action's credit. AoE cannot exceed the combined budgets of affected enemies.
Training feedback can be immediate; Overall encounter XP pays on completion.
Legitimate respawned enemies have new, rate-budgeted encounters.

### Challenge scaling

Compare content to **Overall Level**, never to the currently equipped weapon's
proficiency. Swapping to a new sword must not make starter enemies profitable
again for a high-level hero.

| Enemy levels below hero | XP multiplier |
| --- | ---: |
| 0–5, or equal level | 1.0 |
| 6–15 | 0.5 |
| 16–25 | 0.1 |
| More than 25 | 0 |

Above-level content scales from 1.0 to at most 1.25 at ten levels above. Author
boss rewards from expected challenge time, not an enormous flat HP multiplier.
Do not make intentional damage-taking necessary for eligibility. Supporting
an eligible encounter counts; merely tagging or equipping a weapon does not.
Party reward allocation requires its own multiplayer pass; do not ship a rule
that gives the whole weapon budget to every player who touches a target.

## 4. What every Discipline means

| Discipline | Identity | Qualifying training |
| --- | --- | --- |
| Attack | Physical weapon control and precision | Effective physical attacks with melee weapons, bows and crossbows |
| Strength | Melee force and heavy techniques | Effective melee strikes and force-based abilities |
| Defense | Preventing physical pressure | Blocks, parries, guarding allies and active mitigation |
| Agility | Moving well, not enduring injury | Running routes, traversal, obstacle clears and well-timed evasion |
| Stamina | Physical endurance | Surviving combat pressure, blocking under sustained pressure and sustained running |
| Focus | Magical resource capacity and control | Effective spells, heals, wards and useful maintained channels |
| Willpower | Mental resilience under threat | Control recovery/cleansing, effective casting under pressure and resistance challenges |
| Arcana | Shaping magical effects | Effective magical damage, healing, protection and controlled magical utility |
| Survival | Field recovery and hazards | Preparing/using meaningful recovery supplies and surviving authored hazards |
| Gathering | Extracting resources | Successful eligible harvesting |
| Crafting | Making and improving equipment | Eligible crafts, repairs and upgrades, not endless destroy/recraft refunds |
| Exploration | Discovering the world | New routes, secrets, landmarks and authored exploration objectives |

**Taking an ordinary hit trains Stamina, not Agility.** Avoiding a telegraphed
hit trains Agility; blocking it trains Defense and can train Stamina. This
honors activity-based development without rewarding poor play over good play.

For ordinary traversal, start with 10 Agility XP and 5 Stamina XP per minute
of validated running. Accumulate active moving time, not held input. Exclude
teleports, mount travel, knockback, walls and menus. Repeated safe loops yield
zero after two passes through the same route segment within fifteen minutes;
authored obstacle courses can be repeatable and use their own challenge budget.
Climbing, obstacles and genuine evades can raise Agility toward 30–50 XP/minute
in suitable activities. New exploration grants are not repeated running XP.

## 5. Focus, Willpower and Arcana

**Arcana — what magic can do.** Determines access to complex magical forms
and a modest potency bonus shared by damage, healing and shielding. It does
not determine mana capacity or resistance to being controlled.

**Focus — how much magic you can sustain.** Determines mana capacity and
resource-oriented techniques. Do not also give it spell damage, fear resistance
and cast speed; it would become a mandatory all-purpose magic stat.

**Willpower — keeping control when something fights back.** Reduces eligible
hostile control duration and unlocks stability, cleansing and concentration
techniques. It is not physical HP, generic armor, or a second mana stat.
Physical knockback and ordinary weapon stagger are not mental control.

Examples:

- A Staff fire spell hitting an enemy trains Staff Proficiency, Arcana and
  Focus. If the caster is currently facing a credible active threat, it can
  also train Willpower from that encounter's limited pressure pool.
- A useful Wand heal trains Wand Proficiency, Arcana and Focus. Healing a
  full-health ally trains nothing; healing self-inflicted friendly damage is
  not an eligible threat outcome.
- A magical fear resisted or cleansed during a real encounter trains
  Willpower. Spamming dispel with no effect does not.
- A crossbow bolt trains Crossbow Proficiency and Attack, even if its name
  includes “shot” or its animation uses a projectile. Magical classification
  belongs to the ability's effect, not its animation or mana cost.
- An innate lineage spell trains mystical Disciplines but not the Staff that
  happens to be held. A lineage ability explicitly delivered by a weapon may
  credit that weapon; this must be authored, not inferred from equipped gear.

Willpower must have accessible training before making it an unlock requirement:
include early low-risk magical-pressure encounters and repeatable concentration
trials. Do not gate a cleanse behind a Discipline that can only be trained by
already knowing that cleanse.

## 6. Weapon Proficiency and unlock rules

Track one 1–99 proficiency for each approved family: Sword, Axe, Spear,
Polearm, Bow, Crossbow, Wand, Staff, Dagger and Blunt. One-/two-handed versions
share family progress, but actions can require a particular Grip. Shield skills
use Defense and an equipped Shield, not an eleventh weapon family.

Weapon Proficiency is **earned by use, never by merely wielding**. Attribute
effects to the family and eligible action recorded at cast/attack start; weapon
swaps cannot redirect projectiles, DoTs or healing ticks into a different track.
Split paired-weapon credit by actual contribution, preserving the total pool.
Two swords train Sword once, not twice. Learned techniques persist when weapons
are changed, but cannot be used without their required family/grip equipped.

Class permission still applies: mastery does not grant a Vanguard permission
to dual-wield. Talents modify or specialize actions rather than granting a
second duplicate of the same weapon skill. Class/weapon overlap in DESIGN-0013
must be audited before implementation. Nothing changes permanent Allegiance.

Initial family milestone ladder: **1, 5, 15, 30, 50, 75, 99**. Level 1 always
supplies a usable basic action, so training never requires a locked skill.
Start with four active hotbar slots plus a dedicated basic attack; learning
more skills expands choices, not the number of mandatory simultaneous buttons.
An equip/loadout screen should let players choose their unlocked skills.

### Sword proposal

| Sword proficiency | Action | Additional requirements |
| ---: | --- | --- |
| 1 | Basic Slash | None |
| 5 | Quick Cut — fast low-commitment strike | Attack 3 |
| 15 | Heavy Cut — stronger committed strike | Strength 10 |
| 30 | Pommel Strike — short interruption | Attack 20 |
| 50 | Sweeping Edge — nearby multi-target arc | Attack 30, Strength 25 |
| 75 | Guarded Riposte — response after a successful block | Defense 40, Shield equipped |
| 99 | Blade Rhythm — timed combo technique | Attack 60, Agility 40 |

### Staff proposal

| Staff proficiency | Spell | Additional requirements |
| ---: | --- | --- |
| 1 | Spark — basic magical attack | None |
| 5 | Firebolt — direct projectile | Arcana 3 |
| 15 | Frost Bind — short control projectile | Arcana 10, Focus 5 |
| 30 | Arcane Ward — absorption | Focus 20, Arcana 15 |
| 50 | Chain Spark — limited multi-target spell | Arcana 30, Focus 20 |
| 75 | Steady Channel — sustained spell under pressure | Focus 40, Willpower 25 |
| 99 | Spell Weave — combine two prepared spell effects | Arcana 60, Focus 45, Willpower 35 |

### Other family identities

Use the same milestone ladder, but give each family a reason to exist:

| Family | Skill direction |
| --- | --- |
| Axe | Committed chops, shield pressure and cleaving |
| Spear | Reach control, thrusts and spacing |
| Polearm | Wide sweeps, hooking and area denial |
| Bow | Drawing, mobility and projectile placement |
| Crossbow | Reload decisions, deliberate shots and piercing |
| Wand | Efficient targeted spells, precise healing and cleansing |
| Dagger | Close-range repositioning and opening exploitation |
| Blunt | Guard pressure, concussion and stagger |

Sword and Staff have detailed candidate unlock tables here. The other eight
now have full seven-milestone candidate ladders, costs, requirements and
counterplay in [DESIGN-0019](0019-weapon-skill-catalog.md).
The existing shared Power Strike and Arcane Bolt are prototype stepping stones,
not proof that every weapon's final tree has been defined.

## 7. Lineage abilities remain their own track

Four exclusive abilities per lineage remain distinct from weapon mastery.
Suggested availability: Overall **1, 15, 35 and 60**, with at most one supporting
Discipline requirement of **1, 5, 15 or 30** respectively. A weapon swap does
not remove an innate ability. A weapon-delivered lineage ability must say so
and show the equipment requirement clearly.

This replaces DESIGN-0017's temporary 1/3/5/8 gates only in the proposed design.
Before assigning a supporting Discipline, verify every lineage has a usable
training path to it. Do not force an unshielded caster into shield grinding
to unlock a magical ward: that ward should require Focus, not Defense.

## 8. Keep numerical power growth bounded

Overall level and equipment remain the main encounter scaling. Proficiency
primarily unlocks techniques; it grants no additional universal damage
multiplier. Initial optional Discipline bonuses use `f=(level−1)/98`:

- Strength: up to +10% melee output; Arcana: up to +10% magical efficacy.
- Stamina: up to +20% max HP; Focus: up to +20% max mana.
- Defense: up to 15% lower successful-block stamina cost.
- Agility: up to 15% lower dodge stamina cost, not automatic movement speed.
- Willpower: up to 20% shorter eligible magical control; never immunity.
- Attack initially gates techniques; do not add random misses to visually
  connected action-game hits. World Disciplines gate activities and recipes.

These caps apply once to the appropriate base value, not recursively to gear
bonuses. Ship unlock progression first and validate stat scaling separately;
the current combat prototype still has fixed resource maxima.

### Lineage Affinities — proposal added from user feedback

A Lineage changes the journey and playstyle in three ways: learning rates,
physical traits and conditional enhancements to its own skills. It does not
change the 120 Overall cap, 99 Discipline/Proficiency caps, or Class permissions.
Every lineage may choose every Combat Class; permanent Light/Dark Allegiance
and centaur equipment restrictions stay intact.

All favored families below receive **+15% Proficiency XP from eligible use**.
Other families train at the normal rate; none receive an XP penalty. Two-handed
weapons do not gain two bonuses, and paired weapons split their base XP before
applying each family's affinity. These are initial candidates, not measured
equal-power packages.

| Lineage | Faster Disciplines | Favored families | Proposed physical trait |
| --- | --- | --- | --- |
| Tidekin | Agility +15%, Survival +10% | Spear, Wand | +10% Stamina-resource recovery while not guarding |
| Humans | Attack +15%, Focus +10% | Sword, Crossbow | +5% max mana and +5% max Stamina resource |
| Grove Centaurs | Agility +15%, Stamina +10% | Bow, Spear | +5% grounded running speed; sprint costs 10% less Stamina |
| Aeralith | Agility +15%, Focus +10% | Wand, Staff | +4% grounded running speed and +10% airborne steering |
| Crag Trolls | Stamina +20%, Defense +10% | Blunt, Axe | +12% max HP, +10% max Stamina resource, 5% slower grounded running |
| Deep Goblins | Agility +15%, Crafting +10% | Crossbow, Dagger | Dodges cost 8% less Stamina |
| Sunscour | Focus +15%, Survival +10% | Spear, Wand | +8% max mana |
| Rimeborn | Willpower +15%, Arcana +10% | Staff, Blunt | Eligible hostile magical control lasts 8% less time |

“Stamina Discipline” means the trainable 1–99 capability; “Stamina resource”
means the consumable guard/dodge/sprint pool. Trolls gain both faster endurance
training and a larger physical reserve, rather than merely a tank label.
Stamina Discipline supplies the shared HP bonus described above; Trolls also
have their separate innate HP modifier. A Troll caster keeps that toughness,
but learns Staff at the normal rate and does not inherit an Arcanist permission
from a weapon affinity. Aeralith can still build Defense and become armored.

Apply lineage bonuses additively to the appropriate base stat:

```text
Troll max HP = base HP × (1 + 0.20 × StaminaFraction + 0.12)
Rimeborn eligible control duration = base duration × (1 − 0.20 × WillpowerFraction − 0.08)
```

At Stamina 99, the Troll has 1.32× base HP, not recursively compounded bonuses.
At Willpower 99, the Rimeborn's innate + Discipline reduction is 28%; cap all
control-duration reductions together at 40%, including future temporary buffs.
Never shrink collision boxes automatically with an Agility affinity or silently
grant airborne invulnerability. Equivalent equipment tiers must have comparable
total budgets despite centaurs lacking pants/boot slots; do not charge those
missing stats against their movement trait a second time.

XP affinities multiply the **eligible allocated award and its corresponding
personal budget** after challenge scaling. They do not turn zero-credit actions
into training, bypass reset limits or multiply Overall XP. For a preferred
weapon, the 53.42-hour benchmark to 99 becomes about 46.45 hours. A +20% primary
Discipline affinity changes the 78.28-hour benchmark to about 65.23 hours; it
does not let the Discipline exceed 99. These estimates still assume sustained
qualifying activity. Avoid stacking several lineage XP traits onto one award.

### Weapon-enhanced lineage skills

Base lineage abilities retain the Overall/Discipline unlock gates in section 7
and remain usable with other weapons. At **15 Proficiency** in a favored
family, a compatible lineage skill can gain one authored enhancement. A later
50-Proficiency enhancement should be an alternative selectable variant, not
another automatic multiplicative damage bonus. Show the base and enhanced
effect together in the menu, with the equipped-family condition clearly visible.

| Lineage | Example family-specific enhancement |
| --- | --- |
| Tidekin | Spear: Tongue Snap sets up a longer-reach follow-up thrust. Wand: Bog Spit gains a small splash of its slow, within the same effect budget. |
| Humans | Sword: Crosscut gains a timed combo follow-up. Crossbow: Rally briefly improves the next reload while its ward holds. |
| Grove Centaurs | Bow: Gallop Strike becomes Gallop Shot, using the builder's authored bow gesture. Spear: the rush becomes a longer frontal thrust. |
| Aeralith | Wand: Gale Needle can pierce one additional target at reduced secondary power. Staff: Cyclone gains modest radius instead of more single-target damage. |
| Crag Trolls | Blunt: Boulder Fist applies extra guard pressure. Axe: after Stonehide absorbs an eligible hit, the next strike gains a small secondary cleave. |
| Deep Goblins | Crossbow: Scrap Shot prepares a quicker next reload. Dagger: Smoke Hop creates a short opportunity for a close-range follow-up. |
| Sunscour | Spear: Searing Thrust reaches farther. Wand: Sandglass gains a modest slow enhancement, respecting control limits. |
| Rimeborn | Staff: Ice Shard leaves a brief slowing patch. Blunt: Winter Halo applies extra guard pressure rather than longer immobilization. |

These early examples are expanded and refined by the complete revised
32-skill catalog and enhancement choices in
[DESIGN-0020](0020-lineage-skill-catalog.md). That catalog takes precedence
where an example above differs; neither document implies implemented effects.
Limit an enhancement to one valid activation per cast; a
weapon swap after cast start cannot change the variant or double-trigger it.
Choose by action delivery family, not by whichever two weapons occupy slots.
When an enhancement makes a lineage action weapon-delivered, tag it explicitly
for that family's proficiency credit; innate versions do not train held weapons.

Troll tanking should also come from active play: Stonehide, guard pressure and
an eventual ally-protection variant. Larger HP alone is not a complete tank kit.
If a future PvE threat bonus is added, it must not force human opponents to
target the Troll in PvP. Mobility and control bonuses need actual matchup tests;
do not assume every row has equal value because each has similar percentages.

## 9. Anti-farming and learning safeguards

No XP for empty casts, overhealing, self/friendly damage loops, standing in
fires, movement against walls, unused wards, menus or mere equipment changes.
Training dummies can teach inputs but should stop at Proficiency 5 and award no
Overall XP. Arena sparring remains no-XP with an explicit all-skills mode.

Avoid daily caps on normal play. Bound rewards by the activity, source enemy
and genuine outcome; do not reward one more packet, target tick or button press.
Keep defeated-enemy credit final-hit independent. Public/party/PvP authority and
exploitation checks remain server work, not something the local prototype can
secure. Local telemetry can still test the same rules without a server.

## 10. Implementation and migration sequence

1. Add pure threshold/budget/proficiency models with deterministic tests.
2. Rename visible Adventure Level to Overall Level; remove the averaged badge.
3. Tag abilities with damage type, delivery family and eligibility. Replace
   current raw-HP XP awards with normalized, finite activity credit.
4. Implement Sword and Staff milestone kits, equip checks and selectable
   hotbars; then prototype and validate the other eight authored ladders in
   DESIGN-0019. Their catalog is designed, not yet implemented or playtested.
5. Add meaningful running/endurance and early Willpower training activities,
   then the lineage affinity packages and first weapon-enhanced lineage skills.
6. Update the existing illustrated board: Overall summary, separate Discipline
   and Weapon Proficiency views, requirement links, and lineage-only nodes.
7. Apply bounded stat scaling only after the unlock loop passes playtests.

Preserve existing Overall/old Adventure and Discipline levels plus fractional
progress to the next level when converting XP curves. Reconstruct previously
learned prototype abilities before changing gates; do not silently remove them.
New proficiency tracks start at 1, with a documented legacy unlock policy for
already learned actions. Use a versioned save migration and backup, not reset.
Weapon swaps retain progress; distinct Heroes do not share it.

Collect XP/minute by track, time to first unlock, useful/empty cast ratios,
damage taken per XP, route repetition, and time spent in low-challenge content.
Check that a healer can advance a caster weapon without damage farming, that
good dodging is not worse than face-tanking, and that fast weapons do not beat
slow weapons merely through hit count. A labelled accelerated test profile may
multiply all XP together; never mix its measurements into normal pacing data.
Compare each lineage both with favored weapons and off-affinity builds, including
Troll Staff users and armored Aeralith. Track survival, mobility and ability
uptime separately; fast learning is not evidence of balanced endgame power.

## Current implementation gap

The runtime still uses the previous 1–99 quadratic Discipline curve, the old
averaged Overall summary, Adventure Level, four lineage skills plus two shared
skills, and raw-effect training. Weapon Proficiency does not yet exist there.
This document is the proposed replacement balance, not an implementation claim.
