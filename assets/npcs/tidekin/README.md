# Tidekin residents

`residents.png` was generated with the built-in imagegen tool using
`designs/moodboards/tidekin.png` as its visual reference. It does not use the
character-builder artwork or rig. Seven civilian/service silhouettes and the
Mireback guardian share one atlas. The shader removes the generator's flat
magenta background and despills the antialiased edges.

The eight cells are: ferrymaster, pearl trader, kelp healer, reefguard, engineer,
archivist, innkeeper and Mireback. Runtime crop rectangles exclude neighboring
cells. Resident role selects the painting; idle breathing, facing and short
walks use sprite transforms rather than geometry uploads or baked viewports.

Final prompt: Preserve eight moodboard-inspired full-body Tidekin characters;
4 columns × 2 rows, each sprite centered within its own 384×512 cell on a
1536×1024 sheet with generous empty margins. Flat solid chroma-key magenta
#FF00FF throughout empty space, without gradients or background shadows.
Cream linen, kelp, shells, verdigris bronze, large amber eyes and webbed feet;
the Mireback carries moss, roots and miniature ruined towers on its shell.

Earlier transparent-background attempts returned opaque gradients and were
rejected. The selected chroma atlas is the only generated source used in game.
