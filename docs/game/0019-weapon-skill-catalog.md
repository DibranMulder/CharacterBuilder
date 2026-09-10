---
id: DESIGN-0019
title: Weapon Skills — Eight Remaining Families
status: proposed-balance
updated: 2026-09-10
---

# Weapon mastery should change how you fight

This completes the candidate seven-milestone ladders for Axe, Spear, Polearm,
Bow, Crossbow, Wand, Dagger and Blunt. Sword and Staff remain in
[DESIGN-0018](0018-xp-and-weapon-proficiency-balance.md#sword-proposal).
Together these are ten families with seventy entries, including ten basics.
These are authored design proposals, not implemented or measured balance.

## Shared rules

- Milestones are Weapon Proficiency **1, 5, 15, 30, 50, 75, 99**. Requirements
  in each row are additional Discipline levels; all listed requirements apply.
  There is no extra Overall gate on weapon skills. Level-1 basics are always
  available with permitted equipment. Later rows do not require purchasing or
  slotting earlier rows. No Class Talent Points are spent here.
- Every non-basic active costs **mana**, including physical techniques. Mana
  cost alone does not make an action magical. Costs below are flat points,
  tuned initially against 100 base mana, not percentages of maximum mana.
  Basic attacks cost zero mana. Mana recovery remains a shared combat-system
  tuning dependency; no weapon grants an unlimited self-funding rotation.
- `M / CD` means mana points / cooldown seconds. Cooldowns begin on commitment,
  persist through weapon swaps and belong to the skill, not the individual
  item. Charges, follow-ups and repeats are included in the listed cost unless
  explicitly stated otherwise. Unused follow-ups expire without a refund.
- Check target, equipment and resources before commitment. Invalid activation
  costs nothing. After the authored release/commit point, a miss or interruption
  consumes the cost and cooldown. Wind-up and recovery cannot be skipped by
  swapping weapons; ordinary hit reactions still apply unless explicitly stated.
- One-/two-handed variants use the same family ladder and training. Existing
  Class/Grip permissions in DESIGN-0012 still apply. Polearm and Bow require
  two hands; Crossbow uses its approved grip. These ladders grant no new Grip
  permissions. Paired weapons do not duplicate damage, buffs or XP awards.
- A skill's source family and hand are captured at activation. Numerical
  damage uses that source weapon, never the sum of two equipped weapons.
  Family basics and cadence must first be normalized for comparable sustained
  output at equivalent equipment tiers.

### Reading the numbers

`D` is one unmodified basic hit from the source weapon at the same equipment
tier, before mitigation. It is a starting coefficient, not equal DPS between
fast Daggers and slow Blunt weapons. Physical skills deal physical damage;
Wand spells deal magical damage. A listed coefficient is total damage across
all strikes/ticks unless the row explicitly says **each**. Healing and shield
coefficients use the Wand's corresponding spell-power reference, also called
`D`, not the target's HP. They do not inherit offensive critical-hit bonuses.

`R` is that equipped weapon's ordinary attack reach. Movement distances use
body widths: one shared gameplay unit based on the standard humanoid body,
not a lineage's visual width. Obstacles and arena boundaries always stop moves.
AoE rows have explicit target caps; no repeated hits on one target per sweep.

## Axe — punish openings and keep pressure

**Rhythm:** readable wind-up, committed chop, short pursuit. Unlike Blunt, Axe
converts openings into damage rather than specializing in repeated disruption.
Unlike Sword, it has fewer forgiving recoveries. All rows support permitted
one- or two-handed Axes; none require Dual Wield or a Shield.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Hew | None | 0 / cadence | Basic frontal chop, 1D to one target. Visible recovery after a miss. |
| 5 | Committed Chop | Strength 3 | 8 / 6 | 0.55s wind-up, 1.4D to one target. No tracking after release; step aside or block. |
| 15 | Raking Edge | Attack 10, Strength 5 | 12 / 10 | 0.8D impact plus 0.4D bleed over 4s. Same-caster bleed refreshes, never stacks; cleansing removes remaining ticks. |
| 30 | Pursuing Hew | Attack 20, Agility 10 | 16 / 12 | Advance up to two body widths, then chop for 1.15D. No invulnerability, teleport or passage through enemies; punish the approach. |
| 50 | Broad Reap | Strength 30, Attack 20 | 20 / 16 | 0.7s wind-up; frontal sweep hits up to three targets for 0.9D each. Rear and aerial space remain open. |
| 75 | Split Decision | Attack 40, Strength 30 | 24 / 20 | First chop 0.7D; press again within 1s for a delayed 0.9D return cut. Both share one commitment cost; defender can evade the second beat. |
| 99 | Headsman's Measure | Strength 60, Attack 45 | 30 / 30 | 0.9s overhead wind-up, 1.8D; becomes 2.2D if the target is below 30% HP at impact. Not an execution or instant kill; blockable and interruptible. |

Training: useful hits train Axe, Attack and Strength. Bleed shares the original
action budget. Pursuit grants Agility only if it genuinely evades a threat,
not merely because its animation moves the character.

## Spear — own the edge of reach

**Rhythm:** keep distance, intercept an approach, retreat before being crowded.
Works with permitted one-handed Vanguard and Ranger Spear loadouts; no row
requires a Shield. Tip bonuses reward spacing without random accuracy rolls.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Straight Thrust | None | 0 / cadence | Narrow 1D thrust. Long reach, limited vertical coverage. |
| 5 | Tip Strike | Attack 3 | 8 / 6 | 1.1D, increased to 1.4D when the target is in the outer quarter of R at impact. Close distance to deny the bonus. |
| 15 | Withdrawn Point | Attack 10, Agility 5 | 12 / 10 | 0.8D thrust, then retreat one body width if ground is available. No invulnerability or ledge crossing; chase during recovery. |
| 30 | Set the Point | Attack 20, Stamina 10 | 16 / 14 | After 0.3s setup, hold a visible frontal point for up to 1s. First enemy advancing into it takes 1.2D and a 0.35s stagger; then stance ends. Projectiles, rear attacks and waiting beat it. |
| 50 | Driving Lunge | Attack 30, Strength 20 | 20 / 16 | 0.65s wind-up; step one body width and thrust to 1.25R for 1.5D. Narrow lane; no homing or enemy pass-through. |
| 75 | Turning Shaft | Attack 40, Agility 30 | 24 / 20 | Close sweep hits up to two targets for 0.7D each and pushes them one body width away. Not a Shield block; armored bosses retain position. |
| 99 | Three-Point Measure | Attack 60, Agility 45 | 30 / 30 | Three manually aimed thrusts over 1.4s, 0.6D each; final thrust gains 0.3D at tip range. Direction locks per thrust, not per full combo; no stagger on every hit. |

Training: Spear, Attack and Strength from effective thrusts. Successful
interception may train Stamina under pressure; retreat only trains Agility
when it avoids a genuine attack. Defense is not a mandatory progression gate
for Rangers who cannot equip a Shield.

## Polearm — shape space around groups

**Rhythm:** choose an arc, commit, recover. Two-handed Ravager weapon. Wider
coverage than Spear but less precise and easier to punish at close range.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Long Sweep | None | 0 / cadence | Frontal 0.85D arc, up to two targets; slower recovery than a Spear thrust. |
| 5 | Narrow End | Attack 3 | 8 / 6 | Fast, narrow 1.1D thrust to one target. Sacrifices the basic sweep's coverage. |
| 15 | Hook and Draw | Attack 10, Strength 5 | 12 / 12 | Readable hook at outer reach, 0.7D and pull up to one body width toward the wielder. No stun; blocking prevents the pull, heavy bosses are immovable. |
| 30 | Clearing Wheel | Strength 20, Stamina 10 | 18 / 14 | 0.7s wind-up; planted full sweep, 1D each to up to three targets. Cannot move or become invulnerable during the sweep. |
| 50 | Low Harvest | Attack 30, Strength 20 | 20 / 18 | Low frontal arc, 0.9D each to up to three targets; 25% slow for 2s. Jump over the low arc or block; no root. |
| 75 | Overhead Reach | Strength 40, Attack 30 | 24 / 20 | 0.85s telegraphed downward strike reaching 1.3R, 1.6D to one target. Catches aerial approaches; narrow ground impact leaves lateral escape. |
| 99 | Reaper's Circuit | Strength 60, Stamina 45 | 32 / 30 | Two visible sweeps over 1.6s, at most three targets and 1.8D total per target. Slow movement allowed, no dodge during commitment; targets can leave before the return sweep. |

Training: Polearm, Attack and Strength; target count does not multiply an
encounter's XP budget. These are physical weapon arcs, not Ravager Faultline
eruptions or a new source of free terrain destruction.

## Bow — draw timing and mobile precision

**Rhythm:** read a moving target, draw, release and reposition. No reload meter.
The basic draw takes 0.6s to full power; moving while drawing is initially 70%
normal speed. Basic release deals 0.6D–1D by draw duration. Specials have their
own stated wind-up and do not require a second full basic draw.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Draw and Loose | None | 0 / cadence | Visible aimed projectile using the shared draw rule. No homing or random miss after a collision. |
| 5 | Snap Arrow | Attack 3 | 8 / 6 | 0.15s draw, 0.8D shot without draw movement penalty. Trading mana for responsiveness, not superior sustained damage. |
| 15 | Retreating Loose | Attack 10, Agility 5 | 12 / 10 | Step backward one body width while releasing a 0.8D arrow. No invulnerability, auto-aim or leap over obstacles. |
| 30 | Hampering Arrow | Attack 20, Agility 10 | 16 / 14 | 0.6s draw; 0.8D and 25% movement slow for 2s. Blockable projectile, no immobilization or crippled equipment. |
| 50 | Forked Volley | Attack 30, Agility 20 | 20 / 16 | 0.7s draw; three arrows in a visible fan, 0.65D each. A target can take only one arrow per volley; spread coverage, not point-blank triple damage. |
| 75 | Lofted Shot | Attack 40, Agility 30 | 24 / 20 | 0.8s draw; lob onto a visible ground marker within screen range, 1.2D each to up to three targets. Minimum 0.7s landing warning; overhead cover stops it. |
| 99 | Running Cadence | Attack 60, Agility 45 | 30 / 30 | For 4s, manually release up to three 0.65D arrows at least 0.6s apart while moving at full speed. Replaces basic shots during the window; no automatic tracking, bonus basic attacks or invulnerability. |

Training: Bow and Attack, not Strength or Arcana. Useful evasion can train
Agility. Precision means aiming and spacing; ordinary attacks must remain
usable without pixel-perfect headshots on differently shaped lineages.

## Crossbow — commit a shot, manage the reload

**Rhythm:** ready, shoulder, fire, reload behind cover. One loaded bolt;
baseline reload 1.4s at 60% movement speed, compared with Bow's mobile draw.
Every projectile row requires and consumes one loaded bolt; no ammo inventory
system is added by this proposal. Manual or automatic reload restores one bolt
after completion. Interrupted reloads restart; weapon swapping never reloads.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Shouldered Bolt | None | 0 / reload | 0.2s shoulder-and-aim release, 1D projectile. Wield horizontally from the shoulder in both facing directions. |
| 5 | Braced Bolt | Attack 3 | 8 / 6 | 0.5s planted aim, 1.35D. Cannot move during aim; dodge or pressure the stationary shooter. |
| 15 | Combat Reload | Attack 10, Agility 5 | 12 / 12 | Only usable while empty; replace reload with a visible 0.8s reload at full movement speed. No free shot, ammo overfill or invulnerability. |
| 30 | Disrupting Bolt | Attack 20 | 16 / 14 | 0.45s aim; 0.85D and 0.35s stagger, interrupting only interruptible actions. Block or evade the visible projectile. |
| 50 | Bodkin Bolt | Attack 30 | 20 / 16 | 0.7s planted aim, 1.25D; ignores 20% of the target's armor mitigation, not 20 percentage points. Still blocked normally; does not pierce extra targets. |
| 75 | Measured Pair | Attack 40, Agility 25 | 26 / 22 | First 0.75D shot, then a visible 0.9s reload, then optional second 0.75D shot within 2s. Entire sequence paid once; interruption cancels the follow-up. Ends empty and cannot interleave basic shots. |
| 99 | Siege Measure | Attack 60, Stamina 35 | 32 / 30 | 1.1s planted aim with visible aiming line, 2D single-target bolt with increased guard pressure. Not guard bypass, homing or a screen-wide instant hit. Long recovery and empty weapon afterward. |

Training: Crossbow and Attack. Combat Reload grants no XP by itself; it can
share credit from the next effective shot without increasing its budget. It
does not train Focus merely because it costs mana. Reload bonuses from Human
Rally, Goblin Scrap Shot or Class Talents use the strongest applicable speed
bonus, not multiplicative stacking; minimum actual reload is 0.6s. These
bonuses never add bolts or skip the visible reload sequence.

## Wand — precise magic, efficient support

**Rhythm:** short targeted casts, single-target recovery and careful cleansing.
Staff keeps the heavier elemental and area-spell identity. This common Wand
kit is school-neutral magic, not access to Warden Radiance/Gloam Class Talents.
Both permitted caster Classes can use it; Class trees supply school mechanics.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Lumen Pin | None | 0 / cadence | Small 1D magical projectile with visible travel. Reliable solo training; no free healing alternative. |
| 5 | Stitchlight | Arcana 3 | 10 / 6 | 0.5s cast; heal self or one ally for 0.9D within 6 body widths and line of sight. No overheal shield; interrupt or pressure the caster. |
| 15 | Needle Hex | Arcana 10, Focus 5 | 12 / 10 | Projectile deals 0.9D and marks for 3s; next Wand basic hit adds 0.25D and consumes the mark. One mark per caster, no party-wide damage amplification. |
| 30 | Threadward | Focus 20, Arcana 15 | 18 / 14 | 0.4s cast; shield self or one ally within 6 body widths for 1.1D absorption, expires after 4s. Does not stack with itself; sustained attacks exhaust it. |
| 50 | Unravel | Focus 30, Willpower 15 | 22 / 18 | 0.6s cast; remove one eligible magical slow, root, fear or curse from self/ally within 6 body widths. Prioritize fear, root, slow, then curse. No healing, physical-stagger cleanse or use while actions are fully disabled. |
| 75 | Steady Thread | Focus 40, Willpower 25 | 26 / 22 | Channel 2s to heal self/one ally for 1.8D total within 6 body widths. 50% movement speed; breaking range/line of sight or interruption ends remaining ticks without refund. |
| 99 | Returning Light | Arcana 60, Focus 45, Willpower 35 | 32 / 30 | 0.8s aimed projectile hits one enemy for 1.1D; on hit, a visible return mote heals the caster for 0.9D. Miss/block gives no mote. Not a resurrection, party heal or mana refund. |

Training: useful damage, healing and absorbed shields train Wand, Arcana and
Focus. Effective cleansing also trains Willpower; ordinary safe healing does
not. Eligible support gets comparable access to the shared weapon XP budget,
not lower credit merely for doing no damage. Lumen Pin or the capped training
dummy gets a new Wand user to the first heal; early concentration trials in
DESIGN-0018 provide Willpower before Unravel's gate.

## Dagger — create and exploit a short opening

**Rhythm:** enter close range, bait a response, strike, leave. No permanent
stealth or guaranteed rear-position critical hits. All coefficients refer to
the triggering Dagger; a paired weapon does not double them. Duelist loadouts
still require two permitted one-handed weapons, but not necessarily two Daggers.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Close Prick | None | 0 / cadence | Short 1D stab; quick cadence, limited reach and little guard pressure. |
| 5 | Double Prick | Attack 3 | 8 / 6 | Two visibly separate stabs, 0.65D each. Defender can evade the second; does not trigger on-hit effects twice without an explicit effect budget. |
| 15 | Retreating Nick | Attack 10, Agility 5 | 12 / 10 | 0.8D cut followed by one-body-width retreat. No teleport, invulnerability or inherent bleed. |
| 30 | Held Point | Attack 20, Agility 10 | 16 / 12 | Hold a visible poised stab for up to 0.8s, then release for 1.2D. Deals 1.5D if the target is in an authored attack-recovery window. Holding grants no protection; attack or disengage. |
| 50 | Tendon Touch | Attack 30, Agility 20 | 20 / 16 | Close 0.9D strike, 25% movement slow for 2s. No root, teleport or automatic rear hit; guard denies the slow. |
| 75 | Patient Answer | Attack 40, Agility 30 | 24 / 20 | Available for 1.2s after a genuine successful evade using any permitted movement action; 1.6D close stab. Grants no dodge itself and cannot store multiple evade charges. |
| 99 | Needle Sequence | Attack 60, Agility 45 | 30 / 30 | Three manually timed stabs over 1.2s for 0.5D, 0.5D and 0.9D. Final gains 0.3D if it catches an attack-recovery window. No per-hit stun, invulnerability or target chasing. |

Training: Dagger, Attack and Strength from effective hits, Agility from actual
evades. Recovery windows must be explicitly authored for creatures and player
actions and visibly readable; do not infer them from animation names. Bosses
can expose punish windows without being susceptible to crowd control.

## Blunt — pressure the guard, protect the opening

**Rhythm:** slower impacts, high guard pressure and short, earned disruption.
This is the natural Troll tank weapon, but dealing Blunt damage does not force
PvP targeting or replace Shield defense. All rows work with permitted one- or
two-handed Blunt loadouts; no Shield requirement on the mastery ladder.

| Proficiency | Skill | Discipline requirements | M / CD | Effect and counterplay |
| ---: | --- | --- | --- | --- |
| 1 | Weighted Blow | None | 0 / cadence | Slow 1D frontal strike with ordinary family guard pressure. No automatic stun. |
| 5 | Knocking Blow | Strength 3 | 8 / 6 | 0.55s wind-up, 1.15D with 1.5× basic guard pressure. Guard absorbs damage normally; sidestep the committed swing. |
| 15 | Checking Tap | Attack 10, Strength 5 | 12 / 12 | Short 0.75D strike with 0.35s stagger on an unguarded hit. Does not chain-stun or bypass uninterruptible boss attacks. |
| 30 | Grounded Swing | Strength 20, Stamina 10 | 16 / 14 | 0.7s planted wind-up, 1.4D and 1.5× basic guard pressure. No super armor or immunity while preparing. |
| 50 | Roommaker | Strength 30, Attack 20 | 20 / 18 | Frontal sweep, up to two targets for 0.8D each; push one body width away. Block prevents push; useful for peeling without forced targeting. |
| 75 | Bracebreaker | Strength 40, Stamina 30 | 26 / 22 | 0.9s overhead tell, 1.2D and 2× basic guard pressure. Only breaks a guard if its remaining resource is actually exhausted; no unconditional shield deletion. |
| 99 | Bellfall | Strength 60, Stamina 45 | 32 / 30 | 1s wind-up; compact ground impact, 1.5D each to up to three targets and 0.5s stagger on unguarded hits. Marked impact area can be escaped; no long stun or repeated aftershock. |

Training: Blunt, Attack and Strength; surviving meaningful pressure trains
Stamina. Guard-resource pressure can contribute effective weapon training once
against the finite encounter threat budget, even when no HP is lost; do not
also credit that pressure as full HP damage. A Troll's faster Defense training
still requires actual blocks, parries or protection, not merely holding a mace.

## Shared control and combat safeguards

- All new hard control (stagger, fear, root, forced displacement) shares a
  target-level diminishing-return window in PvP: first duration/distance 100%,
  second 50%, further applications 0% within 6s of the first application.
  Count successful applications from all attackers, including lineage skills
  and Class Talents. Damage still applies; blocked/immune applications do not
  consume the window. The window does not refresh on subsequent attempts.
  Existing control sources must join this rule before these kits enter PvP.
- Weapon staggers in these tables last at most 0.5s before diminishing returns.
  Guard break counts as hard control too, not a separate route to stun-locking.
  Willpower's mental-control reduction does not reduce physical weapon stagger.
- Movement slows use the strongest current effect, never add together. Weapon
  slows here are 25% for 2s; all sources together initially cap movement slow
  at 40%. Repeated applications cannot keep weapon slows active beyond 4s
  continuously, followed by 2s immunity to weapon slows. Broader lineage/Class
  control tuning must preserve escape opportunities rather than bypass this.
- Blocking prevents secondary hostile control unless the action explicitly
  says otherwise. Nothing here says otherwise. Cleanse affects only effects
  authored as removable; no dispelling an entire lineage's passive identity.
- Bosses use explicit immunity and stagger-meter rules. Immune targets still
  take eligible damage; do not silently convert every resisted control into
  bonus damage. Small enemy displacement cannot throw bosses through geometry.
- Heal/ward targeting requires a living friendly target and line of sight at
  cast completion, and continuously for channels. No friendly fire, healing
  enemies or resurrection. Guard, armor and ward mitigation order must be
  shared by all families; Bodkin modifies armor only.
- Wards of the same named skill do not stack across casters: retain the larger
  remaining shield, with its original expiration if the new shield is rejected.
  Different ward sources need a shared absorption cap before party rollout.
  Neither overhealing nor replacing an unused ward earns proficiency XP.
- Basic attacks remain usable at zero mana. Four chosen active slots are shared
  by weapon and lineage skills, alongside a dedicated basic attack as proposed
  in DESIGN-0018. More unlocks create loadout choices, not mandatory extra keys.

## Class Talents and lineage skills are not duplicate unlocks

Existing Class permissions remain authoritative. These weapon skills give the
base equipment its techniques; Class Talents remain additional specialization.
No existing Class Talent is deleted or renamed by this proposal.

| Existing feature | Boundary for this catalog |
| --- | --- |
| Ranger Piercing Shot | Bodkin Bolt ignores a fraction of armor, not extra targets. Piercing Shot can add its one extra target; combined damage stays within the same projectile and XP rules. |
| Ranger Quick Vault | Combat Reload is a paid, visible reload, not a vault. Quick Vault may ready one bolt through its talent condition, never duplicate a loaded bolt or add a third Measured Pair shot. |
| Ranger Snareline / Smokeleaf Roll | Bow and Crossbow gain no trap deployment, root trap or concealment cloud here. |
| Duelist Quickstep / Passing Cut | Dagger grants no new invulnerable dodge or attack-through-target movement. Patient Answer consumes a real evade opportunity without granting one. |
| Duelist Bleeding Nick / Final Feint | Dagger has no baseline bleed or recovery-cancel privilege. Held Point changes release timing before commitment, not after the strike. |
| Ravager Splinter Armor / Faultline / Aftershock | Axe and Blunt gain no stacking armor shred, ground eruption or free repeat impact. Polearm arcs are actual weapon contact. |
| Vanguard Interpose / Perfect Retort | Roommaker pushes enemies away; it does not redirect ally damage or reset counter cooldowns. |
| Warden Mending Ray / Life Siphon / Second Sunrise | Wand provides modest school-neutral support. Steady Thread has no harmful beam mode; Returning Light is a single fixed self-heal, not weakest-ally vitality transfer; no resurrection. |

Class and lineage modifiers share each skill's hit, control and resource
limits. Resolve duplicate triggers by a stable action ID, not visual hit count.
For example, Troll Boulder Fist's Blunt enhancement can increase guard pressure
but cannot bypass the guard resource or the shared control window. Goblin
Smoke Hop can create Patient Answer's opportunity only if it genuinely evades
an attack; merely pressing Smoke Hop is not enough. Aeralith and Tidekin Wand
enhancements do not turn every Wand spell into their innate ability.

The four innate skills per lineage and favored-weapon enhancements are fully
specified in [DESIGN-0020](0020-lineage-skill-catalog.md), extending DESIGN-0018.
No lineage bonus is required to unlock any row
here, and off-affinity builds retain all permitted weapon skills.

## Presentation: use the existing illustrated skills board

The complete seven-tier visual treatment for every family and shared map
reactions are in [DESIGN-0021](0021-skill-visual-direction.md).

- Add a Weapon Proficiency view inside the same Chronicle menu, not a new HUD
  button. Use the current parchment, round illustrated icons, borders and
  typography. Keep the selected weapon and its proficiency visible in the header.
- Show seven milestone nodes connected along a clear learning path. Links show
  progression order, not a requirement to buy previous nodes. A locked node
  states every unmet level; an unlocked but unequipped node says which family
  or Grip is required. Never rely on color alone to distinguish these states.
- Selecting a node shows effect, mana, cooldown, required levels, equipped-hand
  condition and eligible lineage enhancement. Show a builder-gesture preview
  for the actual lineage, facing and equipment; do not substitute a human rig.
- Bow uses an actual draw/release; Crossbow is horizontally shouldered with a
  visible reload; Spear thrusts; Polearm sweeps; Blunt sells weight. Centaur
  movement preserves the unified horse-body rig. No forbidden clothing appears
  in previews, including Troll scarves or Centaur pants/boots.
- Hotbar remains under HP/mana with bound keys and readable cooldown/mana
  states. Selecting skills happens in the menu; no tutorial hints or duplicate
  action buttons reappear in the play screen.

## Validation and implementation readiness

The eight ladders are now authored. Damage coefficients, mana recovery,
animation timings, guard-pressure amounts and Class interactions still require
prototype tests; this document does not claim production-ready combat balance.
Implementation can remain local while server authority is postponed.

1. Verify all 56 entries and seven milestones per family; requirements never
   exceed Discipline 99 and basics require neither mana nor a locked action.
2. Test each at equivalent equipment tiers with neutral and favored lineages.
   Measure damage over a full mana/recovery cycle, not only one burst combo.
3. Compare Bow draw/mobility against Crossbow reload/cover; Sword against Axe
   commitment; Spear spacing against Polearm coverage; Blunt guard pressure
   against Dagger punish windows; Wand support against Staff area control.
4. Exercise block, dodge, interruption, empty mana, missed follow-up, weapon
   swap during flight, mixed Dual Wield, ward replacement, cleansing and boss
   immunity. No action duplicates resources, hits or XP after a swap.
5. Arena bots must telegraph, spend mana, reload and obey shared control rules.
   Test three attackers trying to chain control on one defender. PvP grants
   no progression XP under the current sandbox policy.
6. Validate all gate-training paths, especially Willpower before Unravel,
   Agility before evasive follow-ups, and Stamina without deliberate damage
   farming. Check a Wand healer's proficiency pace against a damage caster.
7. Capture every family in both facing directions using builder-authored
   lineage gestures before accepting its gameplay integration.
