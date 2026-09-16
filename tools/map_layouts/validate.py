#!/usr/bin/env python3
"""Check source coverage, editable SVGs and the actual supported traversal graph."""
from pathlib import Path
import xml.etree.ElementTree as ET
import json,re,collections
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'designs/map-layouts'
data=json.loads((OUT/'manifest.json').read_text());errors=[]
def check(ok,msg):
 if not ok:errors.append(msg)
source=(ROOT/'docs/game/0022-world-map-level-plan.md').read_text()
byid={m['id']:m for m in data['maps']}
check(len(byid)==80,'expected 80 unique detail maps')
for region,heading,end,total in [('open_lands','Open Lands','Tidekin Sea',41),('tidekin_sea','Tidekin Sea','Elder Forests',39)]:
 sec=source.split('### '+heading+'\n')[1].split('### '+end+'\n')[0]
 expected=set(re.findall(r'^\| `([^`]+)` \|',sec,re.M));actual={m['id'] for m in data['maps'] if m['region']==region}
 check(actual==expected,f'{region}: source inventory mismatch {actual^expected}')
 check(len(actual)==total,f'{region}: count mismatch')
 check({p.stem for p in (OUT/region).glob('*.svg')}==actual,f'{region}: delivered SVGs differ from manifest')
 signatures=set()
 for m in (m for m in data['maps'] if m['region']==region):
  id_=m['id'];file=OUT/region/(id_+'.svg');root=ET.parse(file).getroot()
  ids=[n.get('id') for n in root.iter() if n.get('id')];check(len(set(ids))==len(ids),id_+': duplicate SVG ID')
  check(not any(n.tag.endswith('image') for n in root.iter()),id_+': raster image in editable SVG')
  for n in root.iter():
   ref=n.get('href')
   if ref and ref.startswith('#'):check(ref[1:] in ids,id_+': missing symbol '+ref)
   check(not (ref and ref.startswith(('http:','https:','data:'))),id_+': external reference')
  signature=tuple((a['x'],a['y'],a['w']) for a in m['platforms']);check(signature not in signatures,id_+': duplicate geometry');signatures.add(signature)
  surfaces={a['id']:a for a in m['platforms']};surfaces['street']={'x':70,'y':1100,'w':2460}
  reachable={'street'}
  for _ in range(len(surfaces)):
   for c in m['climbs']:
    check(c['type'] in ['stairs','ladder','rope'],id_+': unsupported connector')
    a,b=surfaces[c['from']],surfaces[c['to']]
    check(a['x']<=c['x']<=a['x']+a['w'] and b['x']<=c['x']<=b['x']+b['w'],id_+': climb has unsupported endpoint')
    check(a['x']<=c['bottom_x']<=a['x']+a['w'],id_+': unsupported stair foot')
    check(c['y1']==b['y'] and c['y2']==a['y'],id_+': climb does not meet its landings')
    if c['from'] in reachable:reachable.add(c['to'])
  check(reachable==set(surfaces),id_+': unreachable landing')
  check(set(c['type'] for c in m['climbs'])=={'stairs','ladder','rope'},id_+': missing traversal type')
  check(len(m['objects'])>=18 and sum(o['jumpable'] for o in m['objects'])>=3,id_+': insufficient jumpable scenery')
  for o in m['objects']:
   a=surfaces[o['surface']]
   check(a['x']<=o['x'] and o['x']+o['w']<=a['x']+a['w'],id_+': prop outside supporting surface')
   check(o['y']>=195 and o['y']+o['h']<=1190,id_+': prop clipped by scene')
  check({p['to'] for p in m['portals']}==set(m['neighbors']),id_+': exit mismatch')
  for port in m['portals']:
   check(port['support'] in reachable,id_+': unreachable exit')
   check(id_ in byid[port['to']]['neighbors'],id_+': non-reciprocal connection')
  check(m['recovery_position']['support'] in reachable,id_+': missing recovery')
check(len(data['overviews'])==4,'four overview SVGs required')
for ov in data['overviews']:
 expected={m['id'] for m in data['maps'] if m['region']==ov['region'] and (ov['type']=='region' or m['group']!='wilds')}
 check(set(ov['nodes'])==expected,ov['file']+': overview missing maps')
 root=ET.parse(OUT/ov['file']).getroot();links={n.get('href') for n in root.iter() if n.tag.endswith('a')}
 check(links=={ov['region']+'/'+n+'.svg' for n in expected},ov['file']+': broken map links')
 expected_edges={tuple(e) for e in byid[next(iter(expected))]['edges'] if all(n in expected for n in e)}
 check({tuple(e) for e in ov['edges']}==expected_edges,ov['file']+': omitted portal connection')
if errors:
 print('\n'.join('FAIL: '+e for e in sorted(set(errors))));raise SystemExit(1)
print('PASS: 80 source-matched native SVG layouts; unique geometry; supported stair/ladder/rope routes; jumpable props; reciprocal exits; all four linked overviews')
(OUT/'validation.json').write_text(json.dumps({'status':'pass','maps':80,'overview_maps':4,'regions':{'open_lands':41,'tidekin_sea':39},'checks':['source coverage','standalone native SVG references','unique platform geometry','supported climb endpoints','route to every landing and exit','jumpable scenery','unclipped prop bounds','reciprocal portal destinations','complete overview links and edges']},indent=2)+'\n')
