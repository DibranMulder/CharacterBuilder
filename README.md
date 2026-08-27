# Lineage Forge — modular Godot 2D character prototype

This folder now contains a runnable Godot 4 character-builder prototype for the eight silhouettes in the supplied concept art. The race names are working names and are intentionally separate from their stable IDs.

## Run it

```bash
godot --editor project.godot
```

Press **F6/F5**, select any of eight races, swap equipment independently, and trigger jab, forehand, backhand, or one of three race-specific gestures.

## Production strategy

Do **not** author a complete sprite sheet for every race × armor × weapon × action combination. That grows multiplicatively and becomes impossible to maintain. Use a hybrid cutout rig:

1. One named rig contract per topology family (`biped`, `centaur`, and `winged` in this prototype).
2. Race-specific body pieces attached to stable pivots/bones.
3. Equipment attached to named sockets (`weapon`, `offhand`, `armor`, `head`, `back`, `accessory`) with explicit draw layers.
4. Reusable locomotion and weapon-family animations, plus a small set of race-specific gesture animations.
5. Selective cel swaps only where deformation looks bad: hands, faces, cloth extremes, smear frames, and effects.

The runtime seam is intentionally small:

```gdscript
avatar.configure("goblin", saved_loadout)
avatar.equip(&"weapon", "bow")
avatar.play_weapon_attack(&"forehand")
avatar.play_gesture(0)
```

Gameplay and builder UI never manipulate bones or sprites directly. `ModularCharacter` owns topology, pivots, equipment draw order, and animation.

## Asset contract

Authored replacements should be transparent PNGs (or `Polygon2D` meshes) with a consistent pixels-per-unit scale. Each item needs only the views required by the game camera and attaches at its slot origin. Keep pivots and naming stable:

| Slot/body part | Origin | Typical draw layer |
|---|---|---:|
| back | upper torso | -6 |
| rear arm/leg | shoulder/hip | -3 to -2 |
| torso/body | hip chain | 0 |
| armor | torso | 1 |
| head | neck | 4 |
| main/off hand | wrist | 5 to 6 |
| head/accessory | head | 2 to 3 |

For production, put definitions in custom `.tres` resources rather than hard-coded dictionaries. Godot Resources are Inspector-editable, typed, version-control-friendly data containers. Atlas related textures, but keep logical items independent so downloads and cosmetics can be managed without rebuilding every character.

## Animation plan

- Shared locomotion: idle, walk/run, jump start, rise, apex, fall, land, ladder/rope, hit, defeat.
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
