# Lineage Forge — modular Godot 2D character prototype

This folder now contains a runnable Godot 4 character-builder prototype for the eight silhouettes in the supplied concept art. The race names are working names and are intentionally separate from their stable IDs.

## Run it

```bash
godot --editor project.godot
```

Press **F6/F5**, select any of eight races, swap equipment independently, compare a static Stand pose with lineage-specific animated Idle, preview left/right running, ascend a side-facing stone staircase, climb rear-facing on a ladder, and trigger jab, forehand, backhand, or one of three race-specific gestures.

## Production strategy

Do **not** author a complete sprite sheet for every race × armor × weapon × action combination. That grows multiplicatively and becomes impossible to maintain. Use a hybrid cutout rig:

1. One named rig contract per topology family (`biped`, `centaur`, and `winged` in this prototype).
2. Race-specific body pieces attached to stable pivots/bones.
3. Equipment attached to named sockets (`weapon`, `offhand`, `armor`, `pants`, `boots`, `head`, `back`, `accessory`) with explicit draw layers.
4. Reusable locomotion and weapon-family animations, plus a small set of race-specific gesture animations.
5. Selective cel swaps only where deformation looks bad: hands, faces, cloth extremes, smear frames, and effects.

The runtime seam is intentionally small:

```gdscript
avatar.configure("goblin", saved_loadout)
avatar.equip(&"weapon", "crossbow")
avatar.set_facing(&"left")
avatar.play_motion(&"run")
avatar.play_motion(&"stairs")
avatar.play_weapon_attack(&"fire_crossbow")
avatar.play_gesture(0)
```

The authored cloth family—armor, articulated pants, hoods, capes, and scarves—uses a shared cool-blue source palette that is dyed at runtime with each lineage's accent color. This preserves the same painted seams, folds, outlines, and highlights across the modular set while matching the color identities in the two reference sheets. The golden Fae tunic/capelet, leather, Duneborn lamellar, plate, wood, metal, and glass retain their authored material colors.

Capes and scarves retain their modular torso/head sockets but now receive separate secondary motion. Idle breathing produces a subtle drift, run cycles stream both layers behind the wearer, stairs and ladders use restrained follow-through, and melee, ranged, spell, and lineage impacts pull the fabric through contact before a smooth recovery to the authored hang. Packs, quivers, metal, and other rigid items remain stable.

Gameplay and builder UI never manipulate bones or sprites directly. `ModularCharacter` owns topology, pivots, equipment draw order, and animation.

## Procedural art direction

The prototype translates the supplied illustration into reusable construction rules rather than copying a fixed pose. Authored raster sprites now provide the base heads, hands, biped feet, and centaur hooves through the deep `BaseAnatomyVisual` module. The Bogkin swaps the shared humanoid extremities for dedicated true-alpha four-finger webbed palms, front/rear grips, and broad webbed feet, while keeping the same wrist and ankle socket contract. `BaseAnatomyVisual` owns atlas crops, front/rear view switching, fitting, antialiased chroma coverage and color-despill cleanup, and procedural fallback behind `setup(race_id, part_id, target_size)` and `set_back_view(enabled)`. Shared neutral torso and limb paintings use a nonlinear 0.42–1.12 skin-tone transfer: lineage color changes without flattening the authored joint shadows, shoulder form, or warm-brown contour. The same despill contract cleans keyed plate, pants, and goggles so generated magenta fields cannot leave neon edge bands. Layered tunics, pants, headgear, shoulder pieces, belts, capes, shields, weapons, and accessories remain independent equipment visuals on stable sockets; no equipment combination is baked into a base sprite. Biped pants are a five-piece garment attached at the waist, both thighs, and both shins so they articulate through the knee. Footwear is independently attached at both ankle sockets and replaces only the visible bare-foot layer. Centaurs do not support pants or boots, and the builder disables both slots for that topology so its four authored hooves remain intact.

Painted limb segments overlap past their logical pivots while preserving the
same wrist and ankle endpoints, hiding paired round caps during bends. The
Frost Troll receives a deeper overlap plus adapter-owned proximal socket crops
and a rounded alpha edge, making its broad authored arms and legs flow into the
jerkin, trousers, hands, and feet instead of reading as disconnected beads.

Shield equipment now includes three independently swappable painted faces on one boss/grip socket: the general oak-and-brass adventurer shield, Bogkin's reed-lashed marsh buckler, and Duneborn's engraved bronze desert shield. Reference loadouts select the matching construction while every lineage can equip any variant, and climbing carries the selected face onto the back through the same presentation contract.

Handheld utilities follow the same ladder-safety contract: lanterns hang upright
from their top loops during ordinary motion, while lanterns and spellbooks stow
on the torso for rear climbing and restore to the offhand afterward. Quivers are
biased outside the torso silhouette so their arrows remain readable under the
bow without losing their mirrored back socket.

Selecting a lineage in the builder now applies its complete reference-painting
kit from `CharacterCatalog.REFERENCE_LOADOUTS`. The preset always defines all
eight slots to prevent gear leaking between races, then leaves every supported
selector free for further character building.

## Asset contract

Authored replacements should be transparent PNGs (or `Polygon2D` meshes) with a consistent pixels-per-unit scale. Each item needs only the views required by the game camera and attaches at its slot origin. Keep pivots and naming stable:

| Slot/body part | Origin | Typical draw layer |
|---|---|---:|
| back | upper torso | -6 |
| rear arm/leg | shoulder/hip | -3 to -2 |
| torso/body | hip chain | 0 |
| armor | torso | 1 |
| pants | biped hip + paired thigh/shin sockets | 2–5 |
| boots | paired biped ankle sockets | 5 |
| head | neck | 4 |
| main/off hand | wrist | 5 to 6 |
| head/accessory | head | 2 to 3 |

The shield is a deliberate exception to the general offhand layer: the far-side arm crosses behind the torso so the shield appears on the same screen-right side as the weapon. Its decorated exterior remains toward the viewer in both mirrored directions, matching the supplied concept sheets; the authored strapped interior is retained for a future explicit flip pose. Lanterns and spellbooks remain on the normal foreground hand layer.

The Frost Troll presents the Axe as a lineage-specific two-handed great axe. Equipping it clears and disables the offhand slot, swaps in the long double-headed rendering, and uses two-bone IK to keep the second gripping hand on the shaft during idle, running, and attacks. Climbing moves the axe to the back and releases both arms for the ladder. Other lineages retain the regular one-handed Axe presentation, so equipment remains swappable rather than being baked into troll anatomy.

Staff users can independently equip either the blue-crystal staff reflected by
the Frostling reference or the Fae's leaf-bearing forked branch staff. Both are
full modular weapon items and share the same grounded casting, spell-origin,
upright locomotion, and back-mounted climbing contracts.

The Goblin reference's compact crossbow is also a fully modular two-handed
weapon. It clears and disables the offhand slot, keeps its forward support hand
attached through rest and locomotion, exposes a dedicated grounded Fire
Crossbow action with a visibly loaded rail and release-timed bolt, stays horizontal during running and
stairs, and moves to the back so ladder climbing retains two free hands. Its
short bodkin bolt is a dedicated authored projectile shared with Goblin's Snap
Shot gesture, rather than a scaled copy of the longbow arrow.

Back equipment now includes both a compact cape and the Human reference's broad
knee-length travel cape. Its widened second-generation silhouette follows the
reference's screen-left wind sweep while retaining independent runtime dyeing
and all idle, run, stair, ladder, melee, ranged, and gesture follow-through
instead of being baked into the Human body.

Armor now includes a reference-specific but freely swappable Duneborn lamellar
cuirass alongside cloth, leather, and plate. Its bronze scale rows, burgundy
shoulder mantle, belt, and split skirt remain one true-alpha torso item while
the neck and both arm openings preserve independently animated anatomy.

The Fae reference's golden wrap tunic, compact red shoulder capelet, blue sash,
and leaf clasp are likewise a freely swappable armor item rather than baked
anatomy. Paired front/rear true-alpha sprites keep the animated arms clear and
remove front-only fasteners during rear-facing ladder motion.

The Frostling's midnight-indigo quilted travel coat is also a freely swappable
fixed-color armor item. Thick pale fur frames the open neck, both animated arm
sockets, and split hem; its paired rear sprite removes the front clasp and
buckle during rear-facing ladder motion.

The Frost Troll now has a dedicated broad charcoal hide jerkin instead of the
shared polished leather cuirass. Its raw tan lacing, dull iron hardware, and
ragged rust skirt match the dark-lineage painting, while paired true-alpha
front/rear sprites preserve the troll's animated blue shoulders and arms.

The Centaur's freely swappable woodland harness replaces generic leather in
its reference loadout. Antique-bronze pauldrons, diagonal front tack, crossed
rear straps, and a layered green leaf skirt frame transparent torso and arm
sockets while remaining compatible with bow attacks and quadruped locomotion.

The Duneborn reference kit pairs its bronze lamellar, burgundy cloth trousers,
round shield, spear, and short cape with practical brown leather travel boots,
matching the dark-lineage painting. Bright plate greaves remain a swappable
builder option instead of overriding the painted reference silhouette.

The Human reference loadout now uses articulated `ranger` pants: the shared
painted cloth waist, thigh, and shin pieces receive a fixed olive-green dye
matching the forest painting while preserving independent knee motion through
running, stairs, climbing, and all three melee curves.

Bogkin now wears a freely swappable ivory `marsh_tunic` in its reference
loadout instead of the shared structured blue cuirass. The loose homespun
front/rear sprites keep its broad frog arm sockets open, while the orange scarf,
shield, weapon, articulated pants, and webbed extremities remain independent.
Its lineage profile follows the concept's squat frogfolk construction rather
than a uniformly shrunken human: its global height is about four-fifths of the
Human rig scale and its already shorter local anatomy brings the finished
silhouette close to the compact frog-to-Human relationship in the light-lineage
painting. A wider, shorter torso, compact thick spring legs, a dominant head,
and enlarged authored palms and feet preserve the spring-loaded shape. The reference
loadout deliberately leaves footwear empty so those webbed feet remain visible;
wraps and the other boot items are still available as optional equipment.

Fae now keeps the painting's approximately Human-height, vertically poised
silhouette instead of reading as a miniature fairy. Its narrow torso and limbs
remain slender, while the taller global scale gives the branch staff, baggy
trousers, wrapped feet, ponytail, and four translucent wing lobes enough room to
read as one coherent martial-air design at gameplay scale.

The Human reference kit reuses that modular ivory garment as the painting's
cream frontier tunic, pairing it with the articulated olive `ranger` trousers,
long blue cape, and blue scarf collar. Those layers remain independently
swappable and retain their cape/scarf secondary motion through every action.

Its charcoal balloon trousers are a separate `baggy` pants item built from the
same authored cloth texture family: wider thigh sleeves taper into narrow
wrapped calves while the five-piece waist/thigh/shin rig preserves independent
knee motion through running, stairs, attacks, gestures, and climbing.

For production, put definitions in custom `.tres` resources rather than hard-coded dictionaries. Godot Resources are Inspector-editable, typed, version-control-friendly data containers. Atlas related textures, but keep logical items independent so downloads and cosmetics can be managed without rebuilding every character.

## Animation plan

- Shared locomotion currently includes a distinct static Stand pose, lineage-specific breathing Idle with arm/leg secondary motion, Fae wing flutter, Centaur tail sway, mirrored left/right running with animated thigh/knee/shin chains, topology-specific stair cycles on a rising stone staircase, and a separate rear-facing ladder climb with alternating reaches and foot placement. The Centaur run is a full eight-phase diagonal-pair gallop—contact, compression, tucked passing, and forward reach mirrored across both halves—with coordinated four-knee articulation, body rise, arm carry, and tail counter-sway instead of a two-pose rocking loop. Fae wings use broad run downstrokes/upstrokes, restrained stair balance, paired ladder folding, and gesture-specific impact angles before returning exactly to rest. Stair ascent keeps weapons in hand and side views active; swords and one-handed axes use a low forward carry, while upright spears/staves and the Frost Troll's two-handed axe use a restrained outboard carry channel so no wielded silhouette sweeps across the face during running or stairs. Ladder climbing moves equipped weapons and shields to back mounts and switches shields to their exterior face. Facing changes mirror the complete rig while keeping the weapon on its fixed anatomical right-arm socket. Future states: jump start, rise, apex, fall, land, rope variants, hit, and defeat.
- The Fae's wing bones now render authored true-alpha ivory membranes with painted gold veins and subtle sage/cyan cell variation instead of flat procedural lobes. The accepted right wing and its exact mirrored left derivative retain the same waist roots and all existing independent wing motion.
- Weapon attacks use a two-joint shoulder/elbow/hand chain. At rest, the elbow has an approximately 120° interior bend and the weapon rests diagonally down along the screen-right side of the body. Jab retracts almost to the shoulder while staying horizontal, stabs forward along the same line, then carries beyond contact while decelerating before withdrawal reverses. Duneborn's spear retains that horizontal path through its carry and rotates upright only after the thrust trail ends. Forehand keeps that strong elbow bend folded toward the weapon side, carries the blade up and back beyond the screen-left edge of the face, raises it overhead, then smashes diagonally down toward a screen-right enemy. Backhand circles across the far shoulder, drops into a low loaded guard beside the far hip, then accelerates through a rising screen-right contact and high follow-through. Matched quadratic acceleration/deceleration now carries sword Jabs, Duneborn spear Jabs, one-handed sword cuts, and the Frost Troll's two-handed great axe continuously across contact; a 240 Hz weapon-tip regression bounds speed ratio and direction change at each strike/follow join. The great-axe follow-through additionally keeps its second shaft socket inside the support arm's IK envelope. Every attack phase includes planted lower-body weight transfer rather than translating a neutral stance: bipeds open and reverse the four-bone leg chain, while Centaurs brace all four articulated legs and counterbalance with the tail. Slash trails begin only as thrust or cutting contact starts and expire before recovery. Every attack recovers to the same guard, and the equipped weapon follows the hand socket.
- Bow, crossbow, and staff actions use the same grounded topology contract. Archers open into a wide planted stance, lean against the draw, track the same painted arrow from nock through constant-speed flight, open the drawing hand immediately after recoil, and then recover. Crossbow users settle into a two-handed sight picture, release a constant-speed bolt from the rail, and absorb a compact shoulder recoil. Staff users gather from a rear-weighted brace, hold the exact crystal socket through emission, then carry the staff arm, framing hand, torso, and planted stance past release before continuously recovering. Released arrows, bolts, and spells detach from the animated rig into avatar-local world space, so subsequent recoil and footwork cannot drag them off their flight path. Centaurs perform ranged and spell actions through four-leg bracing and tail counterbalance.
- Race gestures: every lineage has three independently staged full-body actions with a unique semantic impact effect, for 24 distinct pose/effect combinations. Crouches, lunges, braces, dashes, leaps, hovering casts, heavy smashes, Centaur gallops, and a true four-leg rear are scaled to each named action before recovering to the authored rest pose. Tongues, arrows, shield chevrons, leaves, wind, stars, ice, rocks, snow, sand, crescents, powder blasts, and aurora pulses spawn only after the final contact pose reaches its named mouth/hand/weapon/torso/front/ground anchor, so anticipation cannot leave effects behind and projectile gestures release from their completed aim. Weapon, hand, front, and ground effects then detach into avatar-local world space, preventing recovery motion from dragging released arrows, bolts, trails, or impacts; head and torso auras remain body-bound. Effects cleanly disappear when locomotion or another action interrupts them, while weapon visuals continue to follow their hand sockets automatically.
- Put gameplay timing in animation events or action data: startup, active, recovery, hitbox, movement impulse, cancel window. Never infer hit timing from a rendered frame.
- Use `AnimationPlayer` for authored transforms/events and `AnimationTree` for state transitions, one-shots, and filtered upper-body overlays. Use discrete/carry blending for cel-swapped tracks.

## Research basis

- [Godot: Cutout animation](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html) documents hierarchical parts, pivots, mixed cel/cutout animation, particles, colliders, depth ordering, and `AnimationTree` integration.
- [Godot: 2D skeletons](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html) documents `Skeleton2D`, `Bone2D`, `Polygon2D` meshes, weights, and the engine's built-in skeletal deformation path.
- [Godot: Using AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html) documents state machines, one-shots, filtered track blending, and discrete/carry modes for frame-by-frame 2D animation.
- [Godot: Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) supports the data-driven `.tres` catalog recommended above.
- [Godot: CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) defines `z_index` and visibility behavior used for deterministic equipment layering.
- [Spine runtime skins](https://esotericsoftware.com/spine-runtime-skins) and [spine-godot](https://esotericsoftware.com/spine-godot) validate the same skin/slot/attachment model if the project later chooses an external authoring tool. Spine is optional; the current prototype uses only built-in Godot features.

## Next art milestone

Before producing hundreds of items, finish one vertical slice: Human + one armor set + sword/shield + locomotion + one attack. Validate pivots, silhouette, hand swapping, draw-order changes during attacks, and hit timing. Then lock the asset contract and roll it across the other seven races.
