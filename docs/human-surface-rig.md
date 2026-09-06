# Human character surface rig

The human keeps the original front/rear head illustration and the existing
animation and equipment API. Its body now uses a dedicated painted anatomy atlas
referenced from the original head, with continuous deformation under the artwork.
Clothing follows those surfaces or a mesh bound to the same pose.
The other seven lineages retain their existing art and construction.

## Rendering strategy

- `HumanPaintedAtlas` shares tight crops for the painted front/rear torso, whole
  arm, whole leg, hands and foot. Its shader removes the source's neutral
  checkerboard; the warm skin shading and brown contours come from the artwork.
- `HumanTorsoSurface` bends the front/rear painted torso from neck to pelvis.
- `HumanLimbSurface` spans each two-bone chain, rounding the elbow/knee without
  drawing a seam across it. `HumanLimbPaint` maps the whole limb painting by arc
  length over explicit triangles, including tightly folded joints. Separate
  clothing contours still carry sleeves, bracers and trousers.
- `HumanExtremityVisual` supplies painted feet and open/front-grip/back-grip hands.
- `GarmentSurface` fits the authored torso texture to the human shoulder span.
  Shoulder openings share arm motion, the chest follows the torso, the waist
  follows the pelvis and the skirt shares thigh motion. Plate restricts bending
  to its shoulder attachments and lower skirt.
- `ClothSurface` distributes cape/scarf animation from the pinned upper section
  toward the free end. Rigid weapons, boots, headgear, packs and jewelry retain
  their sockets. Held shields occlude the gripping hand; stowed shields sit
  above the rear cape and release both climbing hands.

The original head textures, socket positions, motion curves, saved loadout keys,
and independently selectable equipment remain intact. Human is selected when
the builder opens. Surface meshes are cached while their pose is unchanged.

## Verification

| Requirement | Evidence |
| --- | --- |
| Connected human body and matching extremities | `artifacts/human_body_showcase.png`; `tests/human_surface_regression.gd` |
| Clothing follows running and stair poses | `artifacts/human_run_cycle.png`, `human_stairs_cycle.png`; garment binding tests |
| Equipment follows melee and ranged actions | `artifacts/human_jab_cycle.png`, `human_forehand_cycle.png`, `human_backhand_cycle.png`, `human_fire_bow_cycle.png`, `human_fire_crossbow_cycle.png`, `human_cast_spell_cycle.png` |
| Raised arms and rear equipment order | `artifacts/human_armor_fit_rear.png`, `human_climb_cycle_left_shield.png`, `human_vault_cycle.png` |
| All nine armor choices fit the human | `artifacts/human_armor_fit.png` and its rear comparison |
| Builder integration and lineage isolation | `artifacts/builder_stairs_preview.png`; builder, human-surface, anatomy and smoke regressions |

Cycle sheets sample twelve times across each action, including anticipation,
contact and recovery; they are visual checks rather than exhaustive coverage
of every possible loadout combination. The regression suite separately exercises
all equipment items, locomotion, attacks, gestures, facing and interruptions.

Run all regressions from the repository root:

```sh
for test in tests/*.gd; do
  godot --headless --path . --script "$test" || exit 1
done
```

Reproduce visual checks with a graphics display:

```sh
godot --path . --script tools/render_human_ranger_showcase.gd
godot --path . --script tools/render_human_ranger_showcase.gd -- --bare
godot --path . --script tools/render_human_cycle.gd -- --motion=run
godot --path . --script tools/render_human_cycle.gd -- --motion=climb --left --shield
godot --path . --script tools/render_human_armor_fit.gd -- --rear
```

For new armor, author a transparent torso texture and its required rear view,
then tune its material and sleeve treatment on the existing human surfaces.
Keep rigid objects on sockets; use deformation for garments spanning joints.
