# Rimeborn reference-art surfaces

The rightmost character in `dark-lineages.png` guides the gray-blue anatomy,
large icy eyes, shaggy white hair, navy coat, ivory fur trim and bedroll pack.
The coordinated paintings are `frostling_reference_base_v4.png` and
`frostling_reference_clothes_v4.png`. Original assets are preserved.

`FrostlingPaintedAtlas` owns crops. `FrostlingAppearance` fits the body and
front/rear coat to the shared torso mesh, with the coat hem following the hip.
Whole arms, sleeves and trouser legs bend across the existing two-bone surfaces;
the old separate upper/lower segment sprites stay hidden. Boots and backpack
use artwork overrides on their original gear nodes, preserving animation.

The Hood remains a removable Head-slot item. The base painting contains the
complete white-haired head. Equipping the hood selects a coordinated covered
head presentation and hides the bare head; removing or replacing it restores
the bare head. Climbing selects the hood's rear painting. Staff artwork and
motion ownership are unchanged. The pose is not a tracing of the concept art.

## Verification

`tests/frostling_surface_regression.gd` checks all menu motions in both facings,
continuous wrist/ankle endpoints, front/rear surfaces, clothing and pack swaps,
headgear removal during climbing, gestures and weapon-triggered rebuilds.
The broader suite checks existing lineages and equipment contracts.

The reference comparison includes hooded, uncovered and rear views. Cycle
previews sample movement and spellcasting; they do not exhaust every possible
frame and loadout combination.

```sh
godot --headless --path . --script tests/frostling_surface_regression.gd
godot --path . --script tools/render_frostling_reference.gd
godot --path . --script tools/render_human_cycle.gd -- --frostling --motion=run
```
