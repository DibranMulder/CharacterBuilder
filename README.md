# Lineage Forge — modular Godot 2D character prototype

This folder now contains a runnable Godot 4 character-builder prototype for the eight silhouettes in the supplied concept art. The race names are working names and are intentionally separate from their stable IDs.

## Run it

```bash
godot --editor project.godot
```

Press **F6/F5**, select any of eight races, swap equipment independently, preview left/right idle and running, climb rear-facing on a ladder, and trigger jab, forehand, backhand, or one of three race-specific gestures.

## Production strategy

Do **not** author a complete sprite sheet for every race × armor × weapon × action combination. That grows multiplicatively and becomes impossible to maintain. Use a hybrid cutout rig:

1. One named rig contract per topology family (`biped`, `centaur`, and `winged` in this prototype).
2. Race-specific body pieces attached to stable pivots/bones.
3. Equipment attached to named sockets (`weapon`, `offhand`, `armor`, `pants`, `head`, `back`, `accessory`) with explicit draw layers.
4. Reusable locomotion and weapon-family animations, plus a small set of race-specific gesture animations.
5. Selective cel swaps only where deformation looks bad: hands, faces, cloth extremes, smear frames, and effects.

The runtime seam is intentionally small:

```gdscript
avatar.configure("goblin", saved_loadout)
avatar.equip(&"weapon", "bow")
avatar.set_facing(&"left")
avatar.play_motion(&"run")
avatar.play_weapon_attack(&"forehand")
avatar.play_gesture(0)
```

Gameplay and builder UI never manipulate bones or sprites directly. `ModularCharacter` owns topology, pivots, equipment draw order, and animation.

## Procedural art direction

The prototype translates the supplied illustration into reusable construction rules rather than copying a fixed pose. Authored raster sprites now provide the base heads, hands, biped feet, and centaur hooves through the deep `BaseAnatomyVisual` module. It owns atlas crops, front/rear view switching, fitting, and procedural fallback behind `setup(race_id, part_id, target_size)` and `set_back_view(enabled)`. Layered tunics, pants, headgear, shoulder pieces, belts, capes, shields, weapons, and accessories remain independent equipment visuals on stable sockets; no equipment combination is baked into a base sprite. Biped pants are a five-piece garment attached at the waist, both thighs, and both shins so they articulate through the knee. Centaurs do not support the pants slot, and the builder disables it for that topology.

## Asset contract

Authored replacements should be transparent PNGs (or `Polygon2D` meshes) with a consistent pixels-per-unit scale. Each item needs only the views required by the game camera and attaches at its slot origin. Keep pivots and naming stable:

| Slot/body part | Origin | Typical draw layer |
|---|---|---:|
| back | upper torso | -6 |
| rear arm/leg | shoulder/hip | -3 to -2 |
| torso/body | hip chain | 0 |
| armor | torso | 1 |
| pants | biped hip + paired thigh/shin sockets | 2–5 |
| head | neck | 4 |
| main/off hand | wrist | 5 to 6 |
| head/accessory | head | 2 to 3 |

The shield is a deliberate exception to the general offhand layer: the far-side arm crosses behind the torso so the shield appears on the same screen-right side as the weapon, with its inside face and straps toward the viewer. Lanterns and spellbooks remain on the normal foreground hand layer.

The Frost Troll presents the Axe as a lineage-specific two-handed great axe. Equipping it clears and disables the offhand slot, swaps in the long double-headed rendering, and uses two-bone IK to keep the second gripping hand on the shaft during idle, running, and attacks. Climbing moves the axe to the back and releases both arms for the ladder. Other lineages retain the regular one-handed Axe presentation, so equipment remains swappable rather than being baked into troll anatomy.

For production, put definitions in custom `.tres` resources rather than hard-coded dictionaries. Godot Resources are Inspector-editable, typed, version-control-friendly data containers. Atlas related textures, but keep logical items independent so downloads and cosmetics can be managed without rebuilding every character.

## Animation plan

- Shared locomotion currently includes mirrored left/right idle and running with animated thigh/knee/shin chains, topology-specific four-legged centaur knees, and a rear-facing ladder climb with alternating reaches and foot placement. Facing changes mirror the complete rig while keeping the weapon on its fixed anatomical right-arm socket; the left-facing shield shows its exterior. During climbing, equipped weapons and shields move to back mounts; shields show their exterior face. They return to their hand sockets when climbing ends. Future states: jump start, rise, apex, fall, land, rope variants, hit, and defeat.
- Weapon attacks use a two-joint shoulder/elbow/hand chain. At rest, the elbow has an approximately 120° interior bend and the weapon rests diagonally down along the screen-right side of the body. Jab retracts almost to the shoulder while staying horizontal, then stabs forward along the same line. Forehand keeps that strong elbow bend folded toward the weapon side, carries the blade up and back beyond the screen-left edge of the face, raises it overhead, then smashes diagonally down toward a screen-right enemy. Backhand remains provisional. Every attack recovers to the same guard, and the equipped weapon follows the hand socket.
- Race gestures: three are represented per race in the prototype. Production clips should animate the race rig; weapon visuals follow the hand socket automatically.
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
