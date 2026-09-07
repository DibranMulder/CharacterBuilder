# Centaur painted surface rig

The active artwork is `centaur_reference_upper_v3.png` and
`centaur_reference_equine_v3.png`, newly drawn using `light-lineages.png` itself
as the reference. The older source files are preserved but no longer selected.
The upper atlas coordinates the pointed-eared face, waist-length braided hair,
bare chest, arms and hands. The equine atlas supplies a compact smooth-coated
barrel, sturdy fore/hind legs, small dark hooves and a shorter wavy tail.
`CentaurPaintedAtlas` owns the body crops and magenta key. The head adapter sizes
the face independently from its long hair, placing the hair behind the chest in
profile and over the back when climbing.

Proportions follow `light-lineages.png`: the humanoid torso is 70×70 rather than
54×76, arms are 22 units wide, equine leg surfaces 38, and the barrel is a more
compact 116×70. Hooves are 22×13 and the tail is 45×66. The head is lowered 9
units into the shoulder line. The harness is fitted in both width and height
so its leaf tabs cover the waist. Only the lowest abdominal mesh rows taper
into the withers; the chest keeps its full width.

The barrel and withers now share one silhouette; the separate flared neck is
hidden. Whole-arm and whole-leg paintings use the same continuous two-bone strip
as the human, retaining the original wrist/hoof sockets. Fore and hind legs have
separate paintings and paired roots: indices 0/1 are hind, 2/3 are fore; even
indices are far-side and odd indices near-side. The entire rig mirrors for left.
The hip height includes the equine leg-root offset so standing hooves meet the
ground. The humanoid torso's lower mesh rows stay bound to the offset horse hip.

Rear climbing retains the existing foreshortened horse-body convention and hides
the side-view legs. It swaps torso/body views and narrows and rotates the tail
down the center of the rump. Equipment and hand-state APIs remain unchanged.

Rearing Strike now pitches the whole hip assembly by 32 degrees, counter-rotates
the supporting hind legs, and solves hip translation to keep the near hind hoof
planted. Recovery and interruption restore the captured pose. The separate Jump
motion still lifts all four hooves and lands as a one-shot action.

## Verification

The rendered twelve-frame sheets in `artifacts/centaur_*_cycle.png` cover idle,
stand, run, stairs, climb, jump, jab, forehand, backhand, bow, crossbow, spell,
Gallop Shot, Rearing Strike and Grove Tempest. Additional `_left` sheets check
run, climb, jump, rearing and bow. The v3 art pass refreshes the side/rear preview
and run, jump and rearing in both facings; other sheets retain the previous art
until regenerated with the same tool. The bare gallop sheet exposes body seams without
equipment; `centaur_views.png` compares the equipped side and rear silhouettes.
`centaur_reference_comparison.png` places the original concept crop beside the
live rig, using `tools/render_centaur_reference.gd`. This is the primary visual
comparison; passing motion tests alone does not establish artistic fidelity.

`tests/centaur_surface_regression.gd` checks continuous endpoints through all menu
motions in both facings, near/far layering, planted rear contact, recovery and
attack/gesture interruption. The existing suite additionally checks equipment,
weapon reach, attack curves, all lineage motions and effects, jump, and UI.
Visual checks are pose samples, not proof of every frame of every loadout.

```sh
godot --headless --path . --script tests/centaur_surface_regression.gd
godot --path . --script tools/render_centaur_views.gd
godot --path . --script tools/render_human_cycle.gd -- --centaur --motion=run --bare
godot --path . --script tools/render_human_cycle.gd -- --centaur --motion=gesture1 --left
```
