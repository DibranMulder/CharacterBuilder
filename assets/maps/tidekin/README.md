# Tidekin painted backgrounds

Generated with the built-in image_gen tool on 2026-09-13. The Tidekin moodboard supplies palette, architecture and materials; the Wendmere approach painting supplies the side-scrolling composition and rendering reference. Exact prompts and references are recorded in [prompts.json](prompts.json).

- `landing.png`: Tidewharf Landing, quay and village.
- `shallows.png`: Siltbank Shallows, coral and coastal channels.
- `pools.png`: Ripplefin Pools, nursery lagoon and sluices.

All three originals are stored in the project without raster modification. Runtime draws the paintings proportionally and aligns their observed walking surfaces (0.635, 0.705 and 0.745 of image height) to floor y=480. Small texture regions supply the optional collision-aligned stone ledges. Portals, creatures and interactive effects remain separate from the environment painting.

Verified with rendered screenshots of all three maps and the Tidekin playtest regression. The shared atlas is covered by the world atlas and map-input regression scripts.

Five additional paintings (`citadel`, `shrine`, `mangrove`, `storm`, `confluence`) expand the runtime to eight environmental kits across 39 maps. Exact prompts and original generated-image paths are in `expansion-prompts.json`. Higher routes use the same painting scaled to cover their full camera range; collision-aligned ledges reuse regional stone textures. `tools/capture_height_routes.gd` captures the expanded kits and highest platforms.
