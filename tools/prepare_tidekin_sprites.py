"""Remove the generated checkerboard; preserve source and export individual RGBA sprites.

Run with: uv run --with pillow --with numpy --with scipy python tools/prepare_tidekin_sprites.py
Local image processing explicitly approved by the user after two RGB generation results.
"""
from pathlib import Path
import json
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/monsters/tidekin'
source = Image.open(OUT / 'creatures-source.png').convert('RGB')
rgb = np.asarray(source).astype(np.float32)
lo, hi = rgb.min(axis=2), rgb.max(axis=2)
# The baked checkerboard has a near-neutral violet cast, with squares near 165/219.
neutral = (hi-lo < 15) & (lo > 118) & (hi < 239)
labels, count = ndi.label(neutral, structure=np.ones((3,3)))
background = np.zeros(neutral.shape, dtype=bool)
for index, slices in enumerate(ndi.find_objects(labels), 1):
    if slices is None: continue
    region = labels[slices] == index
    values = rgb[slices][region].mean(axis=1)
    edge = slices[0].start == 0 or slices[1].start == 0 or slices[0].stop == rgb.shape[0] or slices[1].stop == rgb.shape[1]
    # Remove enclosed checkerboard gaps too, but keep single-tone shell highlights.
    checker = len(values) > 20 and np.count_nonzero(values < 180) > 5 and np.count_nonzero(values > 200) > 5
    if edge or checker: background[slices] |= region
alpha = (~background).astype(np.uint8)*255
# Remove tiny isolated remnants in empty space, without shrinking the main silhouettes.
objects, count = ndi.label(alpha > 0, structure=np.ones((3,3)))
sizes = np.bincount(objects.ravel())
alpha[sizes[objects] < 9] = 0
rgba = np.dstack([rgb.astype(np.uint8),alpha])
rgba[alpha == 0,:3] = 0
clean = Image.fromarray(rgba)
clean.save(OUT/'creatures.png')
manifest_path = OUT/'manifest.json'
manifest = json.loads(manifest_path.read_text())
# Source art is not a mathematically exact grid. These cell boundaries preserve
# the Snapper's jaw and the Confluence Eel's tail without including neighbors.
columns = [[0,313,636,932,1254],[0,311,646,935,1254],[0,313,630,936,1254],[0,322,616,939,1254]]
rows = [0,315,608,884,1254]
preview = Image.new('RGB',(1200,1200),'#193e49')
for item in manifest['creatures']:
    col,row = item['column'],item['row']
    bounds = (columns[row][col],rows[row],columns[row][col+1],rows[row+1])
    sprite = clean.crop(bounds)
    pixels = np.array(sprite)
    components, _ = ndi.label(pixels[:,:,3] > 0, structure=np.ones((3,3)))
    counts = np.bincount(components.ravel()); counts[0] = 0
    largest = counts.argmax()
    # Remove neighboring-cell slivers and tiny residual checker fragments.
    keep = counts[components] >= max(20, counts[largest]*.006)
    for component, box in enumerate(ndi.find_objects(components), 1):
        if box is None or component == largest: continue
        height, width = box[0].stop-box[0].start, box[1].stop-box[1].start
        touches_side = box[1].start <= 2 or box[1].stop >= pixels.shape[1]-2
        if touches_side and width < 12 and height > width*3:
            keep[components == component] = False
    pixels[~keep] = 0
    distance = ndi.distance_transform_edt(keep)
    interior = distance >= 2
    if interior.any():
        nearest = ndi.distance_transform_edt(~interior, return_distances=False, return_indices=True)
        edge = keep & (distance < 2)
        pixels[edge,:3] = pixels[nearest[0][edge],nearest[1][edge],:3]
        pixels[edge,3] = 180
    sprite = Image.fromarray(pixels)
    bbox = sprite.getchannel('A').getbbox()
    assert bbox, item['id']
    sprite = sprite.crop(bbox)
    padded = Image.new('RGBA',(sprite.width+16,sprite.height+16))
    padded.alpha_composite(sprite,(8,8))
    if item['id'] == 'floodhall_lanternfish':
        # The generator tinted its checkerboard inside the lantern's glow.
        # Preserve the painted lamp; replace only its outer halo with soft alpha.
        glow = np.array(padded)
        yy, xx = np.indices(glow.shape[:2])
        radius = np.hypot(xx-(padded.width-37), yy-62)
        halo = (xx >= padded.width-75) & (yy >= 30) & (yy <= 100) & (radius > 21) & (glow[:,:,:3].min(axis=2) > 90)
        glow[halo,:3] = [255,208,110]
        glow[halo,3] = np.minimum(glow[halo,3],np.clip((29-radius[halo])/8,0,1)*150).astype(np.uint8)
        glow[glow[:,:,3] == 0,:3] = 0
        padded = Image.fromarray(glow)
    filename = item['id']+'.png'
    padded.save(OUT/filename)
    item['file'] = 'assets/monsters/tidekin/'+filename
    item['source_rect'] = list(bounds)
    item['pivot'] = [0.5,1.0] if item['id'] not in ['ripplefin_sprout','shellbell_nymph','floodhall_lanternfish','reefsong_whalelet','tidal_gate_eel','riptide_coil','confluence_eel'] else [0.5,0.5]
    item['animation'] = 'single pose; runtime transforms only for playable creatures'
    alpha_values = np.asarray(padded.getchannel('A'))
    assert alpha_values.min() == 0 and alpha_values.max() == 255
    thumb = padded.copy(); thumb.thumbnail((270,245))
    preview.paste(thumb,(col*300+(300-thumb.width)//2,row*300+10+(245-thumb.height)//2),thumb)
    ImageDraw.Draw(preview).text((col*300+12,row*300+272),item['name'],fill='#fff1cd')
manifest['sprite_sheet']['file'] = 'assets/monsters/tidekin/creatures.png'
manifest['sprite_sheet']['source_file'] = 'assets/monsters/tidekin/creatures-source.png'
manifest['sprite_sheet']['status'] = 'RGBA export; individually trimmed sprites; static poses'
manifest['sprite_sheet']['cleanup'] = 'User-approved local checkerboard removal; tools/prepare_tidekin_sprites.py'
manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
preview.save('/tmp/tidekin-sprite-preview.png')
print('Exported 16 transparent creature PNGs and RGBA sheet; original preserved.')
