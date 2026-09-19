# Base anatomy sprite sources

These generated raster assets are intentionally limited to identity/anatomy that benefits from authored painting:

- `<race>_heads.png`: a dedicated front/rear head pair for each of the eight races.
- `extremities.png`: open hand, palm-facing grip, back-of-fist weapon grip, bare foot, and centaur hoof.
- `bogkin_extremities_storybook_v1.png`: true-alpha open palm, front/rear
  weapon grips, and a broad webbed foot painted specifically for the Bogkin.
- `shared_humanoid_anatomy_storybook_v1.png`: full-resolution five-piece
  source sheet for the painted torso, upper arm, forearm, thigh, and shin.
- `shared_humanoid_anatomy_storybook_v2.png`: the accepted style-matched source
  sheet. It replaces the bowed arm silhouettes with near-straight socket axes
  and uses the same confident warm-brown contours, clean cel shadows, and
  restrained highlights as the authored Human head. Runtime crops use the
  matching `anatomy_<part>_storybook_v2.png` names.
- `anatomy_<part>_storybook.png`: transparent runtime crops derived from that
  source. `BaseAnatomyVisual` stretches each crop to the existing bone contract
  and recolors only its painted interior while preserving the warm-brown ink.
  Its nonlinear tone transfer expands the pale neutral source into a deeper
  0.42–1.12 modeled-light range, retaining painted joint occlusion and form
  instead of washing every lineage into the same bright mannequin surface.
- `centaur_tail.png`: a detached, side-facing horse tail rooted for animation at the rump.
- `centaur_tail_back.png`: the same tail viewed from behind for the ladder-climbing pose.
- `fae_wing_storybook.png` and `fae_wing_storybook_left.png`: an exact
  mirrored pair of true-alpha, double-lobed ivory membranes with painted
  gold veins, rooted for the existing independent Fae wing bones.

Armor, pants, headgear, back items, weapons, shields, and accessories are not baked into these sheets. They remain independent modular equipment attached to rig sockets.

Seven lineages now use those five shared painted cutout pieces behind the
existing `PartVisual` seam, so locomotion and attacks keep their established
pivots while the base body matches the authored heads and equipment.

The Frost Troll uses a separate five-piece source,
`frost_troll_anatomy_storybook_v2.png`, and runtime crops named
`frost_troll_anatomy_<part>_storybook_v2.png`. Its broad torso, thick limbs,
blue-gray painting, and slate mottling are authored directly instead of
stretching or tinting the shared humanoid pieces. The v2 arm segments replace
the bowed, glossy source with straight socket axes and the same matte contour,
cel-shadow, and marking treatment as the Frost Troll head. Their integrated
overlap seams also remove the old chain of separate spherical joints.

The Centaur's equine topology is authored separately as well:
`centaur_equine_side_storybook_v1.png` supplies the side body, waist-to-withers
transition, upper leg, and shin; `centaur_equine_back_storybook_v1.png` supplies
the foreshortened body and transition used while climbing. Transparent runtime
crops are named `centaur_horse_<part>_storybook.png`. The side/rear body and
neck swap through `BaseAnatomyVisual.set_back_view()`, while the existing
authored side/rear tail and shared hoof cells remain independently animated.

The Fae wing pair replaces the earlier procedural translucent polygons without
changing the rig seam. Each 84×80 sprite draws around a registered waist root;
the two bones keep their mirrored resting cant, idle flutter, run down/upstroke,
stair balance, ladder fold, and gesture-specific impact rotations. The
full-resolution `fae_wing_storybook_v2.png` is the accepted true-alpha source;
the left runtime sprite is a deterministic mirror of the right.

The original shared head, extremity, and rear-tail generations returned chroma-magenta backdrops instead of preserving requested alpha. `BaseAnatomyVisual` owns that source defect and removes the backdrop in its internal shader. Its coverage is based on balanced red/blue dominance rather than distance from one exact key color, then subtracts the remaining magenta contribution from antialiased edge pixels. This prevents neon fringe without eroding warm-brown ink, hair, skin, or blue cloth. The Bogkin extremities and side centaur-tail preserve genuine transparency and therefore bypass chroma keying. Callers only use `setup(race_id, part_id, target_size)` and `set_back_view(enabled)`.

Generation used the supplied `designs/references/light-lineages.png` as a style and race-design reference. Final prompts requested polished hand-painted chibi 2D game sprites with warm dark-brown outlines, expressive anime-inspired eyes, soft cel-painted storybook shading, matching front/rear head views, detached anatomy only, and no equipment, bodies, text, scenery, or watermarks. The extremity prompt requested an open hand, gripping hand, bare foot, and centaur hoof on a uniform chroma background. The Duneborn prompt requested warm brown skin, human ears, and long practical dark braids. The side centaur-tail prompt requested one layered chestnut tail flowing left from a right-edge rump anchor. The rear-tail prompt used that sprite as an identity reference and requested the same tail hanging vertically from a centered top root for ladder climbing, on a uniform chroma background.

The Frost Troll `v2`, Centaur `v2`, Duneborn `v3`, and Frostling `v3` head
sheets use one shared contour, cel-shadow, highlight, and texture language.
Their designs remain lineage-specific: the Troll keeps its friendly blue-gray
face, crest, spots, and tusks; the Centaur retains warm skin and elaborate
rounded-ear woodland braids; the Duneborn keeps warm skin visible only through
layered burgundy wraps; and the Frostling retains its weathered charcoal face,
ice-blue eyes, and shaggy white hair. Their chroma-magenta fields continue to
be removed inside `BaseAnatomyVisual`.

`frost_troll_extremities.png` is a dedicated anatomy atlas generated from
`designs/references/dark-lineages.png`: an oversized open hand, palm-facing grip, back-of-fist
weapon grip, and a broad three-toed foot. All hands enter from the left so the shared
forearm socket and its existing 90-degree presentation continue to work for
every weapon and shield. Unlike the shared human atlas, these sprites retain
their authored blue-gray skin and mottling without runtime tinting.
The foot region deliberately begins below the source image's oval ankle cap,
turning it into a flat side-view seam where the procedural shin overlaps it.
The shared and troll back-of-fist cells show knuckles while gripping an invisible
handle; the shared human-base cell exposes only the thumbnail, not fingernails on
the curled fingers. Palm-facing grip cells remain available for ladder climbing.

`bogkin_extremities_storybook_v1.png` was generated from the supplied
`designs/references/light-lineages.png` design and the shared extremity atlas's socket layout. The
final prompt requested exactly four isolated teal amphibian pieces in a 2×2
sheet: a four-finger webbed palm, a compact front grip with a handle opening, a
rear grip, and a broad webbed side-view foot, all with warm dark-brown ink and
storybook cel shading. It contains no clothing, weapons, text, or scenery. The
source is already transparent, retains its authored teal mottling without a
runtime tint, and is sampled through the `BOGKIN_EXTREMITY_REGIONS` atlas map.
