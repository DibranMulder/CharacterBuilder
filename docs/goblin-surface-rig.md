# Deep Goblin reference-art surfaces

The second character in `designs/references/dark-lineages.png` guides the goblin's large sideways
ears, amber eyes, olive-green skin, compact body, purple neck scarf, worn
leather outfit, brass forehead goggles and small backpack. New anatomy and
clothing paintings are stored in `goblin_reference_base_v2.png` and
`goblin_reference_clothes_v2.png`; original source assets are preserved.

`GoblinPaintedAtlas` owns the crops. `GoblinAppearance` fits front/rear body
and vest paintings to the shared torso mesh, with the garment hem following
the hip. Whole-arm and whole-leg textures use the same continuous two-bone
surfaces as the Human and Aeralith. No separate upper/lower limb sprites remain
visible. The head's short neck overlaps the scarf and upper chest.

Boots, goggles and backpack use optional texture/rectangle overrides on their
existing gear nodes. This preserves animation, facing, socket ownership and
equipment swapping. Rear goggles use the existing strap view. Other clothing
retains the shared continuous fallback. The crossbow artwork and shooting
system are unchanged; the neutral pose is not a tracing of the reference.

## Verification

`tests/goblin_surface_regression.gd` checks continuous wrist/ankle endpoints
through every menu motion in both facings, rear texture selection, clothing
and accessory swaps, gestures, and weapon-triggered rebuilds. The shared
regression suite checks other lineages, weapon sockets and crossbow behavior.

Visual samples cover the reference beside live side/rear views, running,
mirrored jumping, and crossbow firing. These are sampled checks rather than
exhaustive coverage of every frame and equipment combination.

```sh
godot --headless --path . --script tests/goblin_surface_regression.gd
godot --path . --script tools/render_goblin_reference.gd
godot --path . --script tools/render_human_cycle.gd -- --goblin --motion=run
```
