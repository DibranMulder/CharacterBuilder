# Review evidence and generated output

This directory retains screenshots referenced by project documentation and the
paired measurements in `performance-review.json` and
`tidekin-content-performance.json`. Unreferenced captures have been removed;
capture and render scripts remain available to regenerate them.

Run capture tools from the repository root, for example:

```sh
godot --path . --script tools/render_lineage_showcase.gd
godot --path . --script tools/capture_world_atlas.gd
godot --path . --script tools/capture_tidekin_town.gd
```

New PNG captures, JSON measurements, and logs are ignored by Git. Add new evidence
deliberately with `git add -f artifacts/<file>` and link it from the relevant
review. Existing tracked evidence can still be updated normally.

`.gdignore` prevents Godot from importing these documentation images as game
textures. Runtime assets belong in `assets/`; authored concept art belongs in
`designs/`.
