# Base anatomy sprite sources

These generated raster assets are intentionally limited to identity/anatomy that benefits from authored painting:

- `<race>_heads.png`: a dedicated front/rear head pair for each of the eight races.
- `extremities.png`: open hand, gripping hand, bare foot, and centaur hoof.

Armor, pants, headgear, back items, weapons, shields, and accessories are not baked into these sheets. They remain independent modular equipment attached to rig sockets.

The built-in image generator returned uniform chroma-magenta backdrops instead of preserving requested alpha. `BaseAnatomyVisual` owns that source defect and removes the backdrop in its internal shader. Callers only use `setup(race_id, part_id, target_size)` and `set_back_view(enabled)`.

Generation used the supplied `light-lineages.png` as a style and race-design reference. Final prompts requested polished hand-painted chibi 2D game sprites with warm dark-brown outlines, expressive anime-inspired eyes, soft cel-painted storybook shading, matching front/rear head views, detached anatomy only, and no equipment, bodies, text, scenery, or watermarks. The extremity prompt requested an open hand, gripping hand, bare foot, and centaur hoof on a uniform chroma background. The Duneborn prompt requested warm brown skin, human ears, and long practical dark braids.
