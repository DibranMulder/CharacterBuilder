# Head and scarf presentation

The playable heads retain their lineage-specific reference artwork and removable
headgear. `head_paint.gdshader` keys four subpixel samples before averaging their
premultiplied colors, keeping fine hair readable at gameplay scale without dark
chroma fringes. Atlas clipping isolates the selected head view. The shader also
respects character tint and opacity.

The scarf uses `assets/equipment/scarf_painted_atlas.png`, a paired front/rear
painting based on the human collar in `designs/references/light-lineages.png`. It replaces the small
tubular-ring artwork with broad cloth folds, a raised rear collar, and a brass
clasp. The rear view has no front clasp. Source art remains intact; the renderer
maps each region onto the cloth mesh and applies lineage dye.

Crag Trolls do not wear scarves. The catalog rejects that combination in the
builder, imported outfits, and inventory; previews leave their neck uncovered.
Other lineages have an explicit collar fit in `_attach_gear`. The scarf is above
the torso but behind the jaw and rear hair. Its top stays pinned under secondary
motion while the lower fabric bends, including on non-human lineages. Equipping
or removing it does not alter the head or saved outfit schema.

`tools/render_neck_fit.gd` renders all eight lineages bare-necked, scarf-equipped,
left-facing, rear-facing and mid-run. `tests/scarf_fit_regression.gd` protects
layering, fit, view switching and the pinned collar contract.
