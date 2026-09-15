# Human hometown environment generation

Generated with the built-in `image_gen` tool on 2026-09-12, using `designs/moodboards/humans-v2.png` as a visual reference. Assets are copied into the project and do not require the original generated-image directory at runtime. No existing painting was overwritten.

The exact prompts for the keep, tower, ledge, guardian and wildlife are in `hometown-prompts.json`.

## Village series

The exact common prompt, substituting each description below for `{description}`:

> Production 2D side-scrolling game background panorama, 3:1 landscape. {description}. Human homeland Wendmere. Cinematic storybook anime with clean dark contours and richly detailed soft cel-painted shading, luminous oversized nature. Royal blue, warm ivory, field green, muted gold, burgundy accents; oak, linen, brass, weathered stone. Side-on orthographic camera. Uninterrupted level stone foreground walking lane with its top at 73 percent image height, extending edge to edge. Upper platforms are background decoration only; game adds collision architecture. Buildings behind the lane. No people, no text, no UI, no borders. Match the attached Human moodboard's settlement painting style.

- **apothecary.png**: Apothecary Lane, a lush medicinal herb garden street with glazed pottery, hanging plants, herb drying racks, a warm plaster apothecary and a grocer's blue awning, ivy and a brook beyond
- **trainers.png**: Trainers' Yard, an open training green with archery targets, wooden practice dummies, weapon racks, linen tents, low stone walls and an oak gallery, hilltop keep behind
- **inn.png**: Hearth Inn interior, a cosy oak-beamed tavern with ivory plaster, glowing stone hearth, brass tankards, blue banners, food-laden tables behind an empty front walking lane, a balcony in the back, no people
- **approach.png**: Stronghold Approach through terraced farmland, apple orchards on green stone terraces, an old stone road, a majestic ivory gatehouse at the far right, ivy covered boundary stones and distant blue-towered keep

## Gatehouse

Exact prompt for `gatehouse.png`:

> Create a production 2D side-scrolling game background panorama, 3:1 landscape. King's Keep Gatehouse Court of Wendmere, Human Open Lands, cinematic storybook anime, clean dark contours soft cel-painted shading. Warm ivory weathered stone layered curtain walls, royal blue and muted gold banners with abstract road knot symbols, ivy, mighty central portcullis, hammered brass lanterns. Distant hilltop towers in blue sky. Flat horizontal stone foreground walking lane at 73 percent image height runs uninterrupted across entire width. Raised ramparts and arches in background only. Empty of people, no UI, no lettering, no borders, NOT a moodboard. Luminous rich painted detail, welcoming adventurous tone, oak doors, burgundy accents. Side-on orthographic game camera, no vanishing-point road. This is a new environment matching the palette and visual quality of the supplied Human moodboard, not a copy of its composition.

## Runtime alignment

`town_visual.gd` aligns the painted road to the simulation floor using per-image floor ratios where the generated composition differed from the prompt. `ledge.png` supplies the separate collision-aligned platform surface through a runtime texture region. `stair.png` is a taller cutaway so the camera can follow the full tower ascent. Guardian and wildlife textures retain their generated alpha; runtime atlases trim transparent margins without modifying the source PNGs.
