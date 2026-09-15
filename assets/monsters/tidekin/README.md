# Tidekin creature art

The [monster moodboard](../../../designs/moodboards/tidekin-monsters.png) expands the original Tidekin culture board with all sixteen DESIGN-0023 creatures. The [manifest](manifest.json) records names, dispositions, exact prompts, source rectangles and pivots.

All sixteen individual PNGs have real RGBA transparency and are loaded by the playable Tidekin region. The source sheet is preserved as `creatures-source.png`; it contains the generator's baked checkerboard and must not be loaded into gameplay. `creatures.png` is the intermediate full-sheet alpha export; runtime uses the individually trimmed files.

The user approved local cleanup after two RGB generation results. Reproduce the individual exports with:

```sh
uv run --with pillow --with numpy --with scipy python tools/prepare_tidekin_sprites.py
```

These are static poses. Runtime supplies facing, hit flashes and separate attack telegraphs. Benevolent sprites support aid encounters, hostile/neutral sprites support combat, and the Undertow Regent is optional. Fine translucent highlights, particularly the lanternfish's glow, still merit further art polish.
