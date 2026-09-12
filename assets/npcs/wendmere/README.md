# Wendmere guard force

Dedicated full-body halberd sentry and shield captain, generated with the
built-in imagegen tool. `guards.png` is the initial source. `guards_keyed.png`
is the runtime atlas, split into equal left/right halves by `guard_visual.gd`.
The initial transparency request produced an opaque background, so a second
imagegen edit supplied a flat magenta background. The existing game shader
removes it and suppresses edge spill. The runtime preserves the original artwork.

Guards stand about 192 world units tall from helmet to boots; no player rig is
used and no per-frame mesh rebuilding or animation processing is required.

## Original prompt

Use case: stylized-concept. Asset type: transparent sprite atlas containing exactly TWO distinct full-body guards for a hand-painted 2D side-scrolling fantasy RPG. The guards protect Wendmere, a human town with royal blue, ivory and brass heraldry. They must read as formidable veteran soldiers, NOT youthful adventurers, NOT a copy of a small player character. Left guard: broad muscular veteran pikeman, huge armored shoulders, thick chest, closed steel barbute helmet with narrow eye slit, substantial breastplate over navy quilted sleeves, ivory surcoat with a simple blue road-knot symbol (no real crest), dark blue heavy cape, thick leather gloves and steel greaves, planted wide boots, long halberd held upright on his OUTER left side, heavy kite shield in his other hand. Right guard: even stockier armored gate captain, closed angular visor, larger pauldrons, oxblood waist sash, layered blue-and-ivory tabard, brass-edged steel armor, large tower shield planted next to him on OUTER right side, sheathed sword. Both look disciplined and strong with adult 5.5-head body proportions, no exposed face, confident wide grounded stance, three-quarter front view, readable silhouettes, illustrated warm contour shading and crisp painterly surface details matching a charming but grounded 2D fantasy game. 3:2 landscape atlas. Place the left figure wholly inside the left half and right figure wholly inside the right half, plenty of clear space between them, all weapons, shields, cape and boots fully inside their own half, same ground baseline at 94 percent image height. Both approximately 85 percent image height including helmets, halberd tip may reach 3 percent height. GENUINELY TRANSPARENT background with clean alpha edges; no scenery, no floor, no cast shadow, no labels, no text, no watermark. Their outfits must be clearly different from one another yet belong to one guard force. Finished painted game sprites, not a character concept sheet with annotations.

## Background preparation prompt

Edit this guard sprite atlas for use in a game. Preserve BOTH guards exactly: all armor, weapons, colors, proportions, faces hidden by helmets, pose, spacing, size and position. Change ONLY the background. Replace ALL dark background, glow, vignette and background shadow, including the spaces inside the silhouettes, with one perfectly flat uniform pure RGB #FF00FF magenta color. No gradient, no glow, no shadows on the magenta. Keep crisp antialiased cutout edges around metal, fabric and weapon tips. The entire background must be #FF00FF for clean game-engine chroma keying. Do not add text or any new object.
