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
  if region=='tidekin_sea':
   check(m.get('moodboard')=='designs/moodboards/tidekin.png',id_+': missing moodboard provenance')
   check(any(n.get('data-architecture')=='sea-built' for n in root.iter()),id_+': missing sea-built composition')
   drawn_features={n.get('data-feature') for n in root.iter() if n.get('data-feature')}
   check(set(m.get('visual_features',[]))<=drawn_features and len(m.get('visual_features',[]))==3,id_+': missing major landmark')
   check(all(o['type'].startswith('sea-') for o in m['objects']),id_+': non-Tidekin furniture kit')
   check(all(n.get('data-lineage')=='Tidekin' for n in root.iter() if n.get('data-npc')),id_+': resident silhouette mismatch')
   check(any(n.get('data-material')=='rope-lashed-piled-dock' for n in root.iter()),id_+': missing water-supported public route')
  signature=tuple((a['x'],a['y'],a['w']) for a in m['platforms']);check(signature not in signatures,id_+': duplicate geometry');signatures.add(signature)
  surfaces={a['id']:a for a in m['platforms']};surfaces['street']=m.get('floor',{'x':70,'y':1100,'w':2460})
  reachable={'street'}
  for _ in range(len(surfaces)):
   for c in m['climbs']:
    check(c['type'] in ['stairs','ladder','rope'],id_+': unsupported connector')
    a,b=surfaces[c['from']],surfaces[c['to']]
    check(b['x']<=c['x']<=b['x']+b['w'],id_+': climb has unsupported endpoint')
    check(a['x']<=c['bottom_x']<=a['x']+a['w'],id_+': unsupported stair foot')
    check(c['y1']==b['y'] and c['y2']==a['y'],id_+': climb does not meet its landings')
    if c['from'] in reachable:reachable.add(c['to'])
  check(reachable==set(surfaces),id_+': unreachable landing')
  check(set(c['type'] for c in m['climbs'])=={'stairs','ladder','rope'},id_+': missing traversal type')
  check(len(m['objects'])>=18 and sum(o['jumpable'] for o in m['objects'])>=3,id_+': insufficient jumpable scenery')
  for o in m['objects']:
   a=surfaces[o['surface']]
   check(a['x']<=o['x'] and o['x']+o['w']<=a['x']+a['w'],id_+': prop outside supporting surface')
   bounds=m.get('scene_bounds',[40,195,2520,995])
   check(o['y']>=bounds[1] and o['y']+o['h']<=bounds[1]+bounds[3],id_+': prop clipped by scene')
  check({p['to'] for p in m['portals']}==set(m['neighbors']),id_+': exit mismatch')
  for port in m['portals']:
   check(port['support'] in reachable,id_+': unreachable exit')
   support=surfaces[port['support']]
   check(support['x']<=port['x']<=support['x']+support['w'] and port['y']==support['y'],id_+': exit off supporting surface')
   check(id_ in byid[port['to']]['neighbors'],id_+': non-reciprocal connection')
  check(m['recovery_position']['support'] in reachable,id_+': missing recovery')
# These three maps must express vertical progression, not a stretched landscape sheet.
for id_ in ['tower','stair','solar']:
 m=byid[id_];check(m['viewBox'][3]>m['viewBox'][2],id_+': expected portrait canvas')
 check(m.get('layout')=='vertical tower interior',id_+': expected enclosed interior')
 check(max(a['y'] for a in m['platforms'])-min(a['y'] for a in m['platforms'])>900,id_+': insufficient vertical progression')
 stairs_reachable={'street'}
 for _ in m['platforms']:
  for c in m['climbs']:
   if c['type']=='stairs' and c['from'] in stairs_reachable:stairs_reachable.add(c['to'])
 check(stairs_reachable=={'street'}|{a['id'] for a in m['platforms']},id_+': interrupted main stair route')
 if id_!='solar':
  destination='stair' if id_=='tower' else 'solar'
  exit_=next(p for p in m['portals'] if p['to']==destination)
  check(exit_['y']==min(a['y'] for a in m['platforms']),id_+': onward exit must be at top')
check(len(data['overviews'])==4,'four overview SVGs required')
for ov in data['overviews']:
 expected={m['id'] for m in data['maps'] if m['region']==ov['region'] and (ov['type']=='region' or m['group']!='wilds')}
 check(set(ov['nodes'])==expected,ov['file']+': overview missing maps')
 root=ET.parse(OUT/ov['file']).getroot();links={n.get('href') for n in root.iter() if n.tag.endswith('a')}
 check(links=={ov['region']+'/'+n+'.svg' for n in expected},ov['file']+': broken map links')
 if ov['region']=='tidekin_sea':check(sum(n.get('data-tidekin-icon') is not None for n in root.iter())==len(expected),ov['file']+': missing sea-built overview icons')
 expected_edges={tuple(e) for e in byid[next(iter(expected))]['edges'] if all(n in expected for n in e)}
 check({tuple(e) for e in ov['edges']}==expected_edges,ov['file']+': omitted portal connection')
if errors:
 print('\n'.join('FAIL: '+e for e in sorted(set(errors))));raise SystemExit(1)
print('PASS: 80 source-matched native SVG layouts; unique geometry; supported stair/ladder/rope routes; jumpable props; reciprocal exits; all four linked overviews')
(OUT/'validation.json').write_text(json.dumps({'status':'pass','maps':80,'overview_maps':4,'regions':{'open_lands':41,'tidekin_sea':39},'checks':['source coverage','standalone native SVG references','unique platform geometry','supported climb endpoints','route to every landing and exit','jumpable scenery','unclipped prop bounds','reciprocal portal destinations','complete overview links and edges','Tidekin moodboard, landmarks, sea-built decks and resident silhouettes']},indent=2)+'\n')
