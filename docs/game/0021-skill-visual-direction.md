---
id: DESIGN-0021
title: Skill Spectacle and Reactive Environments
status: proposed-art-direction
updated: 2026-09-10
---

# Powerful skills in a living, painted world

User direction: increasingly spectacular skills, taking inspiration from the
energy of MapleStory, with map reactions such as shaking and temporary darkness.
The interpretation here is large expressive silhouettes, layered animation,
strong anticipation and satisfying releases, translated into this game's
painted storybook style. These are original effects, not copies of another
game's characters, logos or exact skill assets. No runtime effects are added
by this design document.

Visual references: `light-lineages.png`, `dark-lineages.png`, and
`designs/npc-interaction-mockup.png` at the repository root. Preserve their
painted edges, warm materials, appealing proportions and legible equipment.
Do not replace them with realistic explosions or uniformly neon particle clouds.

Generated art-direction board:
[Lineage skill effect studies](../../designs/lineage-skill-effects-concept.png).
It establishes materials, silhouettes and atmosphere, not exact gameplay
geometry: Winter Halo must be centered on its caster in production, and
Cyclone's footprint must match its authored radius. Mirage silhouettes are
decorative, not summons. Siphon Dart's base remains a separate gadget even when
the concept character holds a Crossbow; equipped artwork does not grant weapon
delivery or proficiency credit. Normalize those attachments and footprints when
turning the sheet into animated assets.

## The visual grammar of power

Every action is a small sequence, not a single particle burst:

1. **Anticipation:** builder-authored gesture; energy gathers at the actual hand,
   weapon, mouth or feet. Show the threat shape before commitment.
2. **Release:** one strong painted shape carries the action: crescent, spear
   line, root curl, hammer fan, feather spiral or crystal star.
3. **Contact:** brief local flare, clear defender reaction and themed Field
   Notes damage number. Guard, miss and successful damage have different cues.
4. **Aftermath:** fragments, leaves, drifting embers or thawing frost settle;
   the environment responds and returns to its original state.

Effects follow actual release/impact events, not a guessed animation timer.
Wind-ups and damage timing remain those in DESIGN-0019/0020. A cinematic flare
does not postpone an attack or create extra damage ticks. Decorative trails
outside the collision area are translucent and never resemble active threats.

### Growth without visual inflation on every level

| Band | Weapon milestones | Lineage milestones | Visual vocabulary |
| --- | --- | --- | --- |
| Foundation | 1, 5 | Overall 1 | Distinct contact silhouette, small trail, readable single hit |
| Developed | 15, 30 | Overall 15 | Secondary motes, directional movement ribbon, clearer material identity |
| Signature | 50, 75 | Overall 35 | Layered release, localized ground response, pronounced impact flourish |
| Masterwork | 99 | Overall 60 | Authored visual sequence, brief background-light response and rich aftermath |

Bands describe an unlocked ability's presentation, not a hidden stat multiplier.
A level-99 basic is still a readable basic, not a permanent ultimate. A late
single-target strike becomes more elaborate, **not falsely wider**. Weapon
enhancements visibly add their material motif only when equipped and selected;
off-affinity/base versions retain their complete original effects.

## Complete weapon effect ladder

Entries in each row are ordered **1 → 5 → 15 → 30 → 50 → 75 → 99** and map
one-to-one to the skill names in DESIGN-0018/0019. These cover all seventy
candidate weapon entries, including basics, without adding new combat effects.

| Family / palette | Seven milestone treatments |
| --- | --- |
| Sword — ivory, tempered gold, blue shadow | **Basic Slash:** narrow ivory edge trail. **Quick Cut:** short bright comma and steel spark. **Heavy Cut:** weighted amber crescent that collapses onto contact. **Pommel Strike:** compact blunt star, not a blade explosion. **Sweeping Edge:** one broad gold-edged ribbon matching the attack arc. **Guarded Riposte:** shield contact ring resolves into a sharp returning line. **Blade Rhythm:** successive calligraphic arcs join briefly into a broken crown behind the final strike; no extra hit area. |
| Axe — copper, ember amber, dark iron | **Hew:** rough copper slash. **Committed Chop:** wedge of dust and a dense contact spark. **Raking Edge:** hooked rust-red stroke; bleed uses restrained amber-red flecks, no gore. **Pursuing Hew:** low boot-dust ribbon into the chop. **Broad Reap:** broad rough-edged copper fan. **Split Decision:** paired crossing fans with a readable pause. **Headsman's Measure:** hanging axe-shaped glint during wind-up, compressed background shade, one immense vertical painted wedge tapering to the real target; brief local ground jolt only on impact. |
| Spear — reed gold, pale jade | **Straight Thrust:** thin point glint. **Tip Strike:** small jade diamond at the outer reach. **Withdrawn Point:** retracting ribbon toward the hand. **Set the Point:** braced triangular line, compact spark only on interception. **Driving Lunge:** long tapered lance stroke with a narrow footprint. **Turning Shaft:** low circular reed sweep following the shaft. **Three-Point Measure:** three distinct thrust lines, each briefly leaving a translucent measuring mark; last connects them into a narrow spearhead constellation, not an AoE. |
| Polearm — bronze, olive, chalk | **Long Sweep:** muted bronze arc. **Narrow End:** short chalk-white tip streak. **Hook and Draw:** hooked ribbon curling toward the wielder, no rope through scenery. **Clearing Wheel:** broad low bronze ring with a visible interior. **Low Harvest:** grass-height olive scythe ribbon; slow marker at affected feet. **Overhead Reach:** tall descending hook with a narrow landing flash. **Reaper's Circuit:** two offset bronze arcs lift leaves and dust, with a large transparent wheel silhouette behind the wielder; active arcs remain distinct. |
| Bow — honey gold, leaf green | **Draw and Loose:** taut string highlight and fine arrow trail. **Snap Arrow:** quick green needle with a small bow recoil. **Retreating Loose:** backward dust comma, forward arrow streak. **Hampering Arrow:** leaf-shaped contact flare and foot-level slow mark. **Forked Volley:** three separated trails, never an opaque cone. **Lofted Shot:** rising arc and clear gold landing marker, then downward feather streaks. **Running Cadence:** three timed golden feather fans at the bow, flowing wind ribbons and leaf wake; no spectral arrows that appear to be additional damage projectiles. |
| Crossbow — brass, ochre, charcoal | **Shouldered Bolt:** string snap and short brass glint, not a firearm muzzle explosion. **Braced Bolt:** a compressed amber aim line, forceful stock recoil. **Combat Reload:** hands, latch and bolt visibly seat; one gear glint at completion. **Disrupting Bolt:** square impact shards rather than a round spell burst. **Bodkin Bolt:** narrow white-brass point and armor-chip contact sparks. **Measured Pair:** two distinct recoil flashes separated by the visible reload. **Siege Measure:** segmented brass aiming line, subtle gathered light, dense single bolt trail and angular contact fan; background briefly desaturates on release, never hides the aiming line. |
| Wand — pearl, soft turquoise, restrained violet | **Lumen Pin:** pearl needle with two fading star motes. **Stitchlight:** visible turquoise stitches draw inward on the healed target. **Needle Hex:** thin violet ring around target feet, one readable consumption snap. **Threadward:** transparent woven oval, cracks as absorption is spent. **Unravel:** removable-effect knot unthreads outward, no flare if validation fails. **Steady Thread:** fine luminous thread between caster and recipient, interrupted cleanly on break. **Returning Light:** bright pearl lance becomes a distinct returning turquoise mote on hit, blooming into a small petal halo at the caster; heal appears only when the mote arrives. |
| Staff — sapphire, amber, lavender | **Spark:** compact blue spark at the forward tip. **Firebolt:** tapered warm flame with a dark painted outline. **Frost Bind:** crystalline projectile and clearly bounded root lattice. **Arcane Ward:** translucent geometric shell showing remaining absorption through cracks. **Chain Spark:** bright primary bolt and individually legible secondary links. **Steady Channel:** tip-to-target ribbon with rhythmic runic motes, no screen strobe. **Spell Weave:** two selected spell motifs interlace around the staff before their authored release; a short violet background tint frames the actual cast, not an extra unearned explosion. |
| Dagger — silver, ink blue, restrained crimson | **Close Prick:** tiny silver nick. **Double Prick:** two close needle strokes with distinct contacts. **Retreating Nick:** thin silver hook and receding dust. **Held Point:** poised point glint, brighter only for a real recovery-window hit. **Tendon Touch:** low blue slash and legible foot slow marker. **Patient Answer:** brief silver outline on the weapon during its availability window, then a precise contact star. **Needle Sequence:** three ink-and-silver calligraphic marks collapse into one pinpoint final flash; large translucent brush shapes may frame it but never conceal the defender. |
| Blunt — slate, pale stone, amber fissures | **Weighted Blow:** compact dust fan and stone-colored contact star. **Knocking Blow:** denser wedge with a clear guard-pressure ring on blocks. **Checking Tap:** small square burst matching short stagger, not a giant slam. **Grounded Swing:** planted foot dust and slow weighted arc. **Roommaker:** outward dust crescent follows the actual push. **Bracebreaker:** visible overhead weight, broad angular contact ring that distinguishes a real guard break from surviving guard. **Bellfall:** a huge translucent bell-shaped pressure dome rises behind a compact marked impact, then shatters into painted dust; brief local scenery jolt, no damaging shockwave beyond the hit area. |

Returning Light's visual mote travel requires matching the authored heal event;
the weapon catalog's return effect should schedule healing on mote arrival, not
show recovery before it happens. Conversely, a purely decorative afterimage
cannot delay already-resolved damage. No VFX choice changes server-side rules.

## All 32 lineage presentations

Use palette **and shape** to distinguish lineages. Light/Dark allegiance does
not mean every Light effect must be gold or every Dark effect malicious black.
Darkening the background is theatrical contrast, not an allegiance mechanic.

| Lineage | Ability | Visual design and map response |
| --- | --- | --- |
| Tidekin | Tongue Snap | Elastic painted tongue with a wet crescent on contact; two droplets, no oversized beam. |
| Tidekin | Lily Leap | Lily-shaped launch splash and a soft water-ring landing; landing splashes never imply damage. Nearby grass bends then recovers. |
| Tidekin | Bog Spit | Suspended olive water pearl, bursting into sticky leaf-like droplets. Affected feet carry a small mire curl for the actual slow duration. |
| Tidekin | Springwater | Three translucent lily petals open beneath the caster; water spirals inward with the healing ticks. Nearby background foliage receives a soft teal light wash, then returns to normal. |
| Humans | Crosscut | Two restrained ivory/gold crossing trails attached to the actual hands or gear; no phantom sword when unarmed. |
| Humans | Resolute Rush | Forward amber shoulder wedge and boot-dust streak. A real equipped Shield stays visible, never conjured for other Classes. |
| Humans | Rally | Hand-painted gold pennant shapes rise behind the shoulders and weave into a transparent ward; pennants are symbolic, not a new physical banner entity. |
| Humans | Second Wind | A warm breath-like plume draws into the torso, then an expanding gold laurel silhouette frames the healing ticks. Brief warm background lift, no screen shake for healing. |
| Grove Centaurs | Gallop Strike | Hoof-timed leaf bursts and a broad trailing mane ribbon; a compact frontal impact, not a whole-lane damage beam. |
| Grove Centaurs | Rearing Stomp | Forequarters rear as one connected body; circular roots briefly lift in the marked impact, then settle. Nearby hanging vines sway once. |
| Grove Centaurs | Briar Bind | A twisting seed spear leaves a faint green helix; roots rise only on the successfully rooted target and break at root expiry. |
| Grove Centaurs | Grove Renewal | A luminous grove circle blooms into a translucent sapling silhouette behind recipients, with downward gold-green pollen. Background branches sway; no solid tree blocks play. |
| Aeralith | Gale Needle | Thin ivory feather spear with turquoise outer edge, leaving a curling air line. |
| Aeralith | Slipstream | A short feather-shaped wake and one fading silhouette at departure; actual character remains fully readable, never an invisible teleport. |
| Aeralith | Cyclone | Wide hollow wind spiral with painted feather blades, open center and readable ground footprint. Nearby leaves lift along the outward push; decoration does not hide opponents. |
| Aeralith | Zephyr Veil | Transparent overlapping feather shields orbit close to the silhouette. For the initial bloom only, background clouds gain a gentle moving highlight; no unlimited persistent weather effect. |
| Crag Trolls | Boulder Fist | Dust gathers on the actual fist, heavy amber contact crack and low stone chips. Nearby loose pebbles hop on confirmed impact. |
| Crag Trolls | Stonebreak | Forearms descend; a short zigzag seam and angular stone plates rise in the marked lane. Temporary crack decal and local debris jolt, never real platform destruction. |
| Crag Trolls | Stonehide | Slate plates visibly knit over the silhouette without replacing the rig; warm fissures show remaining ward, fragments shed as it absorbs damage. No scarf or hovering head. |
| Crag Trolls | Mountain Charge | Heavy dust front, hoof-free planted Troll steps, stone fragments orbiting only if Stonehide exists. On impact a large translucent crag silhouette and compact dust fan; nearby ruins shudder, background briefly darkens. A transferred ward visibly streams from Troll to ally. |
| Deep Goblins | Scrap Shot | Crooked brass bolt with one tumbling washer; wrist gadget or legally equipped horizontal Crossbow is the actual source. |
| Deep Goblins | Snare Canister | Spinning riveted can with readable landing ring; painted spring/cord motif tightens only on a successful root. No invisible leftover trap. |
| Deep Goblins | Smoke Hop | Low, translucent plum smoke and a fading bootprint. Puff sits behind combatants and telegraphs, never an opaque concealment wall. |
| Deep Goblins | Siphon Dart | Copper dart with a small green vial; on eligible damage, an emerald droplet trail visibly returns to the Goblin. Background gets a brief olive accent near the impact, not a full-screen toxic cloud. |
| Sunscour | Searing Thrust | Narrow amber heat lance, edged in deep terracotta; non-weapon base originates at the palm. |
| Sunscour | Dune Step | Low curling sand ribbon and a dissolving afterimage. Heat distortion affects background decoration only, not platforms or target silhouettes. |
| Sunscour | Sandglass | A glassy sand spindle with grains visibly falling inside; contact leaves a small hourglass slow marker at target feet. No suggestion of time-stop mechanics. |
| Sunscour | Mirage Guard | Transparent layered amber arcs resembling a desert arch shelter the actual body. A brief warm eclipse gradient passes over the distant sky; the hero and ground remain bright and readable. Works without the balaclava. |
| Rimeborn | Ice Shard | Faceted pale-cyan crystal with a dark blue rim and small aurora tail. |
| Rimeborn | Rime Prison | Distinct crystal lattice rises to knee height around a rooted target; head, hands and cast poses remain visible because root is not a stun. |
| Rimeborn | Aurora Mend | Green-violet ribbons fold inward around the shoulders and hands, with gentle pulse markers synchronized to healing. No white flash or shake. |
| Rimeborn | Winter Halo | Thin rune ring announces the footprint, then translucent crystal petals unfold around a hollow center. A pale aurora curtain appears behind the combat layer; cool background dimming and a light impact shiver, followed by falling crystal motes. |

## Signature beat sheets

Use these as the first animated production proofs. Times are relative to
activation, with aftermath tied to the actual hit/cast result when necessary.

### Troll — Mountain Charge

- **0–0.65s:** knees compress, shoulders draw back, small stones rattle; show
  the forward threat direction. No map dimming that hides the warning.
- **Release to collision:** strong planted charge, dust behind the feet, clear
  leading shoulder; no ghost impacts ahead of the character.
- **Confirmed impact:** large painted crag silhouette behind the strike,
  compact bright contact, local rubble shudder and at most the heavy shake
  preset. An empty charge has dust but no impact quake or hit sound.
- **Next 0.15–0.75s:** distant background dims smoothly then recovers; fragments
  fall. Ward transfer, if valid, draws a separate stone ribbon to the ally.

### Rimeborn — Winter Halo

- **0–0.65s:** ice motes orbit hands, a thin ring shows the true affected area.
- **Release:** crystal petals open outward, with transparent upper shapes
  rising behind characters; one contact flare per affected target.
- **Next 0–0.8s:** a background aurora blooms and fades, slight cool lighting
  shift. Ground frost is decorative after the burst; slow icons persist only
  for actual slow duration. This does not become a lasting damage field.

### Staff — Spell Weave

- Preserve the eventual authored cast wind-up; visuals cannot establish timing
  before this skill's two-effect combat contract is finalized.
- Selected spell motifs orbit the forward staff tip, then interlock into one
  sigil. Release them in their actual gameplay sequence, not a fake extra beam.
- Background briefly falls into violet shadow behind the sigil. Each real
  effect keeps its own collision footprint and counterplay cue. UI and enemy
  warnings are unaffected. No claim that every elemental combination already
  has implemented mechanics or art.

## Reactive map: presentation, not accidental destruction

| Response | Initial limit | Rule |
| --- | --- | --- |
| Local scenery shake | Decorative props only; 2–4 reference pixels for 0.15–0.3s | Shake pebbles, loose roots, banners and distant ruin trim near impact. Never shake walkable platform art away from its collision edge. |
| Camera translation | Light 1px / 0.08s; medium 2px / 0.12s; heavy 4px / 0.18s at 1080p reference | Distance-attenuated, no rotation, strongest event wins rather than summing. Camera returns to its underlying tracked position. Default intensity 50%; zero is valid. |
| Background darkening | At most 20% luminance reduction, total transition at most 0.8s | Background layers only; ease in/out. Never darken HUD, characters, hazards, aiming indicators or platform boundaries. No repeated black/white flashes. |
| Background color wash | Soft lineage hue, bounded to the cast region where possible | Restore the original map lighting, not a guessed default. Only one dominant environmental pulse at once. |
| Ground decals | Usually 1–2s; capped local count | Cracks, frost and dust fade. Unless the combat catalog specifies a field, decals deal no damage, alter no friction and grant no cover. |
| Foliage/debris | Local impulse and settle within 1s | Decoration only; no new physical projectiles, collision or networking obligations. |
| Impact emphasis | Local sprite recoil, contact flare, optional short attacker-pose accent | Never pause the world, defender input, cooldowns or network simulation. Any pose accent must fit existing recovery timing, not create extra lockout. |

Reference pixels scale with viewport presentation, not camera world zoom. These
are tuning ceilings, not a claim that they are comfortable for every player.
Repeated signature casts have a shared **3s environment-pulse cooldown** per
viewer: skill/impact effects still play, but global lighting does not oscillate
or stay dark indefinitely. A new pulse cannot extend an active pulse's timer.
Camera shakes use a separate maximum of two accepted bursts per second; later
events still have their contact reactions. Hit sounds are voice-limited too.

Changing scenery geometry, destroying platforms or causing genuine map-wide
darkness would be a separate authored encounter mechanic with explicit rules,
warnings and authority. Cosmetic skills do not silently introduce any of those.

## Readability, accessibility and presentation ownership

- Stack order: distant environment → environmental tint → behind-character
  flourishes → world terrain/characters → essential gameplay telegraphs →
  restrained contact effects → Field Notes damage numbers → unchanged HUD.
  Protect visible platform rims even when decorative ground decals are present.
- Dominant spell shapes use painted opaque edges with transparent interiors,
  not full opaque discs. Colors complement actual character art. Hostile and
  friendly versions also differ by outline/marker pattern, not only hue.
- Essential warning, projectile, hit footprint and status expiration effects
  cannot be culled as decoration. If visuals are simplified, preserve those.
- Settings: **Screen Shake 0–100%**, **Reduced Motion**, **Reduced Flashes**,
  **Environment Effects on/off**, and **Other Players' Effects low/full**.
  Reduced Motion disables shake, scene distortion and decorative camera motion;
  Reduced Flashes replaces bright pulses with steady outlined contact marks
  and removes lighting pulses. Either setting must remain fully playable.
- Default: small local impacts and 50% shake; no full-screen white flash, camera
  rotation, forced zoom or chromatic aberration. Preview accessibility settings
  with actual effects before saving them. Do not require a photosensitivity
  warning as a substitute for restrained effects and player control.
- Local character gets full detail, enemies retain full readable threat cues,
  allies get reduced decorative opacity in crowded combat. Arena bots obey
  exactly the same gameplay effects and warning timing as players.
- Environment/camera responses belong to a viewer-side presentation layer,
  triggered from resolved action events. They never change damage, XP, control
  duration or platform physics. Cancel, despawn, scene change and menu transition
  must clean up owned emitters/decals and release lighting contributions.
- Use shared budgets for particles, decals, temporary lights and sound voices;
  pool reusable effects. Establish hardware-specific budgets by profiling,
  not unmeasured fixed promises. Cull background flourishes first, never cues.
- Keep hand/weapon/foot sockets and forward direction from the builder. Mirror
  trajectories correctly; do not mirror glyph text. No floating heads, detached
  horse legs, backward Staff casts or sideways Crossbows in the spectacle pass.

## First deliverables and acceptance

1. A concept sheet establishing six signature effects against the existing
   painted lineage references: Troll Mountain Charge, Rimeborn Winter Halo,
   Aeralith Cyclone, Centaur Grove Renewal, Sunscour Mirage Guard and Goblin
   Siphon Dart. It is visual exploration, not a screenshot of implemented play.
2. Animated in-game proofs: one physical impact (Boulder Fist → Mountain
   Charge), one projectile (Ice Shard) and one signature (Winter Halo). Reuse
   these tested presentation patterns when expanding the remaining catalogs.
3. Capture normal/reduced effects, both facing directions, bright/dark maps,
   every lineage body, successful hits, misses, blocked hits and interruptions.
   Health bars, damage numbers, feet and enemy warning shapes must stay readable.
4. Stress simultaneous signature casts: capped shake/lighting, no stale tint
   after death or scene changes, stable frame times, no added damage ticks and
   no drift between moving platform art and collision.

The written visual catalog covers all ten weapon ladders and all eight lineage
kits. The concept sheet illustrates a selected direction; it is not a complete
sprite atlas, animation pack, effects implementation or measured performance test.
