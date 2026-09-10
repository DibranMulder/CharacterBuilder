---
id: DESIGN-0020
title: Lineage Skills, Spells and Weapon Synergies
status: proposed-balance
updated: 2026-09-10
---

# Eight lineages, eight recognizable combat identities

This specifies all **32 signature lineage abilities**, plus two alternative
weapon-enhancement tiers for each favored family. It extends
[DESIGN-0018](0018-xp-and-weapon-proficiency-balance.md) and uses the combat
safeguards in [DESIGN-0019](0019-weapon-skill-catalog.md). Names and gestures
start from the existing arena kits; changed effects and numbers are proposals,
not changes to the playable prototype.

## Unlocks, resources and delivery

- Each lineage's four rows unlock at Overall **1, 15, 35, 60**, with one
  supporting Discipline at **1, 5, 15, 30** respectively. Both requirements
  must be met. No Talent Points are spent and no weapon is required for the
  base version. Unlocks are permanent for that Hero and lineage.
- Every active costs mana, including physical moves and gadgets. `M / CD`
  denotes flat mana points / cooldown seconds against an initial 100-base-mana
  reference. All cooldown, invalid-target, commitment and weapon-swap rules
  from DESIGN-0019 apply. No special is usable without sufficient mana.
- `P` is a shared lineage-power reference at the Hero's Overall Level and
  equipment tier, normalized to one standard one-second attack's output.
  It is **not** the held weapon's hit damage, the lineage's maximum HP or its
  mana pool. The base level/tier curve remains a combat-scaling implementation
  dependency. Ratios here allow kit comparison before fixing absolute values.
- Physical output receives applicable Strength scaling, magical output Arcana
  scaling; apply the chosen modifier once. Healing/absorption uses the same P
  reference with the appropriate magical modifier only when tagged magical.
  Larger Troll HP therefore does not automatically amplify every Troll skill.
- The table explicitly classifies effects. Physical hits train Attack/Strength,
  physical projectiles Attack, magic Arcana/Focus, and useful evades Agility.
  Effective protection/endurance uses Defense/Stamina as appropriate. All
  rewards share the finite eligible budgets from DESIGN-0018; no XP on cast.
- Innate skills do **not** train a weapon merely held at the time. A variant
  explicitly marked **weapon-delivered** can credit its captured family from
  the existing weapon pool; it does not create a second pool or change damage
  to a weapon-based coefficient. Magical classification is independent of
  weapon delivery. A magical Spear thrust remains magical.
- Innate magic is a lineage permission, not access to caster equipment or Class
  schools. A Centaur Ranger may use Briar Bind without learning Warden Talents;
  a Troll Arcanist may use Boulder Fist without gaining Axe equipment permission.
- All distances use DESIGN-0019's standard body-width gameplay unit, not visual
  lineage size. Unless stated otherwise, cast recovery is initially 0.35s,
  projectiles travel visibly, single-target range is six body widths, and
  heals/wards are self-targeted. Support targeting requires a living friendly
  target and line of sight. No skill here resurrects a defeated Hero.

## Tidekin — wetland skirmisher and recovery

Quick spacing tools and modest water magic; not a sustained front-line tank.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Tongue Snap | Attack 1 | 12 / 6 | **Physical:** 0.3s tell, narrow tongue strike up to two body widths for 0.8P. No pull or stun; guard or step outside its line. |
| 15 | Lily Leap | Agility 5 | 18 / 12 | **Movement:** 0.25s crouch, hop up to three body widths toward the aimed landing point. No damage or invulnerability; terrain and ceilings constrain the arc. |
| 35 | Bog Spit | Survival 15 | 22 / 16 | **Magic:** 0.45s cast, water-and-mire projectile for 0.7P and 25% slow for 2s. Guard prevents slow; visible travel permits evasion. |
| 60 | Springwater | Survival 30 | 28 / 24 | **Magic:** 0.7s vulnerable cast, heal self for 1.2P over 3s. Moving after release is allowed; no cleanse, overheal ward or burst full heal. |

Survival gates represent wetland remedies and fieldcraft. Survival training
must include repeatable eligible field preparation and hazard activities before
these gates, not depend on already knowing Springwater. Bog Spit opens mystical
training but Arcana is not required before the first available magical action.

## Humans — adaptable resolve

A straightforward opening strike, decisive approach and measured recovery.
Their resilience is physical/morale-based rather than a mandatory caster path.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Crosscut | Attack 1 | 14 / 6 | **Physical:** 0.4s tell, two short crossing strikes, 0.9P total, one target. Unarmed forearm strikes are the base; equipped presentation must not add weapon XP automatically. |
| 15 | Resolute Rush | Stamina 5 | 20 / 12 | **Physical/movement:** 0.35s tell, advance up to two body widths; first target takes a 0.65P shoulder impact. Stops on collision; no guard, immunity or automatic stun. |
| 35 | Rally | Stamina 15 | 22 / 18 | **Physical protection:** 0.4s rally gesture, self gains a 0.9P temporary ward for 4s. No mana regeneration or damage buff; pressure exhausts it. |
| 60 | Second Wind | Stamina 30 | 28 / 26 | **Physical recovery:** 0.8s vulnerable preparation, restore 1.1P HP over 3s. No cleanse or resurrection; continued pressure can overwhelm recovery. |

Resolute Rush is the proposed display-name replacement for **Shield Rush**:
the innate action cannot require or conjure a forbidden Shield for non-Vanguards.
A legally equipped Shield may appear in its animation, without free blocking.
Human Crosscut and the Duelist Crosscut Talent need distinct stable IDs and
visible source labels; they are not two copies of the same unlock.

## Grove Centaurs — momentum and living ground

Long repositioning and localized grove magic, with vulnerable turning and
telegraphed landings. No immunity from being mounted-looking or having four legs.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Gallop Strike | Attack 1 | 18 / 8 | **Physical/movement:** 0.4s lowering tell, rush up to three body widths; first body collision deals 0.85P and ends movement. No enemy pass-through or invulnerability. |
| 15 | Rearing Stomp | Stamina 5 | 20 / 14 | **Physical:** 0.6s rear-up, ground impact within 1.5 body widths; up to two enemies take 0.7P each and a 0.35s stagger. Jump clear or block the landing. |
| 35 | Briar Bind | Survival 15 | 24 / 18 | **Magic:** 0.6s cast, visible seed projectile deals 0.45P and roots for 0.6s. Root stops translation, not attacking or casting; guard prevents it. |
| 60 | Grove Renewal | Survival 30 | 30 / 26 | **Magic:** 0.7s cast places a visible three-body-width grove circle for 3s. Self and at most one nearby ally each recover up to 0.8P while inside. Leaving forfeits remaining ticks. |

Grove fieldcraft follows the same accessible Survival training requirement as
Tidekin. Neither spell requires prior Wand access. Galloping, rearing and
landing must animate the unified horse body/legs, not reintroduce leg sprites.

## Aeralith — wind, spacing and light protection

Strong repositioning, weak stationary trading. Flight-shaped animation grants
neither unlimited flight nor an untargetable airborne state.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Gale Needle | Arcana 1 | 12 / 6 | **Magic:** 0.3s cast, narrow wind projectile for 0.8P. No automatic slow or tracking. |
| 15 | Slipstream | Agility 5 | 18 / 12 | **Movement:** 0.2s tell, retreat up to two body widths with brief aerial steering. No invisibility, damage or invulnerability; collisions stop travel. |
| 35 | Cyclone | Arcana 15 | 24 / 18 | **Magic:** 0.65s visible gathering wind, burst within 1.5 body widths, up to three targets for 0.65P each; push one body width. Block denies push, heavy bosses remain planted. |
| 60 | Zephyr Veil | Focus 30 | 28 / 24 | **Magic:** 0.45s cast, self ward absorbs 1P for up to 4s. Movement remains normal; no reflection, immunity or automatic evade. |

Gale Needle supplies an immediate Arcana/Focus training path. Slipstream only
awards Agility when it actually avoids a qualifying threat; repeated empty
retreats do not accelerate training.

## Crag Trolls — hold space and absorb pressure

The tank identity combines innate HP/Stamina with active absorption and short
peels. Their long wind-ups make evasion and ranged pressure meaningful answers.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Boulder Fist | Strength 1 | 18 / 8 | **Physical:** 0.65s heavy fist tell, one target within 1.5 body widths takes 1.1P and increased guard pressure. No unconditional stun or armor bypass. |
| 15 | Stonebreak | Stamina 5 | 24 / 16 | **Physical:** 0.75s ground slam, narrow marked lane three body widths long; up to two targets take 0.8P each and a 0.35s stagger. Jump/evade the lane or block. |
| 35 | Stonehide | Stamina 15 | 26 / 22 | **Physical protection:** 0.5s brace; gain 1.4P absorption for 4s at 80% movement speed. Physical skin hardening, not a magical ward requiring Focus. Ends when exhausted; grants no control immunity. |
| 60 | Mountain Charge | Stamina 30 | 30 / 26 | **Physical/movement:** 0.65s tell, rush up to three body widths; first target takes 0.9P and is pushed one body width. Charge stops there. If Stonehide is active, an adjacent ally can receive its remaining absorption and duration, removing it from the Troll. No duplication or forced PvP targeting. |

**Stonebreak** is the proposed display-name replacement for the prototype
Troll **Faultline**, avoiding confusion with the Ravager Class Talent. The
existing gesture stays the presentation basis. Stonehide protection trains
only when it absorbs real threat. Mountain Charge's ally transfer is optional,
requires an explicitly selected ally within two body widths at charge end,
and adds no extra ward if the recipient already has a stronger Stonehide.
Rejected transfer leaves the Troll's original ward unchanged. This introduces
a deliberate sacrifice for protection, not an automatic extra party shield.

## Deep Goblins — gadgets, disruption and opportunism

Physical improvised projectiles and alchemy. Gadget mana costs are a shared
gameplay resource, not evidence that every Goblin has trained Arcana.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Scrap Shot | Attack 1 | 12 / 6 | **Physical projectile:** 0.3s improvised wrist-launcher shot for 0.75P. Usable without a Crossbow; no magical classification from projectile animation alone. |
| 15 | Snare Canister | Attack 5 | 20 / 14 | **Physical gadget:** 0.5s lob, visible landing marker with at least 0.5s warning; first enemy within one body width of impact takes 0.4P and a 0.6s root. No persistent invisible trap; guard denies the root. |
| 35 | Smoke Hop | Agility 15 | 22 / 16 | **Movement/gadget:** retreat two body widths, leaving a 2s cosmetic smoke puff marking the departure point. No stealth, target-lock break, immunity or authoritative vision blocking. |
| 60 | Siphon Dart | Attack 30 | 26 / 22 | **Physical/alchemical:** 0.55s projectile for 0.85P; return 50% of eligible HP damage actually dealt as self-healing, capped at 0.425P. No healing from shields, overkill, invulnerable targets or a miss. |

Smoke Hop is an evasive positioning tool, not a weaker implementation of a
future stealth system. Its puff must not obscure enemy telegraphs. Siphon Dart
is alchemical recovery and does not train Arcana/Focus; using its healing to
manufacture friendly-damage XP remains invalid.

## Sunscour — heat, shifting sand and endurance

Close magical pressure and short repositioning. Sun magic is innate and does
not depend on the removable balaclava/head equipment or permanent Allegiance.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Searing Thrust | Arcana 1 | 14 / 6 | **Magic:** 0.4s palm thrust creates a short heat lance up to two body widths for 0.9P. No Spear needed, burn stacking or automatic armor penetration. |
| 15 | Dune Step | Agility 5 | 18 / 12 | **Movement:** 0.25s tell, slide up to two body widths in the chosen direction. No damage, teleport, immunity or travel through creatures. |
| 35 | Sandglass | Arcana 15 | 24 / 18 | **Magic:** 0.55s cast, sand projectile for 0.7P and 25% slow for 2s. Visible travel; blocked impact applies no slow. |
| 60 | Mirage Guard | Focus 30 | 28 / 24 | **Magic:** 0.45s cast, gain 1P ward for 4s. A translucent afterimage shows the ward, but the real body remains readable and targetable; no random miss chance or reflected damage. |

Searing Thrust starts Arcana/Focus training immediately. Dune Step trains
Agility through meaningful evasion, never by repeatedly spending mana safely.

## Rimeborn — deliberate frost and resilient concentration

Readable control, a vulnerable recovery window and a close defensive burst.
Control is short and shares the same diminishing returns as every other kit.

| Overall | Ability | Discipline | M / CD | Proposed effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Ice Shard | Arcana 1 | 14 / 6 | **Magic:** 0.4s cast, frost projectile for 0.85P. Basic version has no free permanent slow. |
| 15 | Rime Prison | Arcana 5 | 22 / 16 | **Magic:** 0.6s cast, visible projectile for 0.45P and a 0.6s root. Not a stun or full ice invulnerability; defender can attack and cast while rooted. |
| 35 | Aurora Mend | Focus 15 | 26 / 22 | **Magic:** 0.8s vulnerable cast, restore 1.1P self HP over 3s. No cleanse, ward or cast-interruption immunity. |
| 60 | Winter Halo | Willpower 30 | 30 / 26 | **Magic:** 0.65s gathering ring, burst within 1.5 body widths; up to three enemies take 0.7P each and a 25% slow for 2s. No extra root, knockback or repeat ticks. |

Ice Shard and Rime Prison provide early mystical training. Winter Halo's
Willpower requirement relies on the early pressure encounters/concentration
trials from DESIGN-0018, not on already possessing a control-resistance skill.

## Favored-weapon enhancements — choice, not another stacking tree

The base ability must first be unlocked. At **family proficiency 15**, learn
the first enhancement below; at **50**, learn its alternative. Choose at most
one enhancement for an ability in the menu, not both. It only functions while
the permitted source weapon is equipped; otherwise the base skill remains
available. Variants keep the base mana cost, cooldown and power reference.
No variant grants an otherwise forbidden weapon or requires wearing a head item.

| Lineage / favored family | Enhanced skill | Proficiency 15 choice | Proficiency 50 alternative |
| --- | --- | --- | --- |
| Tidekin / Spear | Tongue Snap | **Reed Follow-up:** on tongue hit, optional Spear thrust within 1s for 0.25P, reach 1.25× ordinary Spear reach; weapon-delivered follow-up only. | **Reed Retreat:** after tongue hit, optional one-body-width backstep instead of extra damage; no invulnerability, base tongue remains innate. |
| Tidekin / Wand | Bog Spit | **Mire Splash:** target plus at most one nearby enemy within one body width receives the base slow; damage remains single-target. Weapon-delivered cast. | **Clearwater Spit:** trade the slow for reducing the struck enemy's next hit damage by 15% within 3s; one hit only. Weapon-delivered cast. |
| Humans / Sword | Crosscut | **Third Beat:** optional 0.25P Sword follow-up within 1s of a hit; weapon-delivered follow-up only. | **Measured Guard:** instead of follow-up damage, a hit discounts the next legally available guard's Stamina cost by 15% within 2s. No new guard permission; base Crosscut remains innate. |
| Humans / Crossbow | Rally | **Ready Resolve:** while Rally survives, next reload is 15% faster; consumes on reload start. Innate ward, no weapon XP from reloading. | **Steady Stock:** while Rally survives, next Braced Bolt aim wind-up is 0.4s rather than 0.5s. No damage bonus or free bolt; Rally remains innate. |
| Grove Centaurs / Bow | Gallop Strike | **Gallop Shot:** replace collision damage with one manually aimed 0.85P arrow during the rush; weapon-delivered. No collision hit as well. | **Covering Gallop:** Gallop Shot deals 0.65P and, on hit, slows 20% for 1.5s instead. One projectile, weapon-delivered. |
| Grove Centaurs / Spear | Gallop Strike | **Forward Point:** stop before contact and deliver a 0.85P Spear thrust at ordinary Spear reach rather than a body hit; weapon-delivered. | **Measured Gallop:** shorten rush to two body widths, thrust for 0.7P, then optionally retreat one body width after a hit. Weapon-delivered, no invulnerability. |
| Aeralith / Wand | Gale Needle | **Threaded Gale:** pierce one additional target for 0.3P; original target remains 0.8P. Weapon-delivered cast. | **Checked Gale:** single-target 0.7P with a 20% slow for 1.5s, no piercing. Weapon-delivered cast. |
| Aeralith / Staff | Cyclone | **Wide Spiral:** radius becomes two body widths; unchanged damage and three-target cap. Weapon-delivered cast. | **Sheltering Spiral:** remove push and reduce damage to 0.5P each; grant self 0.4P absorption for 2s only if an enemy is hit. Weapon-delivered cast. |
| Crag Trolls / Blunt | Boulder Fist | **Hammer Fist:** replace fist contact with a Blunt strike at base skill reach, same damage and 20% more guard pressure. Weapon-delivered. | **Sheltering Blow:** same weapon-delivered strike without extra guard pressure; on hit, reduce next guard Stamina cost by 15% within 2s if the Class permits guarding. No free Shield permission. |
| Crag Trolls / Axe | Stonehide | **Granite Edge:** after eligible absorption, next Axe basic within the ward's duration may cleave one additional target for 0.25P. Once per Stonehide; only follow-up is weapon-delivered. | **Anchored Edge:** instead of cleave, eligible absorption grants the next Axe basic 20% extra guard pressure. Once per cast, expires with ward; no damage increase. |
| Deep Goblins / Crossbow | Scrap Shot | **Scrap Bolt:** replace wrist gadget with a loaded Crossbow shot, same 0.75P; next reload 15% faster. Consumes one bolt; weapon-delivered. | **Scatter Scrap:** loaded Crossbow fires three fragments, 0.45P each, maximum one fragment per target. No reload bonus; consumes one bolt, weapon-delivered. |
| Deep Goblins / Dagger | Smoke Hop | **Smoke Opening:** if the hop evades a real attack, next Dagger basic within 1.2s adds 0.25P. One use; only the follow-up is weapon-delivered. | **Long Opening:** the same genuine evade instead extends Patient Answer's availability from 1.2s to 2s, if learned. No bonus damage or free unlock; hop remains innate. |
| Sunscour / Spear | Searing Thrust | **Sunpoint:** channel the magical thrust through a Spear at 1.25× ordinary Spear reach, same damage. Weapon-delivered magic, not extra physical damage. | **Returning Sun:** ordinary Spear reach, 0.75P; a hit allows a one-body-width retreat. Weapon-delivered magic, no invulnerability. |
| Sunscour / Wand | Sandglass | **Heavy Grains:** slow becomes 30% for 2s, unchanged single-target damage. Weapon-delivered cast; shared slow cap applies. | **Scattered Grains:** damage becomes 0.55P, applying base slow to target plus one enemy within one body width. Weapon-delivered cast. |
| Rimeborn / Staff | Ice Shard | **Rime Trace:** after impact, leave a one-body-width patch for 2s, slowing occupants 20% only while inside. No patch damage; weapon-delivered cast. | **Quiet Ice:** no patch; impact instead reduces the target's next magical hit damage by 15% within 3s, once. Weapon-delivered cast. |
| Rimeborn / Blunt | Winter Halo | **Winter Weight:** deliver Halo through a Blunt ground strike, same magical damage with 20% extra guard pressure; no physical damage added. Weapon-delivered magic. | **Winter Shelter:** weapon-delivered ground strike trades slow for 0.5P self-absorption for 2s if an enemy is hit. Damage stays 0.7P each; no stacking wards. |

Weapon-delivered variants use the base attack's aim/collision safeguards and
the captured family for credit. A new optional follow-up has its own visible
wind-up/recovery and no independent mana charge. Mixed-family weapons cannot
activate two variants of the same ability. Leaving the source loadout cancels
unreleased weapon follow-ups; already released projectiles finish normally.

An enhancement that needs another action (Braced Bolt, Patient Answer or a
legal guard) shows that requirement in the menu. It never grants the action
early; the player can keep the other enhancement or base ability instead.

## Global limits and practical examples

- Apply DESIGN-0019's target-shared six-second hard-control diminishing returns,
  strongest-slow rule and ward replacement rules to **all** lineage skills.
  Extend the four-second continuous slow limit and two-second slow immunity to
  lineage slows too; a weapon/lineage rotation cannot bypass it. No proc resets
  hard-control immunity or refreshes another caster's root for free.
- Next-hit damage reductions use the strongest eligible reduction, not their
  product. They expire after that hit or their timer. Ward and damage reduction
  order must be shared with the rest of combat. Absorption remains finite.
- Lineage wards never stack with another copy of themselves, and short variant
  wards replace their own previous instance. Party ward caps remain a required
  multiplayer balance step, not authority solved by this local design.
- Successful guarding prevents hostile secondary control. Heavy-boss immunity
  stops displacement/control without granting bonus damage. Rimeborn Willpower
  reduces eligible magical control, not physical Troll or Blunt stagger.
- No movement ability crosses solid geometry, arena limits or unsupported
  terrain. Root prevents movement skills until cleared; it does not prevent
  their non-movement peers. Friendly protection never forces PvP opponents to
  attack the protector. All-skills bot testing still grants no progression XP.
- Choose four active skills **in total**, mixing weapon and lineage choices,
  plus the equipped weapon's basic. Unlocking four lineage skills does not
  automatically add four more play-screen buttons.

Example Troll Vanguard: Boulder Fist, Stonehide, Mountain Charge and Blunt
Roommaker give pressure, personal protection and a deliberate ally peel. A
Troll Arcanist can instead slot Stonehide beside three Staff spells and keeps
its physical toughness, without gaining forbidden Blunt gear.

Example Aeralith caster: Gale Needle, Slipstream, Staff Frost Bind and Wand
Stitchlight are **not** a simultaneously usable single-weapon loadout. Choose
one equipped family and its valid skills, or explicitly manage a weapon swap
with cooldowns preserved. Innate Gale Needle and Slipstream remain available
through either loadout; no hidden Wand permission is granted by holding Staff.

## Training, visual design and migration acceptance

Every ability's visual treatment, signature beat sheets and bounded map
reactions are specified in [DESIGN-0021](0021-skill-visual-direction.md).

1. Build the unlock/training graph before enabling gates: physical lineages
   must not need caster equipment to unlock an innate skill, and no first
   magical spell may require magic XP with no earlier permitted training path.
   Survival activities and Willpower trials are required content dependencies.
2. Preserve the current four builder-gesture slots per lineage and use their
   existing ordering. Names, mechanics, damage classification and XP tags are
   separate data. A `bolt` animation does not make Scrap Shot magical; a `ward`
   animation does not force Stonehide's requirement to Defense or Focus.
3. Reuse the Chronicle skills view and round illustrated nodes. Show Overall
   and Discipline gates, base effect, selected enhancement, weapon condition,
   mana, cooldown and the actual character's gesture preview. Separate lineage
   and weapon paths visually inside the same menu and keep keybinds under HP.
4. Human Resolute Rush and Troll Stonebreak preserve their legacy slot/save
   identity through explicit aliases, not destructive save replacement. Human
   and Duelist Crosscut receive distinct source IDs. Prototype unlocks need the
   preservation policy from DESIGN-0018 when old 1/3/5/8 gates are migrated.
5. Preview both directions with actual gear. Trolls never gain scarves;
   Centaurs retain unified horse bodies and forbidden equipment slots; Sunscour
   magic works with the removable balaclava off. Crossbow variants stay
   horizontally shouldered, and Staff casts move forward rather than backward.
6. Test all base skills with an off-affinity permitted weapon, all 32 enhancement
   choices with matching gear, and swaps during each pending effect. Verify
   no double hits, duplicated ward transfers, free reloads or redirected XP.
7. Compare each lineage's burst, escape, sustained survival and mana exhaustion
   in the local arena. Include healing matchups and multiple attackers trying
   to chain roots/staggers. Affinity XP rates are not proof of combat balance.

The complete candidate catalog is now specified. Absolute P scaling, shared
mana regeneration, guard pressure and animation timings still need tuning in
the prototype before these skills can be called balanced or implemented.
