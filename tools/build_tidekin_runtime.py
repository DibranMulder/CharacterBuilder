#!/usr/bin/env python3
"""Compile reviewed Tidekin SVG geometry into game data and retained scenery.

Reads the authored manifest without modifying it. Geometry and artwork use the
same coordinate transform, with the shared combat floor remaining at y=480.
"""
import json
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools/map_layouts'))
from tidekin import FEATURES, P, tide_symbols, deck, structure, boat, overview_icon
from build import tag, use, connector, rect, path as svg_path, txt


def build():
    manifest = json.loads((ROOT/'designs/map-layouts/manifest.json').read_text())
    path = ROOT/'prototypes/tidekin_sea/region.json'
    data = json.loads(path.read_text())
    authored = {m['id']: m for m in manifest['maps'] if m['region']=='tidekin_sea'}
    out = ROOT/'assets/maps/tidekin/layouts'
    out.mkdir(exist_ok=True)
    for entry in data['maps']:
        d = authored[entry['id']]
        w, h = d['viewBox'][2:]
        ground = d['floor']['y']
        sx, sy = entry['width']/w, .9
        point = lambda x,y: [round(x*sx,3),round(480+(y-ground)*sy,3)]
        entry['layout_source'] = 'designs/map-layouts/tidekin_sea/'+entry['id']+'.svg'
        entry['floor_rect'] = point(d['floor']['x'],ground)+[round(d['floor']['w']*sx,3),18]
        entry['layout_origin'] = point(0,195)
        entry['layout_size'] = [entry['width'],round((ground+180-195)*sy,3)]
        entry['landmark'] = d['landmark']
        entry['platforms'] = [point(a['x'],a['y'])+[round(a['w']*sx,3),18] for a in d['platforms']]
        entry['climbs'] = [{**c,'top':point(c['x'],c['y1']),'bottom':point(c['bottom_x'],c['y2'])} for c in d['climbs']]
        entry['objects'] = [{**o,'rect':point(o['x'],o['y'])+[round(o['w']*sx,3),round(o['h']*sy,3)]} for o in d['objects']]
        # Tops follow the actual furniture silhouettes in tide_symbols().
        tops = {'sea-crate':.28,'sea-basket':.44,'sea-seat':.5,'sea-chest':.2,'sea-table':.48,'sea-scrolls':.08,'sea-shell':.18}
        for obj in entry['objects']:
            if obj['jumpable']:
                x,y,ow,oh=obj['rect']
                entry['platforms'].append([round(x+ow*.1,3),round(y+oh*tops[obj['type']],3),round(ow*.8,3),12])
        entry['portals'] = [{**p,'point':point(p['x'],p['y'])} for p in d['portals']]
        entry['neighbors'] = [p['to'] for p in entry['portals']]
        entry['recovery_point'] = point(d['recovery_position']['x'],ground)
        # Water-care stations occupy authored upper landings, reached by climbs.
        chosen = sorted(d['platforms'],key=lambda a:a['y'],reverse=True)[:3]
        entry['fixture_points'] = [point(a['x']+a['w']*.5,a['y']) for a in chosen]
        biome, features, _ = FEATURES[d['short']]
        reef = biome in ['reef','shoals','ancient','blackwater','shrine']
        floor = d['floor']
        world = deck(floor,ground,layer='supports')
        for a in d['platforms']: world += deck(a,ground,'reef' if reef else 'dock',layer='supports')
        factor=(w-140)/2460
        candidates=sorted((a for a in d['platforms'] if a['w']>200*factor and a['y']>430),key=lambda a:a['w'],reverse=True)
        for j,kind in enumerate(features):
            a=candidates[j%len(candidates)]
            ww=min(a['w']-35,620*factor); hh=min(340 if biome=='shrine' else 300,a['y']-220)
            x=a['x']+(a['w']-ww)/2; y=a['y']
            if kind=='vortex': x,y,ww,hh=w*.31,ground-85,w*.42,320
            world += structure(kind,x,y,ww,hh)
        if biome in ['wharf','lagoon','shore']: world+=boat(w*.37,ground-105,360*factor)
        # Painted retained atlas stamps supply the collision-aligned deck tops and props.
        for j,a in enumerate(d['platforms']):
            below=[b for b in d['platforms']+[floor] if b['y']>a['y'] and min(a['x']+a['w'],b['x']+b['w'])-max(a['x'],b['x'])>65]
            world+=connector(a,min(below,key=lambda b:b['y']),j,P)[0]

        # Retain native geometry while giving timber, stone and canvas depth.
        gradients = ''
        for key, light, dark in [('wood','#ae8e64','#534b3e'),('stone','#c3d2af','#63877e'),('cloth','#4799a2','#23535f')]:
            name='material-'+key
            gradients += tag('linearGradient',tag('stop',offset='0%',stop_color=light)+tag('stop',offset='100%',stop_color=dark),id=name,x2='0',y2='1')
            world=world.replace('fill="'+P[key]+'"','fill="url(#'+name+')"')
        svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{ground+180-195}" viewBox="0 195 {w} {ground+180-195}">'+tag('defs',tide_symbols()+gradients)+world+'</svg>'
        (out/(entry['id']+'.svg')).write_text(svg)
    path.write_text(json.dumps(data,indent=2)+'\n')
    overview = next(o for o in manifest['overviews'] if o['file']=='tidekin_sea_region.svg')
    positions_path = ROOT/'src/world/region_layouts.json'
    positions = json.loads(positions_path.read_text())
    positions['tidekin_sea'] = {key:[round(at[0]/3000,6),round(at[1]/2500,6)] for key,at in overview['positions'].items()}
    positions_path.write_text(json.dumps(positions,indent=2)+'\n')
    # Background shares the SVG atlas geography; labels, fog and travel controls
    # remain retained, interactive game UI rather than baked into this picture.
    chart = rect(0,0,3000,2500,'#183f49')
    for x,y,ww,hh in [(50,220,1180,1820),(1280,220,1670,1350),(1280,1640,1670,620)]:
        chart+=rect(x,y,ww,hh,'#387c85','#7db6a7',3,90)
    for y in range(150,2400,155):
        for x in range(65,2920,300):
            chart+=svg_path(f'M{x} {y}q55-12 110 0',stroke='#97ccbb',sw=2,opacity='.2')
    for key,at in overview['positions'].items():
        chart+=overview_icon(at[0],at[1],authored[key],P,.75)
    chart+=txt(145,330,'TIDEWHARF · CITADEL · SHRINE',32,'#e8d7ad')
    chart+=txt(1370,330,'STARTER COAST · 1–40',32,'#e8d7ad')
    chart+=txt(1370,1740,'RETURN JOURNEYS · 61–120',32,'#e8d7ad')
    (out/'atlas.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="2400" height="1600" viewBox="0 0 3000 2500" preserveAspectRatio="none">'+tag('defs',tide_symbols())+chart+'</svg>')
    print('Compiled 39 Tidekin maps: authored landings, props, climbs, portals and scenery.')

if __name__ == '__main__': build()
