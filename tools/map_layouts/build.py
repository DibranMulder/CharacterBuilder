#!/usr/bin/env python3
"""Build the complete editable Human/Tidekin SVG design atlas; no game files change."""
from pathlib import Path
import sys, json, re, html, math, textwrap
sys.path.insert(0,str(Path(__file__).parent))
from authored import HUMAN,TIDEKIN
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'designs/map-layouts'
ESC=lambda v: html.escape(str(v),quote=True)
W,H=2600,1540
PAL={
 'open_lands':dict(ink='#253c42',sky='#d6e8dd',mist='#a9c9bc',far='#91ada2',stone='#9aa593',dark='#627563',top='#e2d5a6',wood='#8b6448',leaf='#608b65',accent='#9f4c3b',cloth='#375f79',water='#77afb5',paper='#fcf6e9'),
 'tidekin_sea':dict(ink='#23474b',sky='#d5ebe7',mist='#a5d2cc',far='#84b3b0',stone='#8faeaa',dark='#527d78',top='#eee0bc',wood='#788b70',leaf='#5b9b91',accent='#ce775b',cloth='#367f8b',water='#5da8b0',paper='#fcf6e9')}

def tag(name,inner='',**attrs):
 a=' '.join(f'{k.replace("_","-")}="{ESC(v)}"' for k,v in attrs.items() if v is not None)
 return f'<{name} {a}>{inner}</{name}>'
def rect(x,y,w,h,fill,stroke=None,sw=2,rx=0,**kw): return tag('rect',x=x,y=y,width=w,height=h,fill=fill,stroke=stroke,stroke_width=sw,rx=rx,**kw)
def path(d,fill='none',stroke=None,sw=3,**kw):return tag('path',d=d,fill=fill,stroke=stroke,stroke_width=sw,stroke_linecap='round',stroke_linejoin='round',**kw)
def line(x,y,x2,y2,col,sw=3,**kw):return tag('line',x1=x,y1=y,x2=x2,y2=y2,stroke=col,stroke_width=sw,stroke_linecap='round',**kw)
def ellipse(x,y,rx,ry,fill,stroke=None,sw=2,**kw): return tag('ellipse',cx=x,cy=y,rx=rx,ry=ry,fill=fill,stroke=stroke,stroke_width=sw,**kw)
def txt(x,y,s,size=22,col='#253c42',family='Arial, sans-serif',**kw):return tag('text',ESC(s),x=x,y=y,fill=col,font_size=size,font_family=family,**kw)
def use(kind,x,y,w=100,h=100):return f'<use href="#prop-{kind}" x="{x}" y="{y}" width="{w}" height="{h}"/>'
def wrap(x,y,s,width=75,size=21,col='#253c42',leading=29): return ''.join(txt(x,y+i*leading,t,size,col) for i,t in enumerate(textwrap.wrap(s,width)))

def props(p):
 i=p['ink']; wood=p['wood']; top=p['top']; leaf=p['leaf']; acc=p['accent']; blue=p['cloth']
 D={}
 D['crate']=rect(12,20,76,76,wood,i,3,3)+rect(18,27,64,62,top,i,2)+path('M20 28L80 88M80 28L20 88',stroke=wood,sw=7)+line(10,19,90,19,top,5)
 D['barrel']=path('M24 20Q50 12 76 20Q91 58 76 95Q50 102 24 95Q9 55 24 20',wood,i)+''.join(line(x,24,x,92,top,2) for x in [34,50,66])+rect(19,32,62,8,blue,i)+rect(19,74,62,8,blue,i)+ellipse(50,19,26,7,top,i)
 D['bench']=rect(9,59,83,13,wood,i,3,3)+line(19,72,16,96,i,7)+line(82,72,85,96,i,7)+rect(15,28,72,23,wood,i,3,3)+line(20,50,20,61,i,5)+line(82,50,82,61,i,5)+line(9,59,92,59,top,4)
 D['table']=rect(5,44,90,15,wood,i,3,4)+line(18,59,15,97,i,7)+line(82,59,85,97,i,7)+line(20,81,80,81,wood,5)+line(5,44,95,44,top,5)+ellipse(42,40,15,4,top,i)+rect(67,29,12,15,acc,i,2,2)
 D['bed']=rect(5,62,90,19,wood,i,3)+rect(8,43,84,19,top,i,3,5)+rect(43,40,48,28,blue,i,3,4)+rect(11,42,29,14,'#f9f2dc',i,2,5)+line(8,30,8,96,wood,8)+line(93,47,93,96,wood,8)
 D['shelf']=rect(8,6,84,92,wood,i,3,2)+''.join(rect(15,y,70,7,top,i,1) for y in [33,62,88])+''.join(rect(x,y,8,22,[acc,blue,leaf,top][(x//11)%4],i,1) for y in [10,39,66] for x in range(18,77,11))+line(8,6,92,6,top,4)
 D['chest']=rect(8,43,84,53,wood,i,3,4)+path('M8 44Q13 7 50 8Q90 8 92 44Z',acc,i)+rect(21,37,9,59,top,i)+rect(70,37,9,59,top,i)+rect(43,50,15,20,top,i,2,2)+ellipse(50,59,3,4,i)
 D['bottles']=use('table',0,0)+''.join(path(f'M{x} 17v10q-10 6-7 16h22q4-10-7-16V17Z',c,i,2) for x,c in [(25,leaf),(58,blue),(79,acc)])
 D['planter']=path('M10 58H90L80 96H21Z',wood,i)+rect(6,54,88,12,top,i,3,3)+''.join(path(f'M{x} 55Q{x-16} 28 {x-22} 30Q{x-18} 50 {x} 49M{x} 54Q{x+21} 8 {x+25} 17Q{x+30} 42 {x} 50',leaf,i,2) for x in [27,53,72])
 D['basket']=path('M12 50Q50 38 88 50L79 94Q50 101 21 94Z',top,i)+path('M25 50C17 9 83 9 76 50',stroke=wood,sw=7)+''.join(line(18,y,82,y,wood,3) for y in [63,75,87])+line(13,49,88,49,top,5)
 D['ropebasket']=line(28,0,26,60,wood,3)+line(74,0,75,60,wood,3)+use('basket',0,12,100,87)
 D['rack']=path('M15 96L20 17H80L86 96M14 38H88',stroke=wood,sw=7)+''.join(path(f'M{x} 77V23M{x-8} 39h16',stroke=top,sw=5) for x in [30,50,70])+ellipse(50,64,15,21,blue,i,2)
 D['anvil']=path('M14 30H84L94 41L65 51V72L80 85H22L40 69V52L10 44Z',blue,i)+rect(19,85,64,13,wood,i)+line(14,29,85,29,top,5)
 D['forge']=path('M8 96V45L23 29V6H65V29L90 45V96Z',p['stone'],i)+path('M25 96V68Q50 31 75 68V96Z',i,i)+path('M35 91Q24 67 43 58Q37 78 51 63Q48 42 62 53Q85 84 66 94Z',acc,None)+path('M44 93Q39 73 55 70Q69 88 58 95Z','#f3c777')+rect(6,42,88,10,top,i)
 D['oven']=D['forge']
 D['fireplace']=path('M7 98V38H93V98H70V67Q50 42 30 67V98Z',p['stone'],i)+rect(3,27,94,15,wood,i)+path('M38 97Q23 72 48 63Q48 80 63 68Q80 95 58 99Z',acc,i,2)+line(32,96,71,96,wood,8)
 D['dummy']=line(50,42,50,91,wood,8)+line(15,53,85,53,wood,8)+ellipse(50,24,18,18,top,i)+path('M31 42Q50 34 69 42L76 80H24Z',top,i)+path('M38 53L61 68M61 53L38 68',stroke=acc,sw=4)+rect(30,91,40,7,wood,i)
 D['target']=line(30,55,16,97,wood,6)+line(68,55,85,97,wood,6)+ellipse(50,42,38,37,top,i,3)+ellipse(50,42,26,25,acc,i)+ellipse(50,42,13,13,top,i)+ellipse(50,42,4,4,i)
 D['sign']=rect(44,29,11,69,wood,i)+path('M5 13H81L96 29L81 45H5Z',top,i)+line(18,26,72,26,wood,3)+line(18,34,58,34,wood,3)
 D['banner']=line(19,2,19,99,wood,7)+path('M23 9H83V78L54 65L24 81Z',blue,i)+path('M52 22l14 14-14 14-14-14Z',top,i,2)+ellipse(19,5,6,6,top,i)
 D['lantern']=path('M26 39Q50 4 75 39',stroke=wood,sw=5)+path('M27 41H74L67 87H34Z',top,i)+rect(26,37,49,8,blue,i)+rect(32,84,38,8,blue,i)+line(44,45,43,83,acc,3)+line(58,45,59,83,acc,3)
 D['bell']=path('M23 66Q33 42 33 29Q50 12 67 29Q66 42 79 66Z',top,i)+ellipse(50,66,31,8,wood,i)+ellipse(50,78,7,9,top,i)+path('M13 95V13H86V95',stroke=wood,sw=6)+line(49,14,49,25,i,3)
 D['winch']=path('M12 97V9H88V97M12 10L87 78',stroke=wood,sw=7)+line(64,10,64,61,i,3)+ellipse(64,20,10,10,top,i)+path('M64 62v15q-15 15-18-2',stroke=blue,sw=6)+rect(5,90,90,9,top,i)
 D['buoy']=line(50,12,50,82,wood,4)+path('M50 14L84 24L50 37Z',acc,i)+ellipse(50,86,36,11,blue,i)+ellipse(50,75,22,17,top,i)+path('M13 96Q31 88 49 96T89 96',stroke=p['water'],sw=4)
 D['boat']=path('M5 68Q50 89 96 62L77 89Q45 108 16 89Z',wood,i)+line(7,68,94,64,top,5)+line(49,14,49,68,wood,4)+path('M52 17L82 54H52Z',p['paper'],i,2)+line(30,76,17,98,blue,5)
 D['gauge']=rect(32,9,36,87,top,i,3,5)+''.join(line(35,y,51 if y%20 else 61,y,blue,3) for y in range(20,91,10))+rect(63,55,15,18,acc,i)+rect(26,91,49,7,wood,i)
 D['valve']=use('pipe',0,0)+ellipse(50,45,26,26,acc,i)+''.join(line(50,45,50+22*math.cos(a),45+22*math.sin(a),top,4) for a in [0,2.1,4.2])+ellipse(50,45,6,6,blue,i)
 D['pipe']=path('M9 89V45Q9 20 36 20H93V42H39Q31 42 31 50V89Z',blue,i)+rect(2,80,36,12,top,i)+rect(81,13,12,37,top,i)
 D['orb']=path('M27 97L38 73H63L76 97Z',p['stone'],i)+ellipse(50,47,30,30,p['paper'],i)+ellipse(42,34,10,7,'white')+path('M55 70Q74 65 76 46',stroke=p['water'],sw=3)+line(27,97,76,97,top,5)
 D['lectern']=path('M46 43V89H21V98H81V89H56V43Z',wood,i)+path('M14 40L27 16L86 26L77 51Z',top,i)+path('M29 21L51 26L45 45M55 27L77 31',stroke=wood,sw=2)
 D['telescope']=line(48,59,29,98,wood,6)+line(48,59,73,98,wood,6)+path('M11 42L79 13L91 38L22 66Z',blue,i)+path('M71 13L85 7L99 34L86 40Z',top,i)+line(47,55,47,80,wood,5)
 D['throne']=path('M18 95V24L30 33L49 6L70 33L83 24V95Z',wood,i)+rect(31,34,39,41,acc,i,3,3)+rect(20,76,61,13,top,i)+line(24,89,24,99,wood,7)+line(78,89,78,99,wood,7)
 D['cart']=ellipse(26,84,14,14,wood,i)+ellipse(77,84,14,14,wood,i)+rect(7,36,88,42,wood,i,3,3)+''.join(line(x,40,x,73,top,3) for x in [20,37,55,74,87])+path('M10 35Q12 0 50 4Q93 0 92 35Z',p['paper'],i)+line(4,36,96,36,top,5)
 D['tent']=path('M3 96L49 13L97 96Z',blue,i)+path('M27 96L49 49L71 96Z',i,i)+line(50,6,50,26,wood,5)+line(0,97,100,97,top,4)
 D['hay']=rect(9,36,83,59,top,i,3,8)+''.join(path(f'M{x} 42q10 21 0 47',stroke=wood,sw=2) for x in range(17,88,10))+line(9,55,92,55,wood,5)+line(9,80,92,80,wood,5)
 D['trough']=path('M5 54H95L83 87H17Z',wood,i)+ellipse(50,53,44,10,p['water'],i)+line(22,86,19,98,i,6)+line(78,86,83,98,i,6)
 D['log']=rect(15,55,70,39,wood,i,3,10)+ellipse(17,74,14,20,top,i)+ellipse(17,74,7,12,'none',wood)+path('M40 64h28M42 82h24',stroke=top,sw=2)
 D['tree']=path('M38 98Q54 58 44 25L61 23Q50 70 67 98Z',wood,i)+path('M10 60Q-5 34 21 31Q12 4 42 9Q60-10 72 16Q109 9 92 40Q111 71 76 66Q48 85 27 63Z',leaf,i,3)+path('M23 43Q35 26 48 32M58 18q19 1 22 19',stroke=top,sw=2)
 D['coral']=path('M45 98V52L20 36V9M45 71L73 52V17M73 39L90 28V10M19 27L7 19V7M47 51L48 14',stroke=acc,sw=12)+path('M45 98V52L20 36V9M45 71L73 52V17',stroke=top,sw=3)
 D['mushroom']=path('M44 46L34 96H69L58 43Z',top,i)+path('M3 48Q9 2 51 4Q92 9 97 48Q52 66 3 48Z',acc,i)+ellipse(34,27,10,7,top)+ellipse(68,34,13,8,top)+line(3,48,97,48,top,3)
 D['statue']=path('M17 98V83H31L34 52L25 46L30 26L44 20L49 4L64 15L69 32L79 48L66 58L68 83H83V98Z',p['stone'],i)+path('M35 35l26 0M43 53l14 0M45 66l13 0',stroke=top,sw=4)+ellipse(42,32,3,3,p['water'])+ellipse(60,32,3,3,p['water'])
 D['windmill']=path('M22 98L33 33H67L80 98Z',p['stone'],i)+path('M22 33L50 7L78 33Z',acc,i)+path('M48 44L16 8L6 21L44 51L10 88L25 96L54 58L90 90L98 76L62 49L91 13L77 4Z',top,i)
 D['waterwheel']=ellipse(50,51,43,43,wood,i,4)+ellipse(50,51,32,32,'none',top,6)+''.join(line(50,51,50+40*math.cos(a),51+40*math.sin(a),wood,6) for a in [j*math.pi/4 for j in range(8)])+ellipse(50,51,8,8,top,i)
 D['press']=path('M14 97V7H87V97',stroke=wood,sw=9)+line(50,9,50,64,i,7)+rect(21,61,58,11,top,i)+use('basket',12,37,76,61)
 D['laddercart']=ellipse(29,92,6,6,i)+ellipse(73,92,6,6,i)+line(23,90,58,7,wood,6)+line(61,90,91,7,wood,6)+''.join(line(25+y*.39,88-y,61+y*.36,88-y,top,4) for y in range(0,81,13))
 D['chimney']=rect(25,21,48,76,p['stone'],i)+rect(16,14,65,15,top,i)+path('M29 46h42M28 71h43M46 29v17M58 47v23M43 73v22',stroke=p['dark'],sw=2)
 D['well']=ellipse(50,80,36,15,p['stone'],i)+rect(15,62,70,20,p['stone'],i)+ellipse(50,61,36,14,top,i)+ellipse(50,61,24,7,p['water'],i)+line(20,22,20,64,wood,6)+line(80,22,80,64,wood,6)+path('M7 23L50 3L93 23Z',blue,i)+line(50,23,50,61,wood,3)
 D['stall']=path('M13 96V33M86 96V33',stroke=wood,sw=6)+rect(7,68,88,15,wood,i)+path('M4 32L17 6H83L97 32Z',blue,i)+''.join(rect(4+j*18.6,32,18.6,14,top if j%2 else blue,i,1,4) for j in range(5))+use('basket',27,40,45,40)+line(7,68,95,68,top,4)
 return ''.join(tag('symbol',v,id='prop-'+k,viewBox='0 0 100 100') for k,v in D.items())


def catalog():
 text=(ROOT/'docs/game/0022-world-map-level-plan.md').read_text()
 atlas=json.loads((ROOT/'src/world/atlas.json').read_text())
 td={m['id']:m for m in json.loads((ROOT/'prototypes/tidekin_sea/region.json').read_text())['maps']}
 result=[]
 for region,authored,next_heading in [('open_lands',HUMAN,'Tidekin Sea'),('tidekin_sea',TIDEKIN,'Elder Forests')]:
  heading='Open Lands' if region=='open_lands' else 'Tidekin Sea'
  section=text.split('### '+heading+'\n',1)[1].split('### '+next_heading+'\n',1)[0]
  rows={}
  for line_ in section.splitlines():
   if line_.startswith('| `'):
    cells=[a.strip() for a in line_.strip('|').split('|')]
    rows[cells[0].strip('`')]={'name':cells[1],'levels':cells[3],'occupants':cells[4],'access':cells[5]}
  at=next(r for r in atlas['regions'] if r['id']==region)
  groups={n['id']:n['group'] for n in at['nodes']}
  edges=set(tuple(sorted(e)) for e in re.findall(r'^    (\w+) --- (\w+)\s*$',section,re.M))
  seen=set()
  for ordinal,(short,shape,geometry,landmark,kit,story) in enumerate(authored,1):
   id_= ('tidekin_sea_'+short) if region=='tidekin_sea' else ('open_lands_'+short if short.startswith(('path_','site_','return_')) else short)
   assert id_ in rows, id_
   seen.add(id_)
   d=dict(rows[id_],id=id_,short=short,region=region,group=groups.get(id_,'wilds'),shape=shape,landmark=landmark,props=kit.split(','),story=story,ordinal=ordinal)
   d['platforms']=[{'id':f'ledge-{j+1}','x':a,'y':b,'w':c} for j,(a,b,c) in enumerate(tuple(map(int,s.split(','))) for s in geometry.split(';'))]
   d['neighbors']=sorted(b if a==id_ else a for a,b in edges if id_ in [a,b])
   d['edges']=[list(e) for e in sorted(edges)]
   d['source']='DESIGN-0014 / DESIGN-0022'+(' / DESIGN-0023' if region=='tidekin_sea' else '')
   d['planned_only']=id_.startswith('open_lands_')
   if id_ in td:
    d['activity']=td[id_]['activity'];d['recovery']=td[id_]['anchor'];d['species']=td[id_]['species']
   else:d['activity']=d['occupants'];d['recovery']='Sheltered entry alcove on this map';d['species']=[]
   result.append(d)
  assert seen==set(rows),(region,set(rows)-seen,seen-set(rows))
 return result

HUMAN_NPCS={
'square':['Elowen · lorekeeper','Perrin · Exchange broker','Village sentries'], 'market':['Brann · weapons','Tessa · armor','Orin · arcane stall'],
'apothecary':['Mira · apothecary','Bramble · provisions'], 'trainers':['Hale · Vanguard','Runa · Ravager','Ash · Ranger','Nessa · Duelist','Iven · Arcanist','Soleil · Warden'],
'inn':['Maren · innkeeper','Odo · quartermaster'],'approach':['Tamsin · orchard keeper','Old Road Warden · guardian'],
'gatehouse':['Beren · gate captain','Wren · courier'],'barracks':['Aldren · captain','Finch · recruit'],'service':['Ada · cook','Torren · smith'],
'hall':['Cerys · herald','Oswin · steward'],'king':['The Oathbound King','Edda · counsellor'],'archive':['Meriel · archivist','Corvin · treasurer'],
 'tower':['Ansel · tower keeper'],'stair':['Pip · lamplighter'],'solar':['Lyra · heir-warden','Seren · attendant'],'camp':['Rowan · traveling trader']}
TIDE_NPCS={'land':['Ferrymaster Tavi'],'cm':['Neri · weapons','Brineweft · armor','Ossa · provisions','Broker Pel','Lume · wandwright'],
 'lag':['Tidemender Sera','Lagoon sentry'],'ka':['Apothecary Vela'],'dy':['Tal · Vanguard','Rusk · Ravager','Fenn · Ranger','Suri · Duelist','Ilun · Arcanist','Mara · Warden'],
 'inn':['Innkeeper Pell','Toma · quartermaster'],'caus':['Reefwarden Nacre · guardian','Gate sentry'],'gs':['Shell Captain Iri'],'rb':['Reefguard Sen'],
 'cw':['Engineer Mero'],'ph':['Steward Amaya'],'tc':['The Tide Speaker'],'dv':['Archivist Coru']}


def header(d,p):
 s=rect(0,0,W,H,p['paper'])+rect(0,0,W,14,p['ink'])
 s+=txt(64,64,('TIDEKIN SEA' if d['region']=='tidekin_sea' else 'HUMANS · OPEN LANDS')+' / '+d['group'].upper(),18,p['cloth'],letter_spacing=4)
 s+=txt(64,124,d['name'],48,p['ink'],'Georgia, serif')
 s+=txt(66,163,d['landmark']+'   /   '+d['id'],20,p['dark'])
 s+=txt(2536,67,f'{d["ordinal"]:02d} / '+('39' if d['region']=='tidekin_sea' else '41'),28,p['ink'],text_anchor='end')
 s+=txt(2536,108,d['access']+' access · '+d['levels'],20,p['ink'],text_anchor='end')
 s+=txt(2536,149,'EDITABLE SIDE-SCROLL LAYOUT · CONCEPT DESIGN',15,p['dark'],text_anchor='end',letter_spacing=2)
 return s


def house(x,y,w,h,p,kind='house',label=None):
 i=p['ink'];s=''
 roof=p['cloth'] if kind in ['shell','shop'] else p['accent']
 s+=rect(x,y,w,h,p['paper'],i,3,5)
 s+=rect(x+10,y+h-16,w-20,16,p['stone'])
 for xx in [x+14,x+w*.5,x+w-18]:s+=rect(xx,y+8,7,h-23,p['wood'])
 for yy in [y+h*.37,y+h*.7]:s+=line(x+4,yy,x+w-4,yy,p['wood'],5)
 if kind=='shell':
  s+=path(f'M{x-16} {y+12}Q{x+w*.5} {y-h*.72} {x+w+16} {y+12}Z',roof,i,3)
  for a in [.15,.33,.5,.67,.85]:s+=path(f'M{x+w*a} {y+6}Q{x+w*.5} {y-h*.64} {x+w*.5} {y-h*.30}',stroke=p['top'],sw=2)
 elif kind=='shop':s+=path(f'M{x-15} {y+5}L{x+20} {y-53}H{x+w-20}L{x+w+15} {y+5}Z',roof,i,3)+''.join(rect(x+j*w/6,y+5,w/6,16,p['top'] if j%2 else roof,i,1,4) for j in range(6))
 else:s+=path(f'M{x-17} {y+4}L{x+w*.5} {y-77}L{x+w+17} {y+4}Z',roof,i,3)
 for xx in [x+w*.2,x+w*.7]:
  s+=rect(xx-20,y+27,40,48,p['water'],i,3,18)+line(xx,y+27,xx,y+73,p['top'],3)+line(xx-18,y+49,xx+18,y+49,p['top'],3)
 s+=path(f'M{x+w*.45} {y+h}V{y+h-60}q{w*.1}-28 {w*.2} 0V{y+h}Z',p['wood'],i,3)
 if label:s+=rect(x+w*.18,y+h*.66,w*.64,31,p['top'],i,2,3)+txt(x+w*.5,y+h*.66+22,label,15,i,text_anchor='middle')
 return s


def landmark(d,p):
 """Architecture is a background cutaway; landing surfaces are drawn separately."""
 shape=d['shape'];i=p['ink'];s=''
 if shape in ['interior','hall','stacks','observatory','workshops']:
  # Open facade: roof beams, columns and room-specific working furniture.
  s+=path('M230 1080V414L1300 231L2370 414V1080Z',p['paper'],p['far'],4,opacity='.70')
  s+=path('M260 424L1300 264L2340 424M290 431V1080M2310 431V1080',stroke=p['wood'],sw=12,opacity='.5')
  for x in [610,1090,1570,2050]:
   s+=path(f'M{x-83} 736V476Q{x} 346 {x+83} 476V736Z',p['sky'],p['far'],6)
   s+=line(x,407,x,736,p['far'],4)+line(x-80,526,x+80,526,p['far'],4)
  if shape=='stacks':
   for x in [360,750,1190,1650,2060]:s+=use('shelf',x,740,200,310)
  elif shape=='interior':s+=use('fireplace',1050,720,370,380)+use('bed',1850,600,250,160)
  elif shape=='hall':
   for x in [480,910,1680,2110]:s+=use('banner',x,400,130,210)
   s+=use('throne' if d['short']=='king' else 'orb',1160,660,260,370)
  elif shape=='observatory':s+=use('telescope',1170,650,290,360)+ellipse(1300,511,142,142,'none',p['top'],7)
  else:
   for x in [370,1110,1840]:s+=use('pipe',x,735,280,310)+use('valve',x+150,770,180,210)
 elif shape in ['gate','wall','tower','switchback','descent']:
  for x,y,w,h in [(360,430,360,650),(1890,380,360,700)]:
   if shape in ['tower','switchback']:x=980 if x<1000 else 1720;w=410
   s+=rect(x,y,w,h,p['stone'],p['far'],3,40)
   for yy in range(int(y+65),int(y+h-20),85):
    s+=line(x+9,yy,x+w-9,yy,p['far'],2)
    for xx in range(int(x+20),int(x+w-20),95):s+=line(xx,yy,xx,yy+45,p['far'],2)
   s+=path(f'M{x-24} {y+4}L{x+w/2} {y-130}L{x+w+24} {y+4}Z',p['cloth'],p['far'],3)
   for yy in [y+95,y+245,y+395]:s+=rect(x+w*.4,yy,w*.2,82,p['sky'],p['far'],3,30)
  if shape=='gate':
   s+=path('M760 1085V660Q1300 210 1840 660V1085H1650V701Q1300 425 950 701V1085Z',p['stone'],p['far'],4)
   for x in range(1020,1640,85):s+=line(x,605,x,970,p['dark'],10)
  if shape=='descent':s+=path('M270 458L2370 1065M270 478L2370 1085',stroke=p['dark'],sw=12)
  if shape=='switchback':
   for y in [410,640,860]:s+=path(f'M610 {y+185}L1970 {y}M610 {y+199}L1970 {y+14}',stroke=p['wood'],sw=10)
 elif shape in ['harbor','roofstreet','crossroads','camp']:
  if shape=='harbor':
   for x in [390,1600]:s+=use('boat',x,700,550,370)+line(x+200,410,x+200,920,p['wood'],9)+path(f'M{x+210} 430L{x+440} 705H{x+210}Z',p['paper'],p['far'],3)
   s+=house(960,740,410,325,p,'shell' if d['region']=='tidekin_sea' else 'house','CUSTOMS')
  else:
   for j,(x,y,w) in enumerate([(230,770,430),(900,650,460),(1630,760,460),(2160,810,300)]):s+=house(x,y,w,1100-y,p,'shell' if d['region']=='tidekin_sea' else ('shop' if shape=='roofstreet' else 'house'))
   if shape=='crossroads':s+=rect(1130,380,150,440,p['stone'],i,3)+ellipse(1205,440,54,54,p['paper'],i,3)+path('M1205 410V440L1233 457',stroke=i,sw=4)
   if shape=='camp':s+=use('cart',460,760,420,320)+use('tent',1550,680,430,360)
 else:
  if shape in ['woodland','roots','hollow','orchard','hedges','pasture']:
   for j,(x,y,sc) in enumerate([(200,400,590),(920,300,740),(1940,380,610)]):
    s+=use('tree' if shape!='hollow' else 'mushroom',x,y,sc,820 if shape!='hollow' else 650)
   if shape in ['orchard','pasture','hedges']:s+=house(1450,820,350,260,p,'house')
  elif shape in ['cliffs','terraces','sandbars','beach']:
   for x,y,w in [(150,730,650),(880,570,740),(1700,720,750)]:
    s+=path(f'M{x} 1120V{y+40}Q{x+w*.4} {y-60} {x+w} {y+10}L{x+w-60} 1120Z',p['stone'],p['far'],3)
    s+=path(f'M{x+30} {y+42}Q{x+w*.4} {y-18} {x+w-20} {y+30}',stroke=p['top'],sw=12)
   for x in [360,1220,2010]:s+=use('coral' if d['region']=='tidekin_sea' else 'tree',x,760,180,280)
  elif shape in ['bridge','river']:
   for x in [430,950,1470,1990]:
    s+=path(f'M{x-210} 1090V775H{x+210}V1090H{x+133}V933Q{x} 750 {x-133} 933V1090Z',p['stone'],p['far'],3)
   if d['region']=='open_lands':s+=use('waterwheel',1720,700,340,350)
  elif shape in ['basin','sanctuary','convergence','monuments']:
   s+=ellipse(1300,1050,900,230,p['water'],p['far'],4)
   if shape=='basin':
    s+=use('gauge',1170,550,220,470)+house(390,780,330,300,p,'shell' if d['region']=='tidekin_sea' else 'house')
    for x in [980,1520,2040]:s+=ellipse(x,1030,180,55,p['sky'],p['far'],6)
   else:
    for x,y,sc in [(390,660,230),(1110,440,340),(1990,650,250)]:
     s+=use('orb' if d['region']=='tidekin_sea' else 'statue',x,y,sc,420)
   if shape=='convergence':
    s+=ellipse(1300,696,340,250,'none',p['far'],32)+ellipse(1300,696,285,205,'none',p['top'],10)
    for k in range(12):
     a=k*math.pi/6;s+=line(1300+300*math.cos(a),696+210*math.sin(a),1300+330*math.cos(a),696+235*math.sin(a),p['dark'],6)
  else:
   for x,y in [(260,700),(950,520),(1730,670)]:s+=path(f'M{x} 1080V{y}H{x+70}V{y+180}H{x+320}V{y+45}H{x+395}V1080',p['stone'],p['far'],3)
 return tag('g',s,id='architecture',opacity='.72')


def connector(upper,lower,index,p):
 # Every landing has a supported climb to an overlapping lower landing or the street.
 lx=max(upper['x']+35,lower['x']+25);rx=min(upper['x']+upper['w']-35,lower['x']+lower['w']-25)
 x=(lx+rx)/2;y=upper['y'];end=lower['y'];i=p['ink'];s=''
 kind='stairs' if index in [0,3] else ('rope' if index in [1,5,6] else 'ladder')
 if kind=='stairs':
  run=min(230,upper['w']*.65,x-lower['x']-12);start=x-run;steps=max(3,math.ceil((end-y)/32));pts=[(start,end)]
  for j in range(steps):pts += [(start+(j+1)*run/steps,end-j*(end-y)/steps),(start+(j+1)*run/steps,end-(j+1)*(end-y)/steps)]
  s+=path('M'+'L'.join(f'{a:.1f} {b:.1f}' for a,b in pts),stroke=i,sw=13)
  s+=path('M'+'L'.join(f'{a:.1f} {b:.1f}' for a,b in pts),stroke=p['top'],sw=7)
  s+=line(start-3,end-45,x,y-45,p['wood'],5)
  for j in range(5):s+=line(start+j*run/4,end-j*(end-y)/4-45,start+j*run/4,end-j*(end-y)/4-8,p['wood'],3)
 elif kind=='ladder':
  s+=line(x-15,y-18,x-15,end,i,8)+line(x+15,y-18,x+15,end,i,8)
  s+=line(x-15,y-18,x-15,end,p['wood'],4)+line(x+15,y-18,x+15,end,p['wood'],4)
  for yy in range(int(y+8),int(end),24):s+=line(x-13,yy,x+13,yy,p['top'],5)
 else:
  s+=ellipse(x,y-8,9,9,p['wood'],i)+path(f'M{x} {y}Q{x-10} {(y+end)/2} {x} {end}',stroke=i,sw=8)+path(f'M{x} {y}Q{x-10} {(y+end)/2} {x} {end}',stroke=p['top'],sw=4)
  for yy in range(int(y+25),int(end-5),30):s+=line(x-7,yy,x+5,yy+3,p['wood'],3)
 return tag('g',s,id=f'climb-{index+1}',data_kind=kind),{'id':f'climb-{index+1}','type':kind,'from':lower['id'],'to':upper['id'],'x':round(x,1),'bottom_x':round(start if kind=='stairs' else x,1),'y1':y,'y2':end}


def surface(a,p,ground=False,material='stone'):
 x,y,w=a['x'],a['y'],a['w'];i=p['ink'];s=''
 if ground:
  s+=path(f'M{x} {y}H{x+w}V1190H{x}Z',p['dark'],i,4)
  for xx in range(int(x+15),int(x+w-30),85):s+=path(f'M{xx} {y+32}l41-6 28 18-22 39-47-9Z',p['stone'],p['dark'],2)
 elif material in ['timber','gallery']:
  s+=rect(x,y,w,27,p['wood'],i,3,3)
  for xx in range(int(x+14),int(x+w-10),36):s+=line(xx,y+2,xx,y+25,p['top'],2)
  s+=line(x+8,y+31,x+w-8,y+31,p['dark'],8)
  for xx in [x+30,x+w-30]:
   if material=='timber':s+=line(xx,y+31,xx,1096,p['wood'],9)+line(xx-6,y+43,xx+6,y+43,p['top'],4)
   else:s+=path(f'M{xx-15} {y+29}L{xx} {y+65}L{xx+23} {y+29}',p['wood'],i,2)
  for xx in [x+40,x+w-85]:s+=path(f'M{xx} {y+30}l45 45M{xx+45} {y+30}l-45 45',stroke=p['wood'],sw=5)
 elif material=='root':
  s+=path(f'M{x} {y+7}Q{x+w*.4} {y+24} {x+w} {y+5}L{x+w-8} {y+34}Q{x+w*.5} {y+62} {x+10} {y+33}Z',p['wood'],i,3)
  s+=path(f'M{x+30} {y+20}Q{x+w*.5} {y+44} {x+w-25} {y+18}',stroke=p['top'],sw=3)
  s+=path(f'M{x+w*.2} {y+33}q25 100-55 174M{x+w*.75} {y+30}q-45 80 20 122',stroke=p['wood'],sw=9)
 else:
  s+=path(f'M{x} {y}H{x+w}L{x+w-22} {y+41}L{x+w*.77} {y+48}L{x+w*.68} {y+64}L{x+w*.45} {y+44}L{x+35} {y+52}Z',p['stone'],i,3)
  s+=line(x+25,y+32,x+w-26,y+33,p['dark'],3)
 s+=rect(x-2,y-7,w+4,13,p['top'],i,3,5)
 s+=line(x+5,y-8,x+w-5,y-8,'#fcf5d7',4)
 for xx in range(int(x+16),int(x+w-10),48):s+=path(f'M{xx} {y-7}q7-11 14 0m5 0q8-12 12 0',stroke=p['leaf'],sw=3)
 return tag('g',s,id=a['id'],data_walkable='true')


def npc_marker(x,y,name,index,p):
 # Small painted figure with an unobtrusive numbered callout; full name goes in footer.
 s=ellipse(x,y-7,19,6,p['dark'],opacity='.3')
 s+=line(x-7,y-20,x-9,y-7,p['ink'],5)+line(x+6,y-20,x+9,y-7,p['ink'],5)
 s+=path(f'M{x-15} {y-46}Q{x} {y-55} {x+15} {y-46}L{x+18} {y-19}H{x-18}Z',p['cloth'],p['ink'],2)
 s+=ellipse(x,y-62,16,18,p['top'],p['ink'],2)+ellipse(x+5,y-63,2,2,p['ink'])
 s+=ellipse(x,y-103,16,16,p['paper'],p['ink'],2)+txt(x,y-97,str(index),17,p['ink'],text_anchor='middle')
 return tag('g',tag('title',ESC(name))+s,data_npc=name)


def draw_map(d):
 p=PAL[d['region']];s=header(d,p)
 defs=props(p)+tag('linearGradient',tag('stop',offset='0%',stop_color=p['sky'])+tag('stop',offset='100%',stop_color=p['paper']),id='sky',x2='0',y2='1')+tag('clipPath',rect(40,195,2520,995,'white',rx=20),id='scene-clip')
 s+=f'<defs>{defs}</defs>'
 world=rect(40,195,2520,995,'url(#sky)')
 world+=ellipse(2150,361,102,102,'#fff7d7',opacity='.8')
 # Broad quiet skyline; detail is concentrated at the interactive depth.
 world+=path('M40 720Q220 450 410 660Q680 330 900 610Q1170 320 1410 640Q1760 400 1960 640Q2330 350 2560 670V1190H40Z',p['mist'],opacity='.5')
 for x in [210,970,1670]: world+=path(f'M{x} 320q80-40 151 0q55-31 109 0',stroke=p['paper'],sw=14,opacity='.7')
 world+=landmark(d,p)
 if d['region']=='tidekin_sea' or d['shape'] in ['river','bridge']:
  world+=rect(40,1080,2520,110,p['water'],opacity='.8')
  for yy in [1100,1130,1160]:world+=path(f'M65 {yy}q95-15 190 0t190 0t190 0t190 0t190 0t190 0t190 0t190 0t190 0t190 0t190 0t190 0t190 0',stroke=p['paper'],sw=3,opacity='.35')
 floor={'id':'street','x':70,'y':1100,'w':2460}
 world+=surface(floor,p,True)
 # A line under the main floor makes the guaranteed public return unambiguous.
 world+=line(115,1170,2470,1170,p['top'],3,stroke_dasharray='9 12',opacity='.65')
 material='timber' if d['shape'] in ['harbor','roofstreet','crossroads','camp','courts','basin'] else ('gallery' if d['shape'] in ['interior','hall','stacks','observatory','workshops','tower','switchback','gate','descent'] else ('root' if d['shape'] in ['woodland','roots','hollow','orchard','hedges','pasture'] else 'stone'))
 for a in sorted(d['platforms'],key=lambda a:a['y'],reverse=True):world+=surface(a,p,material=material)
 climbs=[]
 for j,a in enumerate(d['platforms']):
  below=[b for b in d['platforms']+[floor] if b['y']>a['y'] and min(a['x']+a['w'],b['x']+b['w'])-max(a['x'],b['x'])>90]
  lower=min(below,key=lambda b:b['y'])
  g,c=connector(a,lower,j,p);world+=g;climbs.append(c)
 # Distinct furniture sets, placed on actual surfaces rather than floating in scenery.
 objects=[]
 for j,a in enumerate(d['platforms']):
  for k in range(2):
   kind=d['props'][(j*2+k)%len(d['props'])];sz=min(72 if kind not in ['tree','coral','mushroom'] else 94,a['y']-220)
   x=a['x']+28+k*(a['w']-sz-55);y=a['y']-sz-7
   world+=tag('g',tag('title',ESC(kind.replace('_',' ')+' · optional jump surface'))+use(kind,x,y,sz,sz),data_prop=kind)
   objects.append({'type':kind,'surface':a['id'],'x':x,'y':y,'w':sz,'h':sz,'jumpable':kind in ['crate','barrel','bench','table','bed','shelf','chest','basket','cart','hay','log','mushroom','boat','anvil','trough']})
 for j,x in enumerate([350,550,750,950,1150,1350,1550,1750,1950,2210]):
  kind=d['props'][(j+3)%len(d['props'])];sz=100 if kind!='tree' else 155
  world+=use(kind,x,1100-sz-8,sz,sz)
  objects.append({'type':kind,'surface':'street','x':x,'y':1100-sz-8,'w':sz,'h':sz,'jumpable':kind in ['crate','barrel','bench','table','chest','cart','hay','log','basket','boat']})
 npcs=(TIDE_NPCS if d['region']=='tidekin_sea' else HUMAN_NPCS).get(d['short'],[])
 for j,name in enumerate(npcs):world+=npc_marker(525+j*(1600/max(1,len(npcs)-1)),1092,name,j+1,p)
 # Golden exits are numbered to avoid the long destination strings obscuring routes.
 portals=[]
 positions=[(155,1100,'street'),(2435,1100,'street')]+[(a['x']+a['w']*.53,a['y'],a['id']) for a in d['platforms']]
 for j,destination in enumerate(d['neighbors']):
  x,y,support=positions[j]
  if d['short']=='stair' and destination=='solar':
   a=min((a for a in d['platforms'] if a['y']>=405),key=lambda a:a['y']);x,y,support=a['x']+a['w']*.6,a['y'],a['id']
  elif d['shape']=='descent':
   a=d['platforms'][3 if destination.endswith(('_fn','_cr','_ps')) else 0];x,y,support=a['x']+a['w']*.55,a['y'],a['id']
  world+=ellipse(x,y-9,45,13,'#f4d16d',p['ink'],2)+ellipse(x,y-9,31,8,'#fff2ba')
  world+=path(f'M{x-29} {y-18}V{y-113}Q{x} {y-155} {x+29} {y-113}V{y-18}',stroke='#efd184',sw=5)
  world+=rect(x-29,y-184,58,30,p['paper'],p['ink'],2,15)+txt(x,y-162,f'P{j+1}',17,p['ink'],text_anchor='middle')
  portals.append({'label':f'P{j+1}','to':destination,'x':x,'y':y,'support':support})
 world+=use('lantern',205,1010,72,85)+txt(238,1006,'R',17,p['ink'],text_anchor='middle')
 # In-scene route captions have reserved sky space, not labels over actors.
 world+=rect(72,218,660,42,p['paper'],None,rx=21,opacity='.92')+txt(94,246,'Climbable stairs / ladders / ropes · pale edges are landable',19,p['ink'])
 world+=rect(1745,218,780,42,p['paper'],None,rx=21,opacity='.92')+txt(1770,246,'Solid route stays open · furniture tops add optional hops',19,p['ink'])
 s+=tag('g',world,id='world',clip_path='url(#scene-clip)')
 # Designer-facing annotations, outside the playable illustration.
 s+=line(64,1220,2536,1220,p['dark'],1)
 s+=txt(64,1260,'01 / SPATIAL STORY',17,p['cloth'],letter_spacing=3)+wrap(64,1297,d['story'],90,21,p['ink'],29)
 route=' / '.join(f'{c["type"]} → {c["to"]}' for c in climbs[:4])
 s+=txt(64,1432,'ROUTES',15,p['dark'],letter_spacing=2)+txt(64,1462,f"{len(d['platforms'])} raised landings · {sum(c['type']=='stairs' for c in climbs)} stairs · {sum(c['type']=='rope' for c in climbs)} ropes · {sum(c['type']=='ladder' for c in climbs)} ladders · {len(objects)} props",19,p['ink'])
 s+=txt(64,1500,'R = same-map recovery  ·  structural concept, not an exported collision mesh',17,p['dark'])
 s+=txt(1330,1260,'02 / DESTINATIONS & RESIDENTS',17,p['cloth'],letter_spacing=3)
 exits='   ·   '.join(f'P{j+1} {NAMES.get(n,n)}' for j,n in enumerate(d['neighbors']))
 s+=wrap(1330,1297,exits,100,18,p['ink'],25)
 npc_text='   ·   '.join(f'{j+1} {n}' for j,n in enumerate(npcs)) if npcs else ('Encounter: '+d['occupants'])
 s+=wrap(1330,1392,npc_text,109,18,p['ink'],25)
 s+=txt(1330,1500,d['source']+' · MAP ATLAS / SEPTEMBER 2026',16,p['dark'])
 d['climbs']=climbs;d['objects']=objects;d['portals']=portals;d['npcs']=npcs
 d['viewBox']=[0,0,W,H];d['recovery_position']={'x':238,'y':1100,'support':'street'}
 title=f'{d["name"]} — {d["landmark"]}'
 desc=d['story']+' Editable design layers: architecture, walkable ledges, supported climbs, jumpable props, numbered exits and NPCs.'
 return f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-labelledby="title desc">'+tag('title',ESC(title),id='title')+tag('desc',ESC(desc),id='desc')+s+'</svg>'

NAMES={}
if __name__=='__main__':
 maps=catalog();NAMES.update({d['id']:d['name'] for d in maps})
 for d in maps:
  folder=OUT/d['region'];folder.mkdir(parents=True,exist_ok=True)
  (folder/(d['id']+'.svg')).write_text(draw_map(d))
 (OUT/'manifest.json').write_text(json.dumps({'version':1,'status':'design proposals; not game implementation','maps':maps},indent=2,ensure_ascii=False)+'\n')
 print(f'Built {len(maps)} individually authored map SVGs in {OUT}')
