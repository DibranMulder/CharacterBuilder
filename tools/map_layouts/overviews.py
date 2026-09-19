"""Illustrated hometown cartography and complete region progression maps."""
import json,math,textwrap
from build import *
from tidekin import overview_icon, tide_symbols, P as SEA_PALETTE
TOWN_POS={
'open_lands':{'square':(430,1060),'market':(310,620),'apothecary':(700,760),'trainers':(730,1390),'inn':(350,1550),'approach':(1020,1030),'gatehouse':(1400,900),'barracks':(1430,560),'service':(1280,1310),'hall':(1800,700),'king':(2170,510),'archive':(2180,900),'tower':(1710,1500),'stair':(2050,1390),'solar':(2380,1240)},
'tidekin_sea':{'land':(300,1210),'cm':(330,460),'lag':(770,840),'ka':(380,820),'dy':(820,1350),'inn':(1220,1510),'caus':(1220,820),'gs':(1570,680),'rb':(1380,360),'cw':(1830,350),'ph':(1960,710),'tc':(2310,420),'dv':(2350,860),'sc':(1930,1030),'fn':(2210,1230),'cr':(1960,1450),'ps':(2300,1630)}}

def icon(x,y,d,p,scale=1):
 if d['region']=='tidekin_sea':return overview_icon(x,y,d,p,scale)
 shape=d['shape'];k='shell' if d['region']=='tidekin_sea' else 'house'
 if shape=='roofstreet':
  s=house(-105,-73,92,70,p,'shop')+house(-24,-103,100,100,p,'shop')+house(62,-63,70,60,p,'shop')+use('crate',-24,-37,40,40)
 elif shape=='crossroads':
  s=rect(-75,-125,55,125,p['stone'],p['ink'],3)+path('M-85-125L-48-162L-12-125Z',p['cloth'],p['ink'],3)+ellipse(-48,-104,17,17,p['paper'],p['ink'],2)+path('M-48-116V-104L-39-98',stroke=p['ink'],sw=2)+use('well',-9,-85,105,90)
 elif shape=='harbor':
  s=rect(-110,-14,230,14,p['wood'],p['ink'],2)+house(-20,-108,100,98,p,k)+use('boat',-116,-98,120,106)+use('winch',75,-115,63,108)
 elif shape=='basin':
  s=ellipse(0,-27,109,30,p['stone'],p['ink'],3)+ellipse(0,-30,81,19,p['water'],p['ink'],2)+use('gauge',-34,-156,65,139)+use('boat',65,-70,68,64)
 elif shape=='courts':
  s=ellipse(0,-20,104,35,p['top'],p['ink'],3)+use('target',-85,-113,83,100)+use('dummy',13,-92,75,85)+use('banner',75,-135,61,128)
 elif shape=='terraces':
  s=''.join(rect(-105+j*43,-25-j*26,140,25,p['stone'],p['ink'],2)+use('planter',-100+j*43,-70-j*26,65,49) for j in range(3))+house(21,-114,90,68,p,k)
 elif shape=='observatory':
  s=rect(-72,-82,144,80,p['stone'],p['ink'],3)+path('M-85-82Q0-191 85-82Z',p['cloth'],p['ink'],3)+use('telescope',-20,-163,105,85)+ellipse(0,-44,28,29,p['water'],p['ink'],3)
 elif shape=='hall':
  s=rect(-101,-93,202,90,p['stone'],p['ink'],3)+path('M-112-93L0-158L112-93Z',p['cloth'],p['ink'],3)
  for xx in [-81,-41,32,72]:s+=rect(xx,-82,12,80,p['top'],p['ink'],2)
  s+=use('orb' if d['region']=='tidekin_sea' else 'throne',-31,-76,63,75)
 elif shape=='stacks':
  s=rect(-95,-93,190,90,p['stone'],p['ink'],3)+use('shelf',-78,-120,81,105)+use('chest',11,-93,81,86)+path('M-107-93L0-147L107-93',stroke=p['cloth'],sw=12)
 elif shape=='workshops':
  s=house(-85,-77,170,74,p,k)+use('forge' if d['region']=='open_lands' else 'valve',-48,-143,97,137)+use('waterwheel',69,-69,80,78)
 elif shape=='descent':
  s=path('M-104-125h60v30h60v30h60v30h58v30',stroke=p['stone'],sw=24)+path('M-104-141L134-19',stroke=p['wood'],sw=5)+use('lantern',-78,-151,50,56)
 elif shape=='interior':
  s=house(-92,-100,184,97,p,k)+use('banner' if d['short'] in ['rb','barracks'] else 'chimney',62,-159,65,137)+use('bed' if d['short'] in ['rb','barracks'] else 'table',-46,-54,93,55)
 elif shape in ['gate','wall','tower','switchback']:
  s=rect(-48,-105,96,104,p['stone'],p['ink'],3,8)+path('M-58-104L0-155L58-104Z',p['cloth'],p['ink'],3)+rect(-12,-53,24,48,p['wood'],p['ink'],2,12)
  for xx in [-38,20]:s+=rect(xx,-93,19,30,p['water'],p['ink'],2,7)
  if shape=='gate':s+=use('statue',-105,-74,64,78)+use('statue',46,-74,64,78)
 elif shape in ['monuments','convergence']:s=use('orb' if d['region']=='tidekin_sea' else 'statue',-60,-130,120,130)
 elif d['group']=='wilds':s=use('coral' if d['region']=='tidekin_sea' else 'tree',-60,-125,120,120)+use(d['props'][0],30,-71,68,68)
 else:s=house(-80,-95,160,90,p,k)
 return tag('g',s,transform=f'translate({x} {y}) scale({scale})')

def svg_open(title,w,h):return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img">'+tag('title',ESC(title))
def label_block(x,y,name,p,size=22,maxwidth=24):
 lines=textwrap.wrap(name,maxwidth)
 w=max(len(q) for q in lines)*size*.56+28
 s=rect(x-w/2,y-21,w,len(lines)*(size+5)+12,p['paper'],p['dark'],1,8,opacity='.96')
 for j,q in enumerate(lines):s+=txt(x,y+j*(size+5),q,size,p['ink'],text_anchor='middle')
 return s

def background(region,w,h,p):
 s=rect(0,0,w,h,p['paper'])+rect(35,190,w-70,h-390,p['sky'],None,rx=28)
 if region=='tidekin_sea':
  s+=rect(50,205,w-100,h-420,p['water'],None,rx=45)
  for yy in range(300,h-250,145):
   for xx in range(100+(yy%130),w-180,280):s+=path(f'M{xx} {yy}q55-13 115 0',stroke=p['paper'],sw=3,opacity='.3')
  s+=ellipse(760,940,435,400,p['cloth'],p['far'],4,opacity='.45')
  for j in range(3):s+=ellipse(760,940,330-j*75,285-j*65,'none',p['paper'],3,opacity='.35')
  for x,y in [(1500,1500),(1690,1670),(2250,1350)]:s+=use('sea-shell',x,y,95,130)
 else:
  s+=path(f'M70 530Q530 140 920 380Q1180 190 1530 310Q2150 80 {w-70} 410V{h-270}H70Z',p['mist'],p['far'],4)
  s+=path(f'M55 1620Q760 1690 1020 1270T{w-50} 1430',stroke=p['water'],sw=78)
  for x,y in [(120,970),(750,420),(980,1440),(1500,280),(2370,1200)]:s+=use('tree',x,y,145,170)
  for x,y in [(100,1340),(540,1600),(1080,600)]:
   for j in range(4):s+=path(f'M{x} {y+j*25}q160-40 260 0',stroke=p['top'],sw=14)
 return s

def town(region,maps):
 p=SEA_PALETTE if region=='tidekin_sea' else PAL[region];w,h=2600,1950
 title='Tidewharf · Pearl Citadel · Sunken Shrine' if region=='tidekin_sea' else 'Wendmere · King’s Keep · Princess’s Tower'
 nodes=[d for d in maps if d['region']==region and d['group']!='wilds']
 positions={d['id']:TOWN_POS[region][d['short']] for d in nodes}
 s=svg_open(title,w,h)+tag('defs',props(p)+(tide_symbols() if region=='tidekin_sea' else ''))+background(region,w,h,p)
 s+=txt(64,67,'HOMETOWN / ILLUSTRATED REGION PLAN',19,p['cloth'],letter_spacing=4)+txt(64,130,title,43,p['ink'],'Georgia, serif')
 s+=txt(2500,75,f'{len(nodes)} MAPS',27,p['ink'],text_anchor='end')
 groups={'village':('TIDEWHARF' if region=='tidekin_sea' else 'WENDMERE',260,290),'stronghold':('PEARL CITADEL' if region=='tidekin_sea' else 'THE KING’S KEEP',1430,245),'story':('THE SUNKEN SHRINE' if region=='tidekin_sea' else 'THE PRINCESS’S TOWER',1800,1800)}
 for group,(name,x,y) in groups.items():s+=txt(x,y,name,23,p['dark'],letter_spacing=4)
 # Portal links follow the authored graph, including reciprocal leaf returns.
 edges=[e for e in nodes[0]['edges'] if all(n in positions for n in e)]
 for a,b in edges:
  x,y=positions[a];xx,yy=positions[b]
  gate=any(q.endswith('caus') or q=='approach' for q in [a,b]) and any(q.endswith('_gs') or q=='gatehouse' for q in [a,b])
  col=p['accent'] if gate else p['paper']
  d=f'M{x} {y}Q{(x+xx)/2+35} {(y+yy)/2-22} {xx} {yy}'
  s+=path(d,stroke=p['dark'],sw=17,opacity='.45')+path(d,stroke=col,sw=11)
  s+=path(d,stroke=p['wood'],sw=2,stroke_dasharray='3 16')
  if gate:
   gx,gy=(x+xx)/2,(y+yy)/2
   s+=rect(gx-55,gy-62,110,30,p['paper'],p['accent'],2,8)+txt(gx,gy-41,'LIGHT GATE',14,p['accent'],text_anchor='middle')
 for d in nodes:
  x,y=positions[d['id']]
  node=icon(x,y,d,p)+ellipse(x,y,15,15,p['top'],p['ink'],3)+label_block(x,y+44,d['name'],p)
  node+=txt(x,y+91,d['short'],13,p['dark'],text_anchor='middle')
  s+=tag('a',tag('title',ESC(d['story']))+node,href=f'{region}/{d["id"]}.svg')
 # Landmark/context annotations are not new map nodes.
 if region=='tidekin_sea':
  s+=txt(630,1020,'TIDAL BASIN',21,p['paper'],letter_spacing=4)+txt(610,1055,'town rings the water',18,p['paper'])
  s+=path('M2350 1110q90 70 0 125t0 125',stroke=p['cloth'],sw=4,stroke_dasharray='9 9')+txt(2320,1120,'DESCENT',16,p['cloth'])
  s+=use('boat',85,1450,150,130)
 else:
  s+=txt(230,1720,'ORCHARDS & OLD ROADS',18,p['dark'],letter_spacing=3)
  s+=path('M1760 1630L2390 1430',stroke=p['cloth'],sw=3,stroke_dasharray='9 9')
  s+=txt(1790,1690,'ASCENDING WARDEN TOWER',17,p['cloth'],transform='rotate(-17 1790 1690)')
 s+=line(64,1840,2536,1840,p['dark'],1)
 s+=txt(64,1880,'Click a place to open its complete side-scroll SVG. Every drawn road is a reciprocal portal connection.',21,p['ink'])
 s+=txt(64,1918,'Outer village: shared · Stronghold / story: Light allegiance · Story doors also retain their authored quest or tide checks.',18,p['dark'])
 s+='</svg>'
 return s,{'file':region+'_hometown.svg','region':region,'type':'hometown','nodes':list(positions),'edges':edges,'positions':positions}


def full_region(region,maps):
 p=SEA_PALETTE if region=='tidekin_sea' else PAL[region];w,h=3000,2500
 nodes=[d for d in maps if d['region']==region];homes=[d for d in nodes if d['group']!='wilds'];wild=[d for d in nodes if d['group']=='wilds']
 title='Tidekin Sea' if region=='tidekin_sea' else 'Human Open Lands'
 s=svg_open(title+' — all region maps',w,h)+tag('defs',props(p)+(tide_symbols() if region=='tidekin_sea' else ''))+rect(0,0,w,h,p['paper'])
 s+=txt(65,70,'COMPLETE REGIONAL ATLAS / ALL MAPS',20,p['cloth'],letter_spacing=4)+txt(65,138,title,60,p['ink'],'Georgia, serif')
 s+=txt(2935,100,f'{len(nodes)} detailed SVG layouts',28,p['ink'],text_anchor='end')
 # Cartographic islands distinguish social home, starter coast and later-return routes.
 for x,y,ww,hh,label in [(50,220,1180,1820,'HOMETOWN & STORY'),(1280,220,1670,1350,'STARTER JOURNEY · 1–40'),(1280,1640,1670,620,'RETURN JOURNEYS')]:
  s+=rect(x,y,ww,hh,p['sky'],p['far'],2,90)+txt(x+45,y+60,label,23,p['dark'],letter_spacing=3)
 # Compact hometown keeps its terrain-shaped plan from the focus map.
 positions={}
 for d in homes:
  xx,yy=TOWN_POS[region][d['short']]
  positions[d['id']]=(100+xx*.42,270+yy*.78)
 # 8 combat/aid cohorts: four columns, two rows; each pair retains direct connection.
 for d in wild:
  if d['short'].startswith(('path_','site_')):
   level=int(d['short'].split('_')[1]);cohort=(level-1)//5;row=cohort//4;col=cohort%4
   if row==1:col=3-col
   positions[d['id']]=(1490+col*405,535+row*650+(240 if d['short'].startswith('site') else 0))
 # Veteran 61–80 spine, mythic branches; danger levels remain separate from the starter sequence.
 for d in wild:
  if d['short'].startswith('return_'):
   level=int(d['short'].split('_')[1]);n=[61,66,71,76,101,116].index(level)
   positions[d['id']]=(1475+(n%3)*610,1860+(n//3)*280)
 # Human tutorial chain belongs to the region too, outside the hometown roster.
 tutorial=[d for d in wild if d['short'] in ['trail','yard','camp','grove']]
 for j,d in enumerate(tutorial): positions[d['id']]=(210+j*290,1860)
 if tutorial:s+=txt(105,1710,'WILLOW TRAIL / INTRODUCTORY LOOP',18,p['dark'],letter_spacing=2)
 edges=nodes[0]['edges']
 for a,b in edges:
  x,y=positions[a];xx,yy=positions[b]
  # Long village branches use a quiet routing corridor between the islands.
  if abs(xx-x)>1200:
   mid=1250
   dpath=f'M{x} {y}C{mid} {y} {mid} {yy} {xx} {yy}'
  else:dpath=f'M{x} {y}Q{(x+xx)/2+18} {(y+yy)/2-18} {xx} {yy}'
  s+=path(dpath,stroke=p['dark'],sw=9,opacity='.35')+path(dpath,stroke=p['paper'],sw=5)
 for d in nodes:
  x,y=positions[d['id']]
  s+=tag('a',icon(x,y,d,p,.52)+ellipse(x,y,10,10,p['top'],p['ink'],2)+label_block(x,y+32,d['name'],p,17,25)+txt(x,y+82,('Peaceful' if d['levels']=='None' else d['levels'].replace('None hostile; aid creature','Aid')),14,p['dark'],text_anchor='middle'),href=f'{region}/{d["id"]}.svg')
 s+=line(65,2310,2935,2310,p['dark'],1)
 s+=txt(65,2360,'Connections follow DESIGN-0022; full detail sheets include routes, furniture, residents, exits and local recovery.',23,p['ink'])
 s+=txt(65,2405,'The hometown inset includes village, stronghold and story maps. Proposed Human outdoor maps are included, even where runtime scenes do not yet exist.',20,p['dark'])
 s+=txt(65,2450,'Regional borders: '+('Coast Road → Open Lands · Coastal Rootway → Elder Forests · Tidal Currents → Gloamfen' if region=='tidekin_sea' else 'Coast Road → Tidekin Sea · Forest Road → Elder Forests · Sky Lifts → Sky Reaches · Great Road → Shattered March'),19,p['dark'])
 s+='</svg>'
 return s,{'file':region+'_region.svg','region':region,'type':'region','nodes':list(positions),'edges':edges,'positions':positions}


def build_overviews():
 manifest=json.loads((OUT/'manifest.json').read_text());maps=manifest['maps'];overviews=[]
 for region in ['open_lands','tidekin_sea']:
  for fn in [town,full_region]:
   svg,entry=fn(region,maps);(OUT/entry['file']).write_text(svg);overviews.append(entry)
 manifest['overviews']=overviews
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
 print('Built two hometown and two full-region SVGs')
if __name__=='__main__':build_overviews()
