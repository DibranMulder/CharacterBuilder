# Base anatomy sprite sources

These generated raster assets are intentionally limited to identity/anatomy that benefits from authored painting:

- `<race>_heads.png`: a dedicated front/rear head pair for each of the eight races.
- `extremities.png`: open hand, gripping hand, bare foot, and centaur hoof.
- `centaur_tail.png`: a detached, side-facing horse tail rooted for animation at the rump.
- `centaur_tail_back.png`: the same tail viewed from behind for the ladder-climbing pose.

Armor, pants, headgear, back items, weapons, shields, and accessories are not baked into these sheets. They remain independent modular equipment attached to rig sockets.

The head, extremity, and rear-tail generations returned chroma-magenta backdrops instead of preserving requested alpha. `BaseAnatomyVisual` owns that source defect and removes the backdrop in its internal shader. The side centaur-tail generation preserved transparency. Callers only use `setup(race_id, part_id, target_size)` and `set_back_view(enabled)`.

Generation used the supplied `light-lineages.png` as a style and race-design reference. Final prompts requested polished hand-painted chibi 2D game sprites with warm dark-brown outlines, expressive anime-inspired eyes, soft cel-painted storybook shading, matching front/rear head views, detached anatomy only, and no equipment, bodies, text, scenery, or watermarks. The extremity prompt requested an open hand, gripping hand, bare foot, and centaur hoof on a uniform chroma background. The Duneborn prompt requested warm brown skin, human ears, and long practical dark braids. The side centaur-tail prompt requested one layered chestnut tail flowing left from a right-edge rump anchor. The rear-tail prompt used that sprite as an identity reference and requested the same tail hanging vertically from a centered top root for ladder climbing, on a uniform chroma background.

The `*_v2.png` sheets for Frost Troll, Duneborn, and Frostling were regenerated
from `dark-lineages.png` after a closer design pass. Their final prompts locked
the Frost Troll to a broad friendly blue-gray face, dark crest, spots and small
tusks; the Duneborn to warm skin visible only through layered burgundy head and
face wraps; and the Frostling to a compact weathered charcoal face, enormous
ice-blue eyes and shaggy white hair. The built-in generator baked its visual
alpha checkerboard into the first outputs, so a precise follow-up edit replaced
only that backdrop with the same chroma-magenta color removed by
`BaseAnatomyVisual`.

`frost_troll_extremities.png` is a dedicated three-cell anatomy atlas generated
from `dark-lineages.png`: an oversized open hand, an oversized gripping hand,
and a broad three-toed foot. Both hands enter from the left so the shared
forearm socket and its existing 90-degree presentation continue to work for
every weapon and shield. Unlike the shared human atlas, these sprites retain
their authored blue-gray skin and mottling without runtime tinting.
The foot region deliberately begins below the source image's oval ankle cap,
turning it into a flat side-view seam where the procedural shin overlaps it.
