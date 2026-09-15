# Regional atlas paintings

Twelve distinct PNGs, generated using the built-in image_gen tool on 2026-09-13. Exact prompts and moodboard references are in [prompts.json](prompts.json). The approved Babylon board is used for Shattered March; Gloamfen, Ashen Scar and Verdant Maw are frontier interpretations of the Tidekin, Crag and Grove palettes respectively.

These are decorative atlas backgrounds. Location IDs, graph edges, discovery, labels and interactions are drawn separately from catalog data. They do not add playable scenes or change portal routes.

`src/world/region_art.gd` owns the matching regional button/route palettes. The region map opens locally by default; World navigates outward. The [region checklist](../../../docs/game/0024-region-quality-rules.md) defines review requirements.

## Verification, 2026-09-13

- All twelve images load as distinct textures with adequate resolution.
- Each region opens with its current location selected and the full region in view; World restores the shared global style without changing discovery.
- Atlas, map-input, UI-event, hometown-travel and Tidekin-playtest regression scripts pass.
- All twelve region views, eight stronghold views, the world overview and Babylon depths were rendered at 1152×648 with `tools/capture_world_atlas.gd`.
- Region views were visually inspected for palette, background coverage and route/marker contrast. Use group zoom for detailed reading; the whole-region view fits all public nodes.

Gameplay completion and sprite transparency are separate checks, not implied by these results.
