# Fae reference-art surfaces

The Fae is rebuilt from the rightmost character in `light-lineages.png`, using
three new paintings: `fae_reference_base_v2.png`,
`fae_reference_clothes_v2.png`, and `fae_reference_wings_v2.png`. The older
sources are preserved. The new head and ponytail, cream base torso, arms, legs
and hands share a coordinated storybook treatment. The reference outfit keeps
the red capelet, mustard split tunic, teal sash, dark baggy trousers and wraps.

`FaePaintedAtlas` owns source selection and crops. `FaeAppearance` fits the
artwork to the existing rig and refreshes it on equipment and rear-view changes.
The head adapter sizes the face separately from the long ponytail, maintaining
their exact source alignment. The neck overlaps the upper torso.

Whole-arm and whole-leg paintings use `HumanLimbSurface` and its continuous
two-bone strip. The baggy trouser painting covers each complete leg, rather
than using separate thigh/shin clothing sprites. Other pants and armor retain
the shared continuous clothing fallback. The fitted waistband sits beneath
the tunic tails. Wrapped feet use coordinated art; other footwear remains
swappable through the original equipment system.

The body and tunic use the shared torso mesh with optional front/rear textures,
material, artwork orientation and hem length. The tunic's lower rows follow
the hip, while the upper chest follows the torso. This shares the human and
centaur surface technique without flattening the Fae into one rigid sprite.

New angular insect-wing paintings replace the old leaf-shaped membranes on
the same animated wing pivots. The membrane shader keeps the blue-gray fill
translucent while retaining stronger cream-gold veins. Facing, running, stairs,
jumping, climbing, spellcasting, weapon sockets and all three gestures remain
owned by the existing rig. The default pose is still the rig's pose, not a
fixed tracing of the concept illustration.

## Verification

`tests/fae_surface_regression.gd` covers continuous wrist/ankle endpoints through
all menu motions and both facings, rear texture switching, near-leg depth,
all armor/pants/footwear swaps, gesture interruption and crossbow rebuilds.
The broader regression suite also checks existing lineages and equipment.

`artifacts/fae_reference_comparison.png` shows the original beside live side
and rear views. Cycle sheets cover run, jump, climb, spellcasting and all three
gestures, plus mirrored and unequipped running. These are sampled visual checks,
not proof of every possible frame/loadout combination.

```sh
godot --headless --path . --script tests/fae_surface_regression.gd
godot --path . --script tools/render_fae_reference.gd
godot --path . --script tools/render_human_cycle.gd -- --fae --motion=run
```
