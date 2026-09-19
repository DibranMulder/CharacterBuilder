# Authored modular equipment

These sprites replace the flat procedural equipment one item at a time while
keeping `GearVisual` as the stable socket, draw-order, and animation interface.

Runtime root offsets are part of that interface: the lantern hangs from its
painted top loop below the offhand socket at a readable 1.35 display scale, and
the diagonal quiver is biased outside the torso so its arrows and leather body
remain readable while the whole rig mirrors. During ladder climbing, lanterns
and books use separate upper-left rear stows above the diagonal weapon instead
of disappearing beneath it. All retain their existing animated socket parents.
While handheld, a damped gravity-hang update counter-rotates the lantern against
the animated arm chain; the suspension point follows the hand through running,
stairs, and attacks while the lamp stays vertical with only a two-degree idle
pendulum drift.

## Sword

- `sword_storybook_v1.png` is the full-resolution generated source.
- `sword_storybook.png` is the trimmed, rotated, game-scale texture. Its leather
  grip crosses the local origin and its blade extends along local `+Y`, matching
  `GearVisual.reach_endpoint()` and the existing weapon attack curves.

The built-in image generator used both supplied lineage paintings as strict
style references. The prompt requested one detached, vertical one-handed sword
with a silver blade, golden-bronze guard, brown leather grip, warm dark-brown
inked edges, soft storybook cel shading, genuine transparency, and no hand,
character, scenery, text, shadow, or watermark.

## Shield

- `shield_exterior_storybook_v1.png` and `shield_interior_storybook_v1.png` are
  the full-resolution paired source views.
- `shield_exterior_storybook.png` and `shield_interior_storybook.png` are the
  trimmed 60-pixel runtime sprites centered on `GearVisual.SHIELD_CENTER`.
- The `_checker` source records the rejected first interior output whose alpha
  checkerboard was baked into the pixels; it is not imported by runtime code.

The exterior prompt requested a straight-on oak round shield with silver rim,
golden-bronze boss and restrained radial motif. Wielded and back-mounted poses
show this decorated face in both mirrored directions, matching every shielded
character in the supplied concept sheets. The interior remains available for a
future explicit shield-flip or inspection pose. Its prompt preserved
the same shield identity while replacing the ornament with visible planks,
fasteners, a leather forearm strap, and a separate hand grip. A precise built-in
edit removed only the interior source's generated checkerboard and restored
genuine alpha.

`marsh_shield_exterior_storybook.png` and
`dune_shield_exterior_storybook.png` are independently selectable 96×96
true-alpha variants that preserve the same center-boss hand socket and shared
interior. The built-in image generator produced each as a separate asset. The
marsh prompt requested five irregular dark-oak slats, weathered bronze, crossed
reed lashings, green cord knots, a compact silhouette, warm inked storybook
painting, and no character, scenery, heraldry, text, or watermark. The dune
prompt requested dark wood, broad aged brass, eight restrained rivets, a raised
boss, subtle quarter-panel desert-sun engraving, the same storybook treatment,
and the same exclusions. Both full-resolution outputs were alpha-trimmed,
downsampled to an 84-pixel painted silhouette, and centered on transparent
96-pixel canvases so their texture density matches the original runtime shield.

## Staff

- `staff_storybook_v1.png` is the full-resolution generated source.
- `staff_storybook.png` is the trimmed, rotated 200-pixel runtime sprite. Its
  butt begins at `GearVisual.POLE_BUTT`, the leather wrapping crosses the hand
  origin, and the blue crystal ends at the staff reach endpoint used to spawn
  spell projectiles.

The built-in image generator used both lineage paintings plus the authored
sword and shield as references. The prompt requested one detached full-length
dark-wood staff with a worn leather grip, restrained bronze fittings, and a
single luminous blue crystal in a forked wooden crown, with genuine alpha and
no character, scenery, particles, text, or watermark.

## Branch staff

- `branch_staff_storybook_v1.png` is the transparent 64×204 runtime asset for
  the separately selectable `branch_staff` item. Its butt, leather grip, and
  forked crown use the same pole socket and 126-pixel spell reach as the crystal
  staff, so it shares casting, locomotion, climbing, and projectile behavior.

The built-in image generator used `designs/references/light-lineages.png` as the authoritative Fae
design reference and the crystal staff only as an orientation/grip template.
The final prompt requested one slender hand-carved warm-brown branch staff with
a restrained leather wrap, uneven Y-shaped crown, one small green leaf, genuine
transparency, and no crystal, metal ornament, glow, character, scenery, text, or
watermark. A deterministic export removed the generator's low-alpha brown
presentation glow, cropped the painted silhouette, and preserved antialiased
edges in the game-scale texture.

## Bow

- `bow_storybook_v1.png` is the full-resolution unstrung source.
- `bow_storybook.png` is the 40×88 runtime stave. Its rightmost leather grip
  meets the hand origin while both tips align with `BOW_TOP` and `BOW_BOTTOM`.

The built-in image generator used the lineage paintings and authored equipment
set as references. The prompt requested a detached C-shaped recurve stave with
layered warm yew limbs, reinforced tips, leather center wrapping, restrained
bronze collars, genuine alpha, and explicitly no baked string or arrow. The
string, drawn nock, and fired arrow remain procedural so `bow_draw` can animate
continuously and the free hand can follow it into the release pose.

## Crossbow

- `crossbow_storybook_v1.png` is the transparent 110×140 runtime asset. The
  trigger grip sits at the local origin, its forward support grip is 34 pixels
  along the stock, and the guide rail reaches the 88-pixel projectile socket.

The built-in image generator used `designs/references/dark-lineages.png` as the authoritative
Goblin design reference and `bow_storybook.png` for the established wood, ink,
and detail treatment. The final prompt requested exactly one unloaded compact
hand crossbow with dark yew limbs and stock, a bronze trigger and fasteners, a
worn leather pistol grip, a pale taut string, genuine alpha, and no character,
hand, projectile, scenery, text, or watermark. A deterministic alpha cleanup
removed only the generated low-opacity presentation halo before the sprite was
trimmed and fitted to its runtime canvas.

The item uses a dedicated `fire_crossbow` action, releases a compact authored
bolt from the guide-rail tip, and keeps the support hand attached with two-bone
IK during rest, firing, running, and stairs. It disables the offhand slot while
wielded, then moves to the back and releases both arms for ladder climbing.

## Axes

- `axe_storybook_v1.png` and `troll_great_axe_storybook_v1.png` are the two
  full-resolution sources; they intentionally remain separate weapon designs.
- `axe_storybook.png` is the vertically flipped one-handed runtime axe. Its
  lower leather grip crosses the primary hand and its right-side cutting edge
  contains the normal axe reach endpoint.
- `troll_great_axe_storybook.png` is the 120×190 Frost Troll export. Its two
  leather grip zones align with the primary hand and
  `TWO_HANDED_AXE_SECOND_GRIP`; the outer right blade contains the great-axe
  reach endpoint used by trails and attack tests.

The built-in image generator used the lineage paintings and authored equipment
as references. Separate prompts requested a balanced single-bit adventurer axe
and the Frost Troll's enormous symmetric mountain-forged double-bit axe. Both
use dark oak, worn leather, restrained bronze collars, textured steel, genuine
alpha, and no character, scenery, text, blood, or watermark.

## Spear

- `spear_storybook_v1.png` is the full-resolution source.
- `spear_storybook.png` is the vertically flipped 200-pixel runtime sprite. Its
  capped butt begins at `POLE_BUTT`, the leather grip crosses the hand socket,
  and the leaf-shaped spearhead ends at the 126-pixel reach endpoint.

The built-in image generator used both lineage paintings and the authored
sword/axe materials as references. The prompt requested one practical full-
length dark-ash spear with lower-middle leather wrapping, restrained bronze
fittings, a textured silver-steel leaf head, genuine alpha, and no character,
flag, tassel, scenery, text, blood, magic, or watermark. The existing animation
still turns this authored sprite horizontal during its deep chamber and jab.

## Leather armor

- `leather_armor_storybook_v1.png` is the full-resolution detached garment.
- `leather_armor_storybook_back_v1_source.png` is its accepted full-resolution
  true-alpha rear design.
- `leather_armor_storybook.png` is the 82×76 torso-socket export. It keeps real
  transparency around and through the neck and arm openings so lineage anatomy,
  articulated arms, pants, heads, capes, and accessories remain independent.
- `leather_armor_storybook_back.png` is the paired 82×76 rear export. It replaces
  the front closures with a center seam and crossed stabilizing straps.

The built-in image generator used both lineage paintings plus the authored
shield and axe as leather/metal references. The prompt requested a compact
sleeveless frontier jerkin with layered shoulder caps, crossed chest straps,
stitching, waist belt, restrained bronze hardware and split lower tabs, with no
body, mannequin, pants, cloak, weapon, scenery, text, or watermark.

## Cloth armor

- `cloth_armor_storybook_v1.png` is the full-resolution chroma-key source.
- `cloth_armor_storybook.png` is the 82×76 torso-socket export. Its neck and arm
  openings show the same magenta field as the exterior so `GearVisual` can
  remove all of them with one hue-selective shader.
- `cloth_armor_storybook_v2.png` records a rejected deterministic mask: it
  removed the annulus but opened too much of the dark cape beneath the shoulder.
- `cloth_armor_storybook_v3_source.png` is the accepted full-resolution edit;
  `cloth_armor_storybook_v3.png` is its transparent 82×76 runtime export. The
  oversized foreground annulus is replaced by a compact integrated sleeveless
  edge, so attacks no longer show either a floating ring or an exposed cape
  wedge. The tunic identity, neckline, clasps, belt, and split hem are preserved.
- `cloth_armor_storybook_back_v1_source.png` preserves the first transparent rear
  generation; `cloth_armor_storybook_back_v2_source.png` adds deliberately open
  neck and arm sockets. `cloth_armor_storybook_back.png` is the accepted 82×76
  rear export with a plain center seam and rear belt loops.
- The `_checker` files record rejected opaque outputs and are never referenced
  by runtime code.

The built-in image generator used the lineage paintings and leather armor as
references. The prompt requested an ivory linen under-tunic, muted deep-blue
surcoat, fabric folds, stitching, bronze collar fasteners, leather belt and a
split hem with no anatomy or other equipment. Two alpha-extraction edits still
returned opaque checkerboards; the accepted follow-up therefore used the same
chroma-key strategy already established for authored base anatomy. The key
material is applied only to chroma-keyed armor and is cleared immediately when
equipment changes.

## Plate armor

- `plate_armor_storybook_v1.png` is the full-resolution chroma-key source.
- `plate_armor_storybook_back_v1_source.png` is the accepted full-resolution
  true-alpha rear backplate.
- `plate_armor_storybook.png` is the 82×76 torso-socket export. Its neck and
  both arm openings retain the exterior magenta field so anatomy and articulated
  limbs remain independently swappable after the key shader removes that field.
- `plate_armor_storybook_back.png` is the paired 82×76 rear export with a raised
  center spine, riveted seams, rear belt, and genuinely transparent apertures.

The built-in image generator used both lineage paintings, the authored cloth
armor silhouette, and the Frost Troll axe's metal treatment as references. The
prompt requested one compact detached silver-steel cuirass with layered open
shoulder caps, a restrained central ridge, leather side straps and waist belt,
bronze rivets and buckle, and a short segmented fauld. It explicitly excluded
anatomy, undershirts, chainmail-filled openings, other equipment, text, and
shadows. Cloth and plate share the hue-selective key material; leather keeps
its genuine alpha, so changing equipment cannot leak the shader between items.

## Lamellar armor

- `lamellar_armor_storybook_v1.png` and
  `lamellar_armor_storybook_back_v1.png` are the accepted full-resolution front
  and rear transparent sources.
- `lamellar_armor_storybook.png` and `lamellar_armor_storybook_back.png` are the
  paired 82×76 torso-socket exports. Their exterior fields, neck openings, and
  both arm openings retain genuine alpha, so the shoulder and arm chains remain
  independently animated beneath them.

The built-in image generator used `designs/references/dark-lineages.png` as the authoritative
Duneborn reference, with the leather and plate runtime items establishing the
project's detached garment silhouette and detail scale. The final generation
prompt requested one front-facing sleeveless desert cuirass with overlapping
weathered bronze-brown scales, oxblood leather understructure, aged hardware, a
broad belt, split skirt tabs, and a compact burgundy shoulder mantle, while
excluding anatomy and all other equipment. Because the first result baked its
checkerboard and filled the apertures, a targeted built-in background-extraction
edit preserved the garment design while restoring true alpha to the field,
neck, and both arm holes. A paired rear-view prompt retained the same scales,
mantle, belt, and skirt while correctly removing the front buckle; climbing now
selects that back artwork through the shared equipment view-state contract.

## Bogkin marsh tunic

- `marsh_tunic_storybook_v1.png` is the accepted full-resolution transparent
  front source.
- `marsh_tunic_storybook_back_v1.png` records the rear design with a painted
  checkerboard; `marsh_tunic_storybook_back_v2.png` is the accepted
  full-resolution true-alpha rear source.
- `marsh_tunic_storybook.png` and `marsh_tunic_storybook_back.png` are paired
  82×76 torso-socket exports. Their collar/front field and broad arm openings
  preserve Bogkin anatomy and leave the orange scarf independently swappable.

The built-in image generator used `designs/references/light-lineages.png` as the authoritative
Bogkin outfit reference, with cloth armor defining the socket framing and
leather armor supplying belt detail. The front prompt requested a loose
warm-ivory homespun sleeveless tunic, tan bindings, brown belt, brass buckle,
and uneven split hem while excluding frog anatomy, scarf, shield, sword, and
scenery. The rear prompt retained the cloth silhouette but replaced its front
lace and buckle with a center seam and two plain belt loops. A targeted
background-extraction edit converted the generated checkerboard to true alpha.

## Centaur woodland harness

- `woodland_harness_storybook_v1.png` is the accepted full-resolution
  transparent front source.
- `woodland_harness_storybook_back_v1.png` records the rear design with a
  painted checkerboard; `woodland_harness_storybook_back_v2.png` is the
  accepted full-resolution true-alpha rear source.
- `woodland_harness_storybook.png` and
  `woodland_harness_storybook_back.png` are paired 82×76 torso-socket exports.
  Their open torso centers and arm apertures preserve the Centaur's authored
  skin and articulated bow arms.

The built-in image generator used `designs/references/light-lineages.png` as the authoritative
Centaur reference, with the leather armor defining the detached socket framing
and the Fae tunic establishing split-panel detail scale. The front prompt
requested antique-bronze shoulder pauldrons, a diagonal brown leather harness,
small leaf clasp, rear-compatible belt, and layered green leaf skirt while
excluding anatomy, horse body, bow, quiver, and scenery. The rear prompt
replaced front fasteners with crossed straps and simple belt loops. A focused
background-extraction edit converted its checkerboard—including the open back
and arm holes—into genuine alpha.

## Frost Troll jerkin

- `troll_jerkin_storybook_v1.png` is the accepted full-resolution transparent
  front source.
- `troll_jerkin_storybook_back_v1.png` and
  `troll_jerkin_storybook_back_v2.png` retain the generated rear design and its
  first extraction attempt; `troll_jerkin_storybook_back_v3.png` is the
  accepted full-resolution true-alpha rear source.
- `troll_jerkin_storybook.png` and `troll_jerkin_storybook_back.png` are their
  paired 82×76 torso-socket exports. The neck/front field and both arm sockets
  preserve the broad troll anatomy instead of baking blue skin into armor.

The built-in image generator used `designs/references/dark-lineages.png` as the authoritative
Frost Troll outfit reference and the authored leather armor as the detached
socket/framing reference. The front prompt requested a broad charcoal-black
worn hide vest with raw shoulder straps, tan laced chest inset, dull iron
hardware, dark belt, and ragged rust skirt tabs while explicitly excluding
anatomy, sleeves, weapons, and scenery. The rear prompt preserved those
materials and proportions while replacing the front lacing and buckle with a
simple center seam and rear belt loops. Two focused background-extraction edits
were needed to turn its painted checkerboard into genuine alpha.

## Frostling fur coat

- `fur_coat_storybook_v1.png` records the initial front generation with a
  painted checkerboard; `fur_coat_storybook_v2.png` is the accepted
  full-resolution true-alpha front source.
- `fur_coat_storybook_back_v1.png` and `fur_coat_storybook_back_v2.png` record
  the rear design and its first extraction attempt;
  `fur_coat_storybook_back_v3.png` is the accepted full-resolution transparent
  rear source.
- `fur_coat_storybook.png` and `fur_coat_storybook_back.png` are their paired
  82×76 torso-socket exports. The outer field, neck/arm apertures, and split
  tails use genuine alpha so anatomy and articulated limbs remain independent.

The built-in image generator used `designs/references/dark-lineages.png` as the authoritative
Frostling outfit reference and the existing cloth torso as the framing/socket
reference. The front prompt requested a compact midnight-indigo quilted wool
travel coat with an off-white fur collar, open fur-lined arm sockets, leather
belt, aged-brass buckle, and split fur-trimmed tails, while excluding anatomy,
hood, limbs, pants, pack, staff, and scenery. Targeted background-extraction
passes converted the generator's painted checkerboards into real alpha. The
rear prompt preserves the quilting, fur, belt, and silhouette but omits the
front clasp and buckle for correct ladder-facing presentation.

## Fae tunic

- `fae_tunic_storybook_v1.png` records the first true-alpha generation whose
  neck opening was still painted shut.
- `fae_tunic_storybook_v2.png` and `fae_tunic_storybook_back_v1.png` are the
  accepted full-resolution transparent front and rear sources.
- `fae_tunic_storybook.png` and `fae_tunic_storybook_back.png` are their paired
  82×76 torso-socket exports. The front preserves open neck and arm apertures;
  the rear keeps both arm apertures open beneath its wrapped capelet collar.

The built-in image generator used `designs/references/light-lineages.png` as the authoritative Fae
outfit reference, with the cloth and lamellar runtime items supplying the
project's detached silhouette, ink, and detail scale. The prompt requested one
golden-yellow wrap tunic with long split panels, a compact brick-red shoulder
capelet, antique-brass leaf clasp, and muted sky-blue sash, while excluding
anatomy, trousers, wings, weapons, and all scenery. A precision edit opened the
front collar, followed by an isolated background-extraction pass when the edit
baked a checkerboard. The paired rear prompt removes the leaf clasp and front
sash knot; climbing selects that rear artwork through the shared armor
back-view state.

## Lantern

- `lantern_storybook_v1.png` is the full-resolution transparent source.
- `lantern_storybook.png` is the 32×50 runtime sprite. Its lower leather grip
  crosses the offhand origin while the amber body rises above the wrist.

The built-in image generator used both lineage paintings plus the authored
shield and staff as references. The prompt requested one compact adventurer
lantern with a dark bronze frame, warm golden glass, contained candle-like
light, a separate worn leather lower grip, genuine alpha, and no anatomy,
scenery, cast shadow, particles, text, checkerboard, or watermark.

## Spellbook

- `spellbook_storybook_v1.png` is the full-resolution transparent source.
- `spellbook_storybook.png` is the 50×33 runtime sprite. Its lower central spine
  meets the supporting palm while the irregular page silhouette remains open.

The built-in image generator used both lineage paintings plus the authored
shield and staff as references. The prompt requested one detached open book
with ivory parchment, a weathered midnight-blue leather cover, bronze corner
protectors, a strong central crease, and abstract faded arcane diagrams without
readable writing. It required genuine alpha and excluded hands, characters,
other equipment, scenery, tables, cast shadows, floating pages, text,
checkerboards, and watermarks.

## Headgear

- `hood_storybook_v1.png` and `hood_storybook_back_v1.png` are the transparent
  full-resolution front/rear hood sources; their runtime exports are both
  74×76.
- `helm_storybook_v1.png` and `helm_storybook_back_v1.png` are the transparent
  full-resolution front/rear helmet sources; their runtime exports are both
  74×75.
- `crown_storybook_v1.png` is the full-resolution transparent circlet source;
  `crown_storybook.png` is its compact 60×39 runtime export.

The built-in image generator used the lineage paintings, authored human head
sheet, and matching cloth or plate equipment as references. The hood prompt
requested a detached deep-blue cloth shell with stitched folds, bronze collar
studs, and a genuinely transparent face aperture. The helm prompt requested a
detached open-face segmented silver-steel shell with leather edge padding and
bronze rivets. The crown prompt requested a restrained antique-gold five-point
circlet with small blue gems. Every prompt excluded anatomy, mannequin parts,
other equipment, scenery, shadows, text, checkerboards, and watermarks.

Separate rear-view prompts preserved the hood and helm identities while closing
their rear shells. `ModularCharacter` now propagates its climb back-view state
to `GearVisual`, so rear heads are never shown through a front face aperture.
The low open crown keeps one nearly symmetric view without hiding lineage hair.

## Back equipment

- `cape_storybook_v1.png`, `pack_storybook_v1.png`, and
  `quiver_storybook_v1.png` are the full-resolution transparent sources.
- `cape_storybook.png` is the 88×100 rear cape export. Its paired bronze clasps
  straddle the upper-back socket and its irregular split hem supplies a subtle
  running sweep.
- `long_cape_storybook_v1.png` preserves the earlier centered 108×146 cape.
  `long_cape_storybook_v2_source.png` is the full-resolution true-alpha source
  for the accepted replacement. `long_cape_storybook_v2.png` preserves its
  centered 132×146 export, while `long_cape_storybook_v3.png` is the accepted
  160×146 runtime sprite. The final version shares the clasp socket and
  cloth-dye shader while progressively sweeping the lower cloth screen-left
  from the shoulders to the knees, matching the Human reference silhouette
  more closely.
- `pack_storybook.png` is the 70×79 backpack export, centered beneath the same
  socket with its buckled flap, pouch, straps, and lower bedroll intact.
- `quiver_storybook.png` is the 62×100 diagonal export. Its opening and exactly
  three blue-fletched arrows occupy the upper right while its capped leather
  body terminates at the lower left.

The built-in image generator used both lineage paintings and the matching
authored cloth, leather, shield, bow, and pole-weapon assets as references.
Separate prompts requested a stitched deep-blue travel cape, a compact worn
leather-and-bronze frontier pack with a blue-gray bedroll, and a slim diagonal
leather quiver with three ash shafts and muted blue fletching. All three prompts
required genuine alpha and excluded anatomy, mannequins, other equipment,
scenery, floors, shadows, text, checkerboards, and watermarks.

The accepted second-generation long cape used `designs/references/light-lineages.png` as the
authoritative Human silhouette reference and both earlier capes as its clasp,
ink, and textile references. The built-in prompt requested one detached
royal-blue travel cape with two brass clasps, large painterly folds, a broad
screen-left wind sweep, and a worn split hem. It excluded characters, anatomy,
other equipment, shadows, scenery, text, frames, and baked backgrounds. The
generated source contains genuine alpha; deterministic alpha-level cleanup,
downsampling, and a clasp-anchored perspective sweep retain antialiased cloth
edges without a runtime chroma key.

## Accessories

- `scarf_storybook_v1.png` and `scarf_storybook_back_v1.png` are the transparent
  full-resolution scarf views; both runtime exports are 66×58.
- `amulet_storybook_v1.png` is the full-resolution transparent necklace source;
  `amulet_storybook.png` is its 48×38 front-only runtime export.
- `goggles_storybook_v1.png` and `goggles_storybook_back_v1.png` are the
  full-resolution chroma-key sources. Their 56×18 front and 56×10 rear exports
  separate the twin aqua lenses from the climbing-view leather strap.

The built-in image generator used both lineage paintings plus the authored
cloth, crown, lantern, hood, and human-head references. The scarf prompts
requested matching front/rear deep-blue stitched wraps with a transparent neck
opening and short right-side tail. The amulet prompt requested a shallow bronze
chain with leather tabs and one small blue teardrop pendant. The goggles prompts
requested compact bronze-rimmed aqua lenses for the front and only their
stitched leather adjustment strap from the rear.

An attempted alpha-cleanup edit of the goggles returned a baked checkerboard
and was rejected. The accepted goggles therefore use the proven magenta-field
workflow and an item-scoped key shader; switching to the genuine-alpha scarf or
amulet clears that material immediately. Climbing swaps scarf and goggles to
their rear views and occludes the front-hanging amulet entirely.

## Articulated pants

- `cloth_pants_storybook_v1.png`, `leather_pants_storybook_v1.png`, and
  `plate_pants_storybook_v1.png` are the full-resolution chroma-key production
  sheets. Each sheet contains exactly one waist, thigh, and shin component in
  isolated top/middle/bottom thirds.
- The nine runtime exports use one shared contract per body segment: every
  `*_pants_waist_storybook.png` is 56×26, every thigh is 24×40, and every shin
  is 20×36.

The built-in image generator used both lineage paintings plus the corresponding
authored cloth, leather, or plate equipment as material references. Each prompt
requested one coherent three-component kit on a uniform magenta field: a wide
waist yoke with five split tabs, one reusable open thigh sleeve/guard, and one
reusable open shin wrap/gaiter/greave. The prompts explicitly excluded anatomy,
mannequins, paired legs, connected trousers, feet, boots, labels, shadows,
checkerboards, scenery, and watermarks.

`ModularCharacter` still attaches independent copies to the waist, both thighs,
and both shins. `GearVisual` scales authored limb textures only along each
race's bone length, so knees remain independently articulated throughout run,
idle, attack, gesture, and climb motion. All three material kits use the scoped
magenta key and clear it when the pants slot is empty.

The selectable `baggy` cut reuses the authored cloth kit instead of introducing
a second visual language. It applies a fixed charcoal dye matching the Fae
reference, widens the painted thigh sleeve from 21 to 30 runtime pixels, and
narrows the wrapped shin from 18 to 16 pixels. This creates the reference's
balloon-trouser-to-wrapped-calf taper while retaining the same five modular
waist/thigh/shin attachments and fully articulated knees.

The selectable `ranger` cut also reuses the cloth kit, but retains the standard
21-pixel thigh and 18-pixel shin widths. Its fixed olive-green dye matches the
Human travel trousers in `designs/references/light-lineages.png`; unlike lineage-dyed `cloth`, it
keeps that forest palette when equipped by any race while preserving the same
five articulated waist/thigh/shin attachments.

Future equipment should follow the same contract: retain a high-resolution
source, export a tightly trimmed runtime sprite, align its actual grip with the
socket origin, and preserve the semantic reach points used by animation and
effects.

## Footwear

- `footwear_storybook_v1.png` is the full-resolution, true-alpha production
  atlas generated in one pass for consistent scale and side-view orientation.
- `wraps_boot_storybook.png`, `leather_boot_storybook.png`, and
  `plate_boot_storybook.png` are 40×42 true-alpha runtime exports.

The built-in image generator was prompted for exactly three detached single
footwear pieces: linen wraps, a strapped leather travel boot, and an articulated
steel sabaton. All face screen-right with the cuff at upper-left and toe on +X;
characters, anatomy, paired boots, shadows, labels, and scenery were excluded.
`ModularCharacter` mounts one copy at each biped ankle, above the shin garment,
and hides the underlying bare-foot sprite while the slot is non-empty. Centaurs
reject the slot and retain their four lineage-specific hooves.

## Weapon projectiles

- `arrow_projectile_storybook_v1.png` and
  `crossbow_bolt_storybook_v1.png` and
  `spell_projectile_storybook_v1.png` preserve the full-resolution,
  true-alpha generated sources.
- `arrow_projectile_storybook.png` is the 80×18 runtime arrow;
  `crossbow_bolt_storybook.png` is the 64×20 runtime bolt;
  `spell_projectile_storybook.png` is the 44×44 runtime crystal-energy orb.

The built-in image generator used the authored bow or staff plus both lineage
paintings as style references. The arrow prompt required one horizontal
left-to-right wood, feather, bronze, and steel projectile. The spell prompt
required one compact blue-white crystalline orb with a painted energy ring.
Both excluded characters, weapons, scenery, labels, frames, shadows, and baked
backgrounds. Runtime flight, mirroring, rotation, recoil, scale, and fading stay
procedural, while the visible projectile cores now share the authored storybook
materials used by the equipment and base sprites.

The hand bow also uses `arrow_projectile_storybook.png` while the string is
drawn. Its painted shaft, fletching, collar, and point stretch only between the
animated nock and the fixed forward tip socket; release transfers to the same
texture as a flying `Sprite2D`. This removes the earlier procedural beige line
and flat triangle without sacrificing continuous string tracking.

Centaur's lineage-specific Gallop Shot reuses that draw state. Its anticipation
pulls the string and painted nocked arrow while all four equine legs enter the
gallop brace; the impact callback snaps the string home and spawns the named
flying-arrow effect. Recovery or locomotion interruption also guarantees a
relaxed string rather than retaining a stale partial draw.

The bolt used the authored Goblin crossbow, arrow, and dark-lineage painting as
references. Its prompt requested exactly one compact screen-right projectile:
a short warm-brown hardwood shaft, cream split vanes, dark iron collar, and
steel bodkin on true transparency, with no weapon, hand, scenery, text, or
additional object. Fire Crossbow and Goblin's Snap Shot share this bolt rather
than scaling the longbow arrow into a stand-in.

The same bolt is visibly seated along the crossbow's guide rail during rest,
locomotion, and its complete sighting beat. The rail copy disappears in the
same callback that spawns `FiredBolt`, remains absent through recoil, and is
restored after recovery or an interrupted action. A single authored asset now
carries the load, release, flight, and Snap Shot semantics.

Goblin's lineage-specific Snap Shot follows the same state transition: its rail
unloads in the exact impact callback that spawns the named bolt effect, then
reloads after gesture recovery or locomotion interruption. The unique action
therefore cannot display a seated and flying bolt simultaneously.
