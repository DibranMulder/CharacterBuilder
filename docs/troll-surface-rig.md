# Frost Troll reference-art surfaces

The leftmost character in `dark-lineages.png` guides the new troll: broad
slate-blue mottled anatomy, a friendly tusked face, dark crest, thick arms,
short sturdy legs, oversized hands and bare feet. Two coordinated paintings
live in `troll_reference_base_v3.png` and `troll_reference_clothes_v3.png`.
The original assets remain available.

`TrollPaintedAtlas` owns the crops and a magenta-key material that preserves
blue skin. `TrollAppearance` fits the body and front/rear jerkin to the shared
torso surface; the garment hem follows the hip. Whole-arm and whole-leg
paintings bend over `HumanLimbSurface`, without separate visible upper/lower
segment sprites. Reference leather shorts and bracers are painted into those
continuous surfaces. Other equipment uses the existing clothing fallback.

The head and neck overlap the upper chest. Hands and feet retain the existing
equipment sockets. Wider shoulders and heavier arms required an inward resting
forearm bend to keep the second axe grip reachable, plus a small follow-through
timing adjustment to preserve weapon-tip continuity. The existing axe artwork
and motion system remain in use; the pose is not a tracing of the reference.

## Verification

`tests/troll_surface_regression.gd` covers both facings, all menu motions,
continuous wrist/ankle endpoints, rear-view switching, all armor/pants/boots
swaps, gestures and weapon-triggered rig rebuilds. The shared attack and weapon
tests additionally check tip continuity and the second hand's axe attachment.

Visual samples include the reference comparison, running with and without
clothing, mirrored jumping, and the first lineage gesture. These samples do
not exhaust every possible frame and loadout.

```sh
godot --headless --path . --script tests/troll_surface_regression.gd
godot --path . --script tools/render_troll_reference.gd
godot --path . --script tools/render_human_cycle.gd -- --troll --motion=run
```
