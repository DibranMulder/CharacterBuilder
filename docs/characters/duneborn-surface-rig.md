# Sunscour reference-art surfaces

The third character in `dark-lineages.png` guides the bronze lamellar shoulder
mantle, rust-red split robe, brown straps and boots, cape, and burgundy wrapped
headgear. The new anatomy and outfit paintings are
`duneborn_reference_base_v4.png` and `duneborn_reference_clothes_v4.png`.
Original source assets are preserved.

`DunebornPaintedAtlas` owns source crops; `DunebornAppearance` fits the artwork
to the existing animation rig. Body and front/rear robe use the shared torso
surface, whose lower rows follow the hip. Whole-arm and whole-leg paintings
use continuous two-bone surfaces instead of separate upper/lower sprites.
Boots and cape use overrides on their original animated gear nodes. Other
equipment retains the existing fallback, and spear/shield artwork is unchanged.

## Removable balaclava

The reference preset selects `balaclava` in the Head slot. The base atlas
contains a complete uncovered face, hair and rear head: the mask is not baked
into that anatomy. For consistent painted edges, the headgear uses a complete
covered-head presentation, hiding the bare head only while equipped. Removing
or replacing it restores the bare head immediately. Climbing selects the
wrapped rear view; changes and weapon-triggered rebuilds preserve the selection.
Other lineages can use a generic cloth fallback for the same head-slot item.

## Verification

`tests/duneborn_surface_regression.gd` checks continuous limb endpoints through
all menu motions and both facings, front/rear surfaces, clothing swaps, all
headgear choices, removal during climbing, gestures and weapon rebuilds.
Shared tests cover equipment sockets and spear motion continuity.

The comparison preview shows the reference, equipped balaclava, uncovered head,
and rear climb. Cycle sheets sample clothed running and a mirrored jump with
clothing/headgear removed; these do not exhaust every frame/loadout combination.

```sh
godot --headless --path . --script tests/duneborn_surface_regression.gd
godot --path . --script tools/render_duneborn_reference.gd
godot --path . --script tools/render_human_cycle.gd -- --duneborn --motion=run
```
