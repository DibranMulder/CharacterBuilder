"""Sea-built Tidekin architecture derived from designs/moodboards/tidekin.png.

No Human house, castle, tower, tree or interior renderer is used here. Configurations
name the large structures that distinguish all 39 maps, not just their prop colours.
"""
import math
from build import ESC, tag, rect, path, line, ellipse, txt, wrap, use, connector, TIDE_NPCS

P=dict(ink='#183f49',sky='#d7eee8',mist='#94c9c5',far='#6bafa8',stone='#afbea2',dark='#4e786c',top='#ead8aa',wood='#82644b',leaf='#668e59',accent='#db8250',cloth='#297989',water='#3faaa8',paper='#fff6df',bronze='#b89857',deep='#215c71')
# Design language and map-specific structures. Order is rear landmark, working deck, foreground activity.
FEATURES={
 'land':('wharf',['ferry','customs','crane'],'Twin ferry berths and a rigged customs wharf'),
 'cm':('wharf',['market','market','net'],'Coral canvas stalls over a working fish canal'),
 'lag':('lagoon',['gauge','nursery','ferry'],'A ring of tide-monitoring decks around open lagoon water'),
 'ka':('garden',['kelp','apothecary','kelp'],'Hanging kelp gardens, drying racks and a sea-glass mixing hut'),
 'dy':('lagoon',['diving','training','gong'],'Six pontoon stations beneath a diving boom'),
 'inn':('wharf',['lodge','hammock','kitchen'],'A thatched stilt lodge with over-water hammock balconies'),
 'caus':('citadel',['sluice','shellgate','crane'],'A broad tidal lock and shell-carved admission quay'),
 'gs':('citadel',['shellgate','guard','sluice'],'Open shell-rib gate pavilions above canal locks'),
 'rb':('citadel',['barracks','training','hammock'],'Reefguard boathouse, bunk rafts and practice decks'),
 'cw':('works',['cistern','sluice','cistern'],'Raised freshwater cisterns spilling into bronze sluices'),
 'ph':('citadel',['pearlhall','council','cascade'],'A fan-shell assembly pavilion overlooking falling seawater'),
 'tc':('citadel',['council','tidewheel','gong'],'An open sea-facing council deck and tidal listening wheel'),
 'dv':('submerged',['archive','glass','archive'],'Dry archive caissons with sea-glass observation walls'),
 'sc':('shrine',['ruin','crane','shellgate'],'A kelp-draped descent from the sea wall to drowned arches'),
 'fn':('shrine',['nave','sluice','ruin'],'Broken shell vaults and three sluice channels under water'),
 'cr':('shrine',['reliquary','archive','coral'],'Shell, wave and pearl stations inside a coral-encrusted ruin'),
 'ps':('shrine',['regulator','cascade','reliquary'],'An ancient pearl regulator in a submerged shell rotunda'),
 'path_001':('shoals',['sandbar','ferry','net'],'Fishing piers across three freshwater sandbars'),
 'site_001':('lagoon',['nursery','nursery','net'],'Woven nursery pens and shallow rescue pools'),
 'path_006':('shore',['gong','beached','net'],'Shell bells, beached hulls and shore-fishing rigs'),
 'site_006':('reef',['nursery','gong','coral'],'A protected shell-bell nursery on living reef shelves'),
 'path_011':('reef',['coral','survey','coral'],'Living coral overhangs and a rope-lashed survey station'),
 'site_011':('reef',['coral','rescue','crane'],'Three reef courts with rescue cradles and rigging'),
 'path_016':('garden',['kelp','cascade','sluice'],'Kelp terraces fed by stepped freshwater spillways'),
 'site_016':('lagoon',['nest','survey','coral'],'A crowncrab nesting lagoon seen from a ring of hides'),
 'path_021':('mangrove',['mangrove','rootcamp','net'],'Woven root bridges and fishing huts among mangroves'),
 'site_021':('mangrove',['mangrove','rescue','winch'],'Root buttresses, rigging spools and snapper observation decks'),
 'path_026':('submerged',['ruin','glass','lanterns'],'Roofless tide halls with sea-glass lantern galleries'),
 'site_026':('submerged',['nave','lanterns','glass'],'A dry observation gallery beside submerged glyph arches'),
 'path_031':('reef',['bridge','gong','beacon'],'Current-spanning dock bridges and three musical beacons'),
 'site_031':('lagoon',['song','council','gong'],'An open-water whale-song amphitheater on moored decks'),
 'path_036':('works',['sluice','cistern','crane'],'Bronze floodgates and exposed waterworks on driven piles'),
 'site_036':('works',['contacts','sluice','beacon'],'Segmented eel contacts between open tidal gates'),
 'return_061':('storm',['breakwater','rescue','beacon'],'Shell storm screens and a weather-rigged breakwater'),
 'return_066':('blackwater',['reefspires','rescue','lanterns'],'Dark coral teeth around pearl-lit refuge pontoons'),
 'return_071':('works',['bellows','sluice','bellows'],'Shell pressure bellows and relief decks above the sea'),
 'return_076':('vortex',['vortex','crane','beacon'],'Mooring rings and storm-tethered decks around a maelstrom'),
 'return_101':('ancient',['prism','reliquary','coral'],'Fossil shell plates and pearl-glass survey shrines'),
 'return_116':('vortex',['confluence','regulator','contacts'],'Three tidal channels converging beneath an ancient shell gate'),
}

def spiral(x,y,r,col=P['bronze'],sw=4):
 pts=[]
 for j in range(65):
  a=j/64*math.pi*3.9;rr=r*(1-j/72);pts.append((x+rr*math.cos(a),y+rr*math.sin(a)))
 return path('M'+'L'.join(f'{xx:.1f} {yy:.1f}' for xx,yy in pts),stroke=col,sw=sw)

def kelp(x,y,h=100):
 s=path(f'M{x} {y}q-23 {-h*.35} 2 {-h*.65}t0 {-h*.35}',stroke=P['leaf'],sw=5)
 for j in range(4):
  yy=y-h*j/5;side=1 if j%2 else -1
  s+=path(f'M{x} {yy}q{side*45} -4 {side*38} -35q{-side*39} 2 {-side*38} 35Z',P['leaf'],P['dark'],1)
 return s

def tide_symbols():
 p=P;i=p['ink'];d={}
 d['sea-basket']=path('M9 48Q50 35 91 48L80 92H22Z',p['top'],i)+''.join(line(17,y,85,y,p['wood'],3) for y in [58,68,78,87])+path('M27 44q-5-50 44 0',stroke=p['wood'],sw=5)+spiral(50,66,15,i,2)
 d['sea-crate']=rect(7,28,86,68,p['wood'],i,3,3)+''.join(line(12,y,88,y,p['top'],2) for y in [38,53,70,86])+line(20,28,20,96,p['bronze'],7)+line(80,28,80,96,p['bronze'],7)+spiral(50,65,18,p['top'],3)
 d['sea-pearl']=ellipse(50,60,30,29,p['paper'],p['bronze'],3)+ellipse(40,48,10,6,'#ffffff')+path('M17 83q34 23 67 0',stroke=p['cloth'],sw=7)
 d['sea-lantern']=path('M35 22q15-33 30 0',stroke=p['bronze'],sw=4)+ellipse(50,58,30,35,p['cloth'],i,3)+ellipse(50,58,21,25,'#8be4d3')+line(50,26,50,91,p['bronze'],4)+rect(23,23,54,9,p['bronze'],i,2,4)+rect(25,86,50,8,p['bronze'],i,2,4)
 d['sea-banner']=line(16,4,16,98,p['wood'],5)+path('M20 10H91V84L56 74L20 88Z',p['cloth'],i,2)+spiral(56,43,22,p['top'],4)
 d['sea-buoy']=line(49,10,49,95,p['wood'],4)+ellipse(50,61,27,30,p['accent'],i,3)+rect(24,50,52,12,p['top'],i,2,4)+path('M49 12l36 4-36 22',p['cloth'],i,2)
 d['sea-net']=line(12,9,12,97,p['wood'],6)+line(88,9,88,97,p['wood'],6)+path('M12 19Q50 34 88 19L79 83Q50 98 21 83Z','none',p['top'],3)+''.join(path(f'M{xx} 22L{xx+10} 85M18 {xx}Q50 {xx+14} 84 {xx}',stroke=p['top'],sw=2) for xx in [27,42,57,72])
 d['sea-kelp']=rect(9,72,82,25,p['wood'],i,3,4)+kelp(35,73,61)+kelp(66,75,54)
 d['sea-shell']=path('M50 92Q-8 72 12 27Q27 4 46 23Q70-4 89 24Q116 65 50 92Z',p['top'],p['bronze'],3)+''.join(path(f'M50 90Q{xx} 50 {xx} 24',stroke=p['wood'],sw=2) for xx in [22,39,58,76])
 d['sea-seat']=path('M9 56Q50 38 91 56L83 76H17Z',p['stone'],i,3)+line(26,76,21,98,p['wood'],7)+line(75,76,81,98,p['wood'],7)+spiral(50,58,14,p['cloth'],2)
 d['sea-table']=rect(4,48,92,12,p['wood'],i,3,5)+line(20,60,18,96,i,6)+line(80,60,83,96,i,6)+use('sea-shell',54,13,36,36)+use('sea-pearl',16,16,33,33)
 d['sea-chest']=rect(7,38,86,58,p['wood'],i,3,7)+path('M7 39Q50-2 93 39Z',p['cloth'],i,3)+line(23,28,23,94,p['bronze'],6)+line(78,27,78,94,p['bronze'],6)+spiral(50,64,15,p['top'],3)
 d['sea-gauge']=rect(29,5,43,91,p['top'],i,3,4)+''.join(line(33,yy,55 if yy%20 else 66,yy,p['cloth'],3) for yy in range(15,88,10))+rect(64,52,18,11,p['accent'],i,2)
 d['sea-valve']=ellipse(50,50,37,37,p['cloth'],p['bronze'],6)+spiral(50,50,27,p['top'],3)+''.join(line(50,50,50+30*math.cos(a),50+30*math.sin(a),p['bronze'],5) for a in [0,2.1,4.2])+rect(38,84,24,12,p['wood'],i,2)
 d['sea-scrolls']=rect(8,8,84,90,p['wood'],i,3,5)+''.join(rect(17,y,66,6,p['bronze'],i,1)+''.join(ellipse(x,y-8,7,10,p['top'],i,2) for x in [26,45,64,79]) for y in [33,61,89])
 d['sea-gong']=path('M10 96V8H90V96',stroke=p['wood'],sw=7)+line(50,10,50,22,p['bronze'],3)+ellipse(50,49,28,29,p['bronze'],i,3)+spiral(50,49,18,p['cloth'],3)
 d['sea-bottles']=use('sea-table',0,0)+''.join(path(f'M{x} 8v12q-9 7-7 19h21q3-12-7-19V8Z',p['water'],p['bronze'],2) for x in [23,53,78])
 return ''.join(tag('symbol',s,id='prop-'+name,viewBox='0 0 100 100') for name,s in d.items())

KITS={
 'wharf':['sea-crate','sea-basket','sea-net','sea-buoy','sea-chest','sea-seat'],
 'lagoon':['sea-basket','sea-buoy','sea-shell','sea-seat','sea-crate','sea-gauge'],
 'garden':['sea-kelp','sea-bottles','sea-basket','sea-table','sea-crate','sea-scrolls'],
 'citadel':['sea-banner','sea-seat','sea-chest','sea-pearl','sea-table','sea-shell'],
 'works':['sea-valve','sea-gauge','sea-crate','sea-table','sea-chest','sea-buoy'],
 'submerged':['sea-scrolls','sea-lantern','sea-chest','sea-table','sea-pearl','sea-seat'],
 'shrine':['sea-shell','sea-scrolls','sea-pearl','sea-seat','sea-chest','sea-lantern'],
 'mangrove':['sea-net','sea-basket','sea-crate','sea-kelp','sea-seat','sea-buoy'],
 'shoals':['sea-net','sea-basket','sea-crate','sea-buoy','sea-gauge','sea-shell'],
 'shore':['sea-gong','sea-shell','sea-basket','sea-crate','sea-seat','sea-net'],
 'reef':['sea-shell','sea-crate','sea-buoy','sea-basket','sea-seat','sea-gauge'],
 'storm':['sea-crate','sea-net','sea-gauge','sea-buoy','sea-chest','sea-banner'],
 'blackwater':['sea-lantern','sea-gauge','sea-crate','sea-buoy','sea-chest','sea-seat'],
 'vortex':['sea-valve','sea-buoy','sea-crate','sea-gauge','sea-chest','sea-pearl'],
 'ancient':['sea-pearl','sea-shell','sea-scrolls','sea-chest','sea-seat','sea-crate']}


def boat(x,y,w=350):
 s=path('M0 90Q175 170 350 90L301 150Q157 207 36 140Z',P['wood'],P['ink'],5)+path('M11 96Q180 160 338 97',stroke=P['top'],sw=6)
 s+=line(175,-80,175,126,P['wood'],7)+path('M185-70Q250-35 318 68H185Z',P['top'],P['bronze'],3)+path('M163-52L82 74H163Z',P['cloth'],P['ink'],3)+spiral(224,42,22,P['cloth'],3)
 s+=use('sea-crate',90,81,58,58)+use('sea-basket',218,79,54,54)
 return tag('g',s,transform=f'translate({x} {y}) scale({w/350})',data_feature='moored-sailboat')


def canopy(x,y,w,h,kind='awning'):
 # x,y is the occupied deck. Roof remains broad, low and organic.
 i=P['ink'];s=''
 for xx in [x+24,x+w-24]:s+=line(xx,y-h*.74,xx,y,P['wood'],11)+line(xx-9,y-22,xx+9,y-22,P['top'],5)
 if kind=='shell':
  s+=path(f'M{x-16} {y-h*.65}Q{x+w*.5} {y-h*1.35} {x+w+16} {y-h*.65}Q{x+w*.5} {y-h*.40} {x-16} {y-h*.65}Z',P['top'],P['bronze'],4)
  for f in [.15,.3,.5,.7,.85]:s+=path(f'M{x+w*.5} {y-h*1.03}Q{x+w*f} {y-h*.85} {x+w*f} {y-h*.56}',stroke=P['bronze'],sw=2)
 else:
  color=P['leaf'] if kind=='thatch' else P['accent']
  s+=path(f'M{x-26} {y-h*.62}Q{x+w*.5} {y-h*.7} {x+w*.5} {y-h}Q{x+w*.6} {y-h*.70} {x+w+26} {y-h*.62}L{x+w} {y-h*.49}Q{x+w*.5} {y-h*.62} {x} {y-h*.49}Z',color,i,3)
  for xx in range(int(x+10),int(x+w),25):s+=line(xx,y-h*.62,xx-10,y-h*.5,P['top'],2)
 s+=line(x+23,y-h*.5,x+w-23,y-h*.5,P['wood'],7)
 s+=use('sea-lantern',x+w-67,y-h*.51,47,61)
 return s


def coral(x,y,w,h,dark=False):
 col=P['deep'] if dark else P['accent'];s=''
 for f in [.15,.5,.82]:
  xx=x+w*f
  s+=path(f'M{xx} {y}Q{xx-w*.1} {y-h*.25} {xx} {y-h*.92}M{xx} {y-h*.42}q{-w*.22} {-h*.08} {-w*.19} {-h*.35}M{xx} {y-h*.60}q{w*.23} {-h*.04} {w*.18} {-h*.28}',stroke=P['ink'],sw=17)
  s+=path(f'M{xx} {y}Q{xx-w*.1} {y-h*.25} {xx} {y-h*.92}M{xx} {y-h*.42}q{-w*.22} {-h*.08} {-w*.19} {-h*.35}M{xx} {y-h*.60}q{w*.23} {-h*.04} {w*.18} {-h*.28}',stroke=col,sw=11)
 return s


def structure(kind,x,y,w,h):
 """A complete working structure attached to a deck; no freestanding castle assets."""
 p=P;i=p['ink'];s=''
 if kind in ['customs','market','apothecary','lodge','guard','barracks','rootcamp','kitchen']:
  s+=rect(x+20,y-h*.58,w-40,h*.58,p['wood'],i,3,5)
  for xx in range(int(x+35),int(x+w-25),35):s+=line(xx,y-h*.54,xx,y-8,p['top'],2)
  s+=canopy(x,y,w,h,'thatch' if kind in ['lodge','rootcamp','barracks'] else 'awning')
  for f in [.2,.64]:s+=rect(x+w*f,y-h*.41,w*.17,h*.25,p['deep'],p['bronze'],4,4)
  s+=use('sea-banner',x+w*.44,y-h*.5,w*.18,h*.42)
  if kind in ['market','kitchen','apothecary']:s+=use('sea-table',x+w*.15,y-110,170,110)+use('sea-bottles' if kind=='apothecary' else 'sea-basket',x+w*.61,y-80,88,80)
  if kind in ['lodge','barracks']:s+=structure('hammock',x+40,y-10,w-80,h*.35)
 elif kind in ['pearlhall','council','reliquary','song']:
  s+=canopy(x,y,w,h,'shell')
  s+=rect(x+w*.19,y-30,w*.62,30,p['stone'],i,3,8)
  s+=use('sea-pearl' if kind!='song' else 'sea-gong',x+w*.38,y-h*.53,w*.24,h*.46)
  s+=use('sea-banner',x+w*.07,y-h*.65,w*.16,h*.54)+use('sea-banner',x+w*.78,y-h*.65,w*.16,h*.54)
  s+=kelp(x+12,y,h*.54)+kelp(x+w-15,y,h*.46)
 elif kind in ['shellgate','ruin','nave','glass']:
  s+=path(f'M{x+20} {y}V{y-h*.5}Q{x+w*.5} {y-h*1.18} {x+w-20} {y-h*.5}V{y}',stroke=p['bronze'] if kind=='shellgate' else p['stone'],sw=40)
  s+=path(f'M{x+20} {y}V{y-h*.5}Q{x+w*.5} {y-h*1.18} {x+w-20} {y-h*.5}V{y}',stroke=p['top'],sw=9)
  for f in [.18,.36,.64,.82]:
   xx=x+w*f;s+=spiral(xx,y-h*(.62 if f in [.18,.82] else .81),22,p['cloth'],3)
  if kind=='glass':s+=path(f'M{x+39} {y-15}V{y-h*.5}Q{x+w*.5} {y-h} {x+w-39} {y-h*.5}V{y-15}Z',p['water'],p['bronze'],4,opacity='.45')
  if kind in ['ruin','nave']:
   s+=kelp(x+40,y-h*.25,h*.54)+coral(x+w*.68,y,w*.27,h*.4)
   s+=path(f'M{x+w*.46} {y-h*.85}l25 25-18 30 32 12',stroke=p['ink'],sw=4)
  else:s+=use('sea-banner',x+w*.42,y-h*.79,w*.18,h*.6)
 elif kind in ['crane','winch','diving','rescue','survey','beacon']:
  s+=line(x+40,y,x+40,y-h,p['wood'],15)+line(x+40,y-h,x+w-20,y-h*.83,p['wood'],14)+line(x+45,y-h*.43,x+w*.6,y-h*.9,p['bronze'],7)
  s+=line(x+w*.82,y-h*.84,x+w*.82,y-h*.17,p['top'],5)
  s+=ellipse(x+40,y-h,16,16,p['bronze'],i,3)
  s+=use('sea-lantern' if kind=='beacon' else 'sea-basket',x+w*.65,y-h*.28,w*.30,h*.26)
  s+=use('sea-crate',x+70,y-88,88,88)
  if kind=='diving':s+=line(x+w*.15,y-h*.6,x+w*.6,y-h*.6,p['wood'],16)
  if kind=='rescue':s+=structure('hammock',x+40,y-30,w*.6,h*.25)
 elif kind in ['cistern','bellows','sluice','contacts','tidewheel','regulator','confluence']:
  if kind in ['cistern','bellows']:
   s+=rect(x+w*.1,y-h*.8,w*.8,h*.7,p['cloth'],i,4,50)
   for yy in [y-h*.66,y-h*.40,y-h*.15]:s+=rect(x+w*.06,yy,w*.88,14,p['bronze'],i,2,6)
   s+=ellipse(x+w*.5,y-h*.8,w*.4,h*.10,p['water'],p['bronze'],5)
   if kind=='bellows':
    for xx in range(int(x+w*.2),int(x+w*.83),26):s+=line(xx,y-h*.65,xx,y-h*.20,p['top'],3)
  elif kind in ['sluice','contacts']:
   s+=line(x+35,y-h,x+35,y,p['wood'],14)+line(x+w-35,y-h,x+w-35,y,p['wood'],14)+line(x+35,y-h,x+w-35,y-h,p['wood'],16)
   for xx in range(int(x+70),int(x+w-45),40):s+=line(xx,y-h*.84,xx,y-30,p['bronze'],12)
   s+=rect(x+55,y-h*.45,w-110,17,p['cloth'],i,3)
  else:
   r=min(w*.39,h*.43);cx=x+w*.5;cy=y-h*.5
   s+=ellipse(cx,cy,r,r,p['deep'],p['bronze'],14)+ellipse(cx,cy,r*.73,r*.73,p['water'],p['top'],5)+spiral(cx,cy,r*.61,p['top'],9)
   for a in [0,2.1,4.2]:s+=line(cx+math.cos(a)*r,cy+math.sin(a)*r,cx+math.cos(a)*r*1.15,cy+math.sin(a)*r*1.15,p['accent'],15)
   if kind in ['regulator','confluence']:s+=use('sea-pearl',cx-r*.35,cy-r*.35,r*.7,r*.7)
  s+=use('sea-valve',x+w*.35,y-h*.49,w*.3,h*.38)
 elif kind in ['kelp','net','lanterns','training','hammock']:
  s+=line(x+12,y,x+12,y-h,p['wood'],9)+line(x+w-12,y,x+w-12,y-h,p['wood'],9)+path(f'M{x+12} {y-h}Q{x+w*.5} {y-h*.72} {x+w-12} {y-h}',stroke=p['top'],sw=5)
  if kind=='hammock':s+=path(f'M{x+12} {y-h*.75}Q{x+w*.5} {y+h*.15} {x+w-12} {y-h*.75}Q{x+w*.5} {y-h*.1} {x+12} {y-h*.75}Z',p['cloth'],p['top'],3)
  else:
   for f in [.17,.4,.65]:
    xx=x+w*f
    if kind=='kelp':s+=kelp(xx,y-h*.25,h*.58)
    else:s+=use('sea-lantern' if kind=='lanterns' else ('sea-banner' if kind=='training' else 'sea-net'),xx,y-h*.72,w*.22,h*.66)
 elif kind=='archive':
  s+=canopy(x,y,w,h,'shell')
  for f in [.08,.39,.7]:s+=use('sea-scrolls',x+w*f,y-h*.59,w*.24,h*.58)
 elif kind in ['ferry','beached']:s+=boat(x,y-w*.40,w)
 elif kind=='mangrove':
  s+=path(f'M{x+w*.46} {y-h*.7}Q{x+w*.56} {y-h*.20} {x+w*.15} {y}M{x+w*.5} {y-h*.5}Q{x+w*.6} {y-h*.12} {x+w*.89} {y}',stroke=p['wood'],sw=28)
  s+=path(f'M{x+w*.5} {y-h*.9}Q{x+w*.25} {y-h*.35} {x} {y}M{x+w*.51} {y-h*.6}Q{x+w*.8} {y-h*.4} {x+w} {y}',stroke=p['wood'],sw=12)
  for f,yy in [(.19,.75),(.48,.96),(.78,.75)]:
   s+=ellipse(x+w*f,y-h*yy,w*.31,h*.09,p['leaf'],p['dark'],4)
   s+=path(f'M{x+w*f} {y-h*yy}q-10 90 18 150',stroke=p['leaf'],sw=4)
 elif kind in ['coral','reefspires','prism','nest','sandbar','breakwater']:
  s+=path(f'M{x} {y}L{x+w*.12} {y-h*.42}Q{x+w*.3} {y-h*.9} {x+w*.48} {y-h*.48}L{x+w*.69} {y-h*.84}L{x+w*.94} {y-h*.37}L{x+w} {y}Z',p['deep'] if kind=='reefspires' else p['stone'],i,4)
  if kind in ['prism','nest','sandbar','breakwater']:
   for f in [.08,.38,.69]:s+=use('sea-pearl' if kind=='prism' else 'sea-shell',x+w*f,y-h*.57,w*.25,h*.52)
  else:s+=coral(x+w*.1,y,w*.8,h*.8,kind=='reefspires')
 elif kind in ['cascade','bridge']:
  s+=path(f'M{x} {y}V{y-h*.6}Q{x+w*.5} {y-h} {x+w} {y-h*.6}V{y}H{x+w*.8}V{y-h*.38}Q{x+w*.5} {y-h*.65} {x+w*.2} {y-h*.38}V{y}Z',p['stone'],p['dark'],4)
  s+=kelp(x+w*.12,y-h*.12,h*.5)+kelp(x+w*.82,y-h*.12,h*.46)
 elif kind=='vortex':
  for j in range(6):s+=ellipse(x+w*.5,y-h*.5,w*(.47-j*.064),h*(.46-j*.06),'none',p['top'] if j%2 else p['cloth'],9)
 elif kind=='nursery':
  s+=ellipse(x+w*.5,y-30,w*.49,h*.25,p['cloth'],p['wood'],8)+ellipse(x+w*.5,y-37,w*.43,h*.18,p['water'],p['top'],3)
  for f in [.1,.35,.65,.9]:s+=line(x+w*f,y-20,x+w*f,y-h*.65,p['wood'],7)
  s+=path(f'M{x+w*.1} {y-h*.65}Q{x+w*.5} {y-h*.35} {x+w*.9} {y-h*.65}',stroke=p['top'],sw=3)
 elif kind in ['gong','gauge']:s+=use('sea-gong' if kind=='gong' else 'sea-gauge',x+w*.2,y-h,w*.6,h)
 else:raise ValueError('Unillustrated Tidekin feature: '+kind)
 return tag('g',s,data_feature=kind)


def deck(a,ground,mode='dock',layer='all'):
 x,y,w=a['x'],a['y'],a['w'];p=P;i=p['ink'];s=''
 if mode=='reef':
  s+=path(f'M{x} {y}H{x+w}L{x+w-20} {y+38}Q{x+w*.5} {y+68} {x+15} {y+35}Z',p['stone'],p['dark'],3)
  for f in [.28,.73]:
   xx=x+w*f
   s+=path(f'M{xx+15} {ground+100}Q{xx-28} {(ground+y)/2} {xx} {y+33}',stroke=p['dark'],sw=43)
   s+=path(f'M{xx+15} {ground+100}Q{xx-28} {(ground+y)/2} {xx} {y+33}',stroke=p['stone'],sw=35)
   s+=path(f'M{xx} {y+66}q-25 25-40 35m42 24q25-18 42-17',stroke=p['stone'],sw=16)
  s+=kelp(x+w*.36,min(ground+100,y+170),min(130,ground-y+30))
 else:
  for xx in [x+20,x+w-20]:
   s+=line(xx,y+15,xx,ground+100,p['wood'],11)+line(xx-9,y+40,xx+9,y+40,p['top'],5)
   s+=path(f'M{xx-8} {ground+50}q-14 13 1 25m5-12q18 15-2 25',stroke=p['leaf'],sw=6)
  s+=path(f'M{x+30} {y+24}l60 100M{x+w-30} {y+24}l-60 100',stroke=p['wood'],sw=7)
 if layer=='supports':return tag('g',s,data_support=mode)
 if layer=='top':s=''
 s+=rect(x,y,w,23,p['wood'],i,3,3)+line(x,y-3,x+w,y-3,p['top'],8)
 for xx in range(int(x+10),int(x+w),24):s+=line(xx,y+2,xx,y+20,p['bronze'],2)
 # Mooring posts and sagging kelp rope replace crenellations and grass-topped masonry.
 for xx in [x+14,x+w-14]:s+=line(xx,y-53,xx,y+10,p['wood'],7)+ellipse(xx,y-55,7,5,p['bronze'],i,1)
 if w>400:s+=path(f'M{x+14} {y-50}Q{x+w*.5} {y-16} {x+w-14} {y-50}',stroke=p['top'],sw=3)
 return tag('g',s,id=a['id'],data_walkable='true',data_material='reef-and-driftwood' if mode=='reef' else 'rope-lashed-piled-dock')


def resident(x,y,name,n):
 p=P;s=ellipse(x,y-5,24,7,p['deep'],opacity='.3')
 s+=path(f'M{x-20} {y-40}Q{x} {y-58} {x+20} {y-40}L{x+17} {y-13}H{x-17}Z',p['cloth'],p['ink'],2)
 for xx in [x-11,x+11]:s+=path(f'M{xx} {y-15}l-5 9-12 3h30',stroke=p['leaf'],sw=6)
 s+=ellipse(x,y-61,27,19,p['leaf'],p['ink'],2)
 for xx in [x-17,x+17]:s+=ellipse(xx,y-76,10,11,p['leaf'],p['ink'],2)+ellipse(xx+2,y-77,5,6,p['top'],p['ink'],2)
 s+=path(f'M{x-12} {y-57}q12 8 24 0',stroke=p['ink'],sw=2)+ellipse(x,y-117,16,16,p['paper'],p['ink'],2)+txt(x,y-111,str(n),17,p['ink'],text_anchor='middle')
 return tag('g',tag('title',ESC(name))+s,data_npc=name,data_lineage='Tidekin')


def draw_tidekin(d,names):
 biome,features,hook=FEATURES[d['short']];p=P;i=p['ink']
 deep=biome in ['shrine','submerged','blackwater'];portrait=biome=='shrine'
 w,h=(1800,2480) if portrait else ((2800,1720) if biome in ['wharf','shoals','shore'] else (2600,1780))
 ground=h-475;floor={'id':'street','x':70,'y':ground,'w':w-140}
 sx=(w-140)/2460;sy=(ground-300)/800
 d['platforms']=[dict(a,x=round(70+(a['x']-70)*sx),y=round(300+(a['y']-300)*sy),w=round(a['w']*sx)) for a in d['platforms']]
 d.update(viewBox=[0,0,w,h],floor=floor,scene_bounds=[40,195,w-80,ground-80],layout='Tidekin sea-built '+biome,moodboard='designs/moodboards/tidekin.png',visual_features=features,landmark=hook)
 s=rect(0,0,w,h,p['paper'])+rect(0,0,w,13,i)
 s+=txt(60,61,'TIDEKIN SEA / '+d['group'].upper(),18,p['cloth'],letter_spacing=3)+txt(60,119,d['name'],45,i,'Georgia, serif')
 s+=wrap(60,157,hook,100 if w>2000 else 73,21,p['dark'],27)+txt(w-65,63,f'{d["ordinal"]:02d} / 39',25,i,text_anchor='end')
 s+=txt(w-65,108,d['access']+' access · '+d['levels'],18,i,text_anchor='end')
 s+=tag('defs',tide_symbols()+tag('linearGradient',tag('stop',offset='0%',stop_color=p['deep'] if deep else p['sky'])+tag('stop',offset='100%',stop_color='#123f55' if deep else p['water']),id='sea',x2='0',y2='1')+tag('clipPath',rect(40,195,w-80,ground-80,'white',rx=22),id='tide-scene'))
 world=rect(40,195,w-80,ground-80,'url(#sea)')
 waterline=340 if deep else 660
 if not deep:
  # Broken reef islets on the horizon; most of the frame is navigable-looking open sea.
  for xx,hh in [(150,110),(650,175),(w-560,210),(w-230,150)]:
   world+=path(f'M{xx} 720l35-60 22{-hh} 70-30 41 {hh+75} 85 65Z',p['mist'],None)
  world+=ellipse(w-220,336,80,80,'#fff1c2',opacity='.8')
  world+=rect(40,waterline,w-80,ground-waterline+115,p['water'],opacity='.65')
 else:
  for xx in [180,w*.45,w*.72]:world+=path(f'M{xx} 195l100 0 240 {ground-195}h-410Z','#6dc5b4',opacity='.10')
  for j in range(28):world+=ellipse(100+(j*157)%(w-200),330+(j*113)%int(ground-410),5+j%5,6+j%5,'none','#a4d9bd',2,opacity='.35')
 for yy in range(waterline+30,ground+100,90):
  for xx in range(90+(yy%120),w-120,270):world+=path(f'M{xx} {yy}q45-9 95 0m14 0h38',stroke=p['top'] if not deep else p['far'],sw=3,opacity='.34')
 if biome in ['storm','blackwater','vortex']:
  world+=path(f'M40 545Q{w*.2} 255 {w*.4} 530Q{w*.6} 275 {w*.75} 480Q{w*.9} 310 {w-40} 475V675H40Z',p['deep'],opacity='.32')
 if biome=='mangrove':
  for xx in [90,w*.39,w*.74]:world+=structure('mangrove',xx,ground-65,w*.23,ground-360)
 elif biome in ['reef','ancient','blackwater','shoals','shore']:
  for xx in [110,w*.45,w*.81]:world+=structure('reefspires' if biome=='blackwater' else 'coral',xx,ground+40,w*.15,380)
 elif biome in ['citadel','works']:
  # Broad reef-grown terraces and visible spillways, never twin castle towers.
  for xx,yy in [(w*.08,760),(w*.48,680),(w*.8,800)]:
   world+=structure('cascade',xx,ground+80,w*.16,ground-yy+180)
   world+=path(f'M{xx+w*.07} {yy}q30 85 5 {ground-yy+100}',stroke='#b9ead4',sw=28,opacity='.75')
 reef=biome in ['reef','shoals','ancient','blackwater','shrine']
 world+=deck(floor,ground,layer='supports')
 for a in d['platforms']:world+=deck(a,ground,'reef' if reef else 'dock',layer='supports')
 if biome=='vortex':
  for j in range(3):
   xx=w*(.23+j*.27)
   world+=path(f'M{xx} 725Q{xx+95} 940 {w*.53} {ground+50}',stroke=p['cloth'],sw=38,opacity='.55')+path(f'M{xx} 725Q{xx+95} 940 {w*.53} {ground+50}',stroke=p['top'],sw=5,opacity='.65')
 # Main silhouettes are individually selected, anchored to substantial actual landings.
 candidates=sorted((a for a in d['platforms'] if a['w']>200*sx and a['y']>430),key=lambda a:a['w'],reverse=True)
 occupied=[]
 for j,kind in enumerate(features):
  a=candidates[j%len(candidates)];ww=min(a['w']-35,620*sx);hh=min(300 if not portrait else 340,a['y']-220)
  x=a['x']+(a['w']-ww)/2;y=a['y']
  if kind=='vortex':x,y,ww,hh=w*.31,ground-85,w*.42,320
  world+=structure(kind,x,y,ww,hh);occupied.append(a['id'])
 if biome in ['wharf','lagoon','shore']:
  world+=boat(w*.37,ground-105,360*sx)
 if biome=='garden':
  for xx in [130,w*.52,w*.86]:world+=structure('kelp',xx,ground-30,210,290)
 # Public return is a thin boardwalk on piles, with water visibly passing below it.
 world+=deck(floor,ground,layer='top')
 for a in sorted(d['platforms'],key=lambda a:a['y'],reverse=True):world+=deck(a,ground,'reef' if reef else 'dock',layer='top')
 climbs=[]
 for j,a in enumerate(d['platforms']):
  below=[b for b in d['platforms']+[floor] if b['y']>a['y'] and min(a['x']+a['w'],b['x']+b['w'])-max(a['x'],b['x'])>65]
  lower=min(below,key=lambda b:b['y']);g,c=connector(a,lower,j,p);world+=g;climbs.append(c)
 objects=[];kit=KITS[biome];d['props']=kit;d['shape']='sea-'+biome
 for j,a in enumerate(d['platforms']+[floor]):
  count=8 if a['id']=='street' else 2
  for k in range(count):
   size=min(72 if a['id']!='street' else 92,a['y']-215,a['w']*.29)
   x=a['x']+20+(a['w']-size-40)*(k/(count-1));y=a['y']-size-8;kind=kit[(j*2+k)%len(kit)]
   world+=use(kind,x,y,size,size)
   objects.append({'type':kind,'surface':a['id'],'x':x,'y':y,'w':size,'h':size,'jumpable':kind in ['sea-crate','sea-basket','sea-seat','sea-chest','sea-table','sea-scrolls','sea-shell']})
 portals=[];positions=[(150,ground,'street'),(w-150,ground,'street')]+[(a['x']+a['w']*.54,a['y'],a['id']) for a in d['platforms']]
 for j,dest in enumerate(d['neighbors']):
  x,y,support=positions[j]
  if portrait:
   onward=dest.endswith({'sc':'_fn','fn':'_cr','cr':'_ps','ps':'_cr'}[d['short']]);a=max(d['platforms'],key=lambda a:a['y']) if onward else min(d['platforms'],key=lambda a:a['y'])
   x,y,support=a['x']+a['w']*.54,a['y'],a['id']
  world+=path(f'M{x-30} {y-15}V{y-113}Q{x} {y-152} {x+30} {y-113}V{y-15}',stroke='#f5d985',sw=7)+ellipse(x,y-8,39,10,'#ffe3a0',p['bronze'],2)
  world+=rect(x-27,y-180,54,30,p['paper'],i,2,15)+txt(x,y-159,f'P{j+1}',17,i,text_anchor='middle')
  portals.append({'label':f'P{j+1}','to':dest,'x':x,'y':y,'support':support})
 npcs=TIDE_NPCS.get(d['short'],[])
 for j,name in enumerate(npcs):world+=resident(430+j*(w-900)/max(1,len(npcs)-1),ground-4,name,j+1)
 world+=use('sea-lantern',232,ground-90,67,82)+txt(265,ground-100,'R',19,p['paper'] if deep else i,text_anchor='middle')
 if deep:world+=rect(65,213,700 if w>2000 else 620,36,p['deep'],None,rx=18,opacity='.9')+txt(85,238,'Dry inspection galleries · submerged ruins beyond the sea glass',17,p['paper'])
 s+=tag('g',world,id='tidekin-seascape',clip_path='url(#tide-scene)',data_architecture='sea-built',data_biome=biome)
 fy=ground+163;s+=line(60,fy-35,w-60,fy-35,p['dark'],1)
 s+=txt(60,fy,'01 / LIFE WITH THE TIDES',17,p['cloth'],letter_spacing=2)
 col=(w-160)/2
 s+=wrap(60,fy+34,d['story'],int(col/11),20,i,28)
 s+=txt(60,fy+166,f"{len(d['platforms'])} landings · stairs / ropes / ladders · {len(objects)} props",18,i)
 s+=txt(60,fy+210,'Shell · kelp rope · sea glass · driftwood · verdigris bronze',16,p['dark'])
 s+=txt(w/2+25,fy,'02 / DESTINATIONS & RESIDENTS',17,p['cloth'],letter_spacing=2)
 s+=wrap(w/2+25,fy+34,' · '.join(q['label']+' '+names[q['to']] for q in portals),int(col/10),18,i,25)
 people=' · '.join(str(j+1)+' '+n for j,n in enumerate(npcs)) if npcs else d['occupants']
 s+=wrap(w/2+25,fy+143,people,int(col/10),18,i,25)
 s+=txt(60,h-34,'REFERENCE: TIDEKIN MOODBOARD · DESIGN-0014 / 0022 / 0023 · EDITABLE SVG DESIGN',15,p['dark'])
 d.update(climbs=climbs,objects=objects,portals=portals,npcs=npcs,recovery_position={'x':265,'y':ground,'support':'street'},architecture_anchors=occupied)
 return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-labelledby="title desc">'+tag('title',ESC(d['name']+' — '+hook),id='title')+tag('desc',ESC(d['story']),id='desc')+s+'</svg>'


def overview_icon(x,y,d,p,scale=1):
 biome,features,_=FEATURES[d['short']]
 s=ellipse(0,18,144,36,P['water'],P['far'],2)
 a={'id':'mini-dock','x':-125,'y':-2,'w':250}
 # No IDs on repeated miniatures.
 s+=deck(a,30).replace('id="mini-dock"','')
 s+=structure(features[0],-100,-5,200,150)
 if biome in ['wharf','lagoon']:s+=boat(45,-10,115)
 return tag('g',s,transform=f'translate({x} {y}) scale({scale})',data_tidekin_icon=features[0])
