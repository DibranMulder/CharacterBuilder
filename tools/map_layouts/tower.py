"""Portrait cutaways for the three connected Human tower interiors."""
from build import PAL, ESC, tag, rect, path, line, ellipse, txt, wrap, use, props, surface, npc_marker, HUMAN_NPCS

CONFIG = {
 'tower': (1400, 2800, 7, 'The keeper’s door → bell chamber → upper stair',
           'Enter at the foot of the tower. Climb around the bell counterweight through stores, the keeper’s room and the ringing gallery. The upper door continues into Winding Stair.'),
 'stair': (1400, 3500, 10, 'A continuous climb inside the tower shaft',
           'Alternating stair flights wrap the central shaft. Window seats and lamplighter shelves punctuate the ascent; maintenance ladders and a bell rope offer shorter routes. Reach the Solar through the highest door.'),
 'solar': (1600, 2400, 5, 'Upper chambers → library mezzanine → lantern crown',
           'Arrive beneath the private rooms, then climb past the library and ward table to Lyra’s sunlit chamber. A final stair reaches the telescope beneath the glazed dome. Return through the lower tower door.')}


def draw_tower(d, names):
 w,h,n,subtitle,story=CONFIG[d['id']];p=PAL[d['region']];i=p['ink'];ground=h-510
 # A narrow, enclosed cylinder is the map, not a tower behind an outdoor platform grid.
 left=150;right=w-150;mid=w/2
 floor={'id':'street','x':left,'y':ground,'w':right-left}
 spacing=(ground-560)/n
 ledges=[]
 for j in range(n):
  side=j%2
  x=left+22 if side==0 else mid-60
  width=mid+60-x if side==0 else right-22-x
  ledges.append({'id':f'ledge-{j+1}','x':x,'y':round(ground-(j+1)*spacing),'w':width})
 d.update(platforms=ledges,story=story,landmark=subtitle,viewBox=[0,0,w,h],floor=floor,scene_bounds=[60,210,w-120,ground-150],layout='vertical tower interior')
 s=rect(0,0,w,h,p['paper'])+rect(0,0,w,12,i)
 s+=txt(60,60,'HUMAN STORY SITE / TOWER INTERIOR',17,p['cloth'],letter_spacing=2)
 s+=txt(60,119,d['name'],48,i,'Georgia, serif')+txt(60,160,subtitle,22,p['dark'])
 s+=tag('defs',props(p))
 world=path(f'M60 {ground+100}V460Q60 220 {mid} 215Q{w-60} 220 {w-60} 460V{ground+100}Z',p['stone'],i,5)
 world+=path(f'M{left} {ground}V490Q{left} 285 {mid} 275Q{right} 285 {right} 490V{ground}Z','#eee4ce',p['dark'],5)
 # Courses follow the cylindrical wall; darker piers frame the continuous indoor cutaway.
 for y in range(470,ground,95):
  world+=path(f'M65 {y}Q{mid} {y+28} {w-65} {y}',stroke=p['far'],sw=2)
  for x in range(90+(45 if (y//95)%2 else 0),w-70,140):world+=line(x,y,x,y+88,p['far'],2)
 for x in [105,w-105]:world+=line(x,480,x,ground,p['dark'],24)
 world+=path(f'M{left} 493Q{mid} 260 {right} 493M{left+35} 480Q{mid} 320 {right-35} 480',stroke=p['wood'],sw=10)
 # Recessed arched windows make the building read from its interior.
 for j,a in enumerate(ledges):
  x=mid if j%2 else mid+12;y=a['y']-100
  world+=path(f'M{x-58} {y+75}V{y-52}Q{x} {y-132} {x+58} {y-52}V{y+75}Z',p['water'],p['dark'],5)
  world+=line(x,y-87,x,y+72,p['top'],5)+line(x-55,y-15,x+55,y-15,p['top'],5)
  world+=use('lantern',left-35 if j%2==0 else right-30,a['y']-155,66,94)
 if d['id']=='solar':
  world+=path(f'M{left+65} 448Q{mid} 130 {right-65} 448Z',p['sky'],p['cloth'],8)
  for x in [mid-170,mid,mid+170]:world+=line(mid,283,x,444,p['cloth'],4)
  world+=ellipse(mid,375,46,46,p['top'])
 else:
  world+=line(mid-35,400,mid-35,ground-100,p['wood'],7)
  world+=line(mid+35,400,mid+35,ground-350,p['wood'],7)
  world+=use('bell',mid+150,310,180,150)
  world+=rect(mid-61,ground-360,52,160,p['stone'],i,4,6)
 world+=rect(left,ground,right-left,48,p['wood'],i,4)+line(left,ground,right,ground,p['top'],10)
 for a in ledges:world+=surface(a,p,material='gallery')
 climbs=[]
 previous=floor
 for j,a in enumerate(ledges):
  top=a['x']+120 if j%2==0 else a['x']+a['w']-120
  bottom=right-142 if j==0 or (j-1)%2 else left+142
  run=top-bottom;rise=previous['y']-a['y'];steps=max(8,round(abs(run)/24));pts=[(bottom,previous['y'])]
  for k in range(steps):pts.extend([(bottom+(k+1)*run/steps,previous['y']-k*rise/steps),(bottom+(k+1)*run/steps,previous['y']-(k+1)*rise/steps)])
  world+=path('M'+'L'.join(f'{x:.1f} {y:.1f}' for x,y in pts),stroke=i,sw=13)
  world+=path('M'+'L'.join(f'{x:.1f} {y:.1f}' for x,y in pts),stroke=p['top'],sw=7)
  world+=line(bottom,previous['y']-52,top,a['y']-52,p['wood'],6)
  for k in range(9):
   x=bottom+k*run/8;y=previous['y']-k*rise/8;world+=line(x,y-52,x,y-8,p['wood'],3)
  climbs.append({'id':f'flight-{j+1}','type':'stairs','from':previous['id'],'to':a['id'],'x':top,'bottom_x':bottom,'y1':a['y'],'y2':previous['y']})
  # Optional maintenance connections occupy the overlapping inner gallery lips.
  if j in [1,3]:
   kind='ladder' if j==1 else 'rope';x=mid+(25 if j==1 else -25)
   if kind=='ladder':
    for xx in [x-15,x+15]:world+=line(xx,a['y']-10,xx,previous['y'],p['wood'],6)
    for yy in range(a['y'],previous['y'],24):world+=line(x-15,yy,x+15,yy,p['top'],5)
   else:
    world+=line(x,a['y'],x,previous['y'],p['wood'],6)
    for yy in range(a['y'],previous['y'],30):world+=line(x-5,yy,x+5,yy+4,p['top'],4)
   climbs.append({'id':kind,'type':kind,'from':previous['id'],'to':a['id'],'x':x,'bottom_x':x,'y1':a['y'],'y2':previous['y']})
  previous=a
 objects=[]
 kit={'tower':['chest','crate','bench','rack','barrel','table'], 'stair':['bench','shelf','chest','crate','table','lantern'], 'solar':['shelf','table','bed','chest','bench','telescope']}[d['id']]
 for j,a in enumerate([floor]+ledges):
  for k in range(3):
   room_kits={
    'tower':[['chest','crate','bench'],['barrel','crate','rack'],['table','bed','shelf'],['shelf','chest','lectern'],['winch','crate','barrel'],['bench','table','lantern'],['rack','chest','bell'],['bench','winch','crate']],
    'solar':[['chest','bench','planter'],['shelf','shelf','lectern'],['bed','table','chest'],['shelf','orb','table'],['bench','table','planter'],['telescope','lectern','chest']]}
   kind=room_kits[d['id']][j][k] if d['id'] in room_kits else kit[(j*2+k)%len(kit)];size=76
   # Furnish the outer alcoves; keep the inner lip and staircase mouth clear.
   x=(a['x']+12+k*83) if j==0 or (j-1)%2==0 else (a['x']+a['w']-size-12-k*83)
   y=a['y']-size-7;world+=use(kind,x,y,size,size)
   objects.append({'type':kind,'surface':a['id'],'x':x,'y':y,'w':size,'h':size,'jumpable':kind in ['chest','crate','bench','barrel','table','shelf','bed']})
 portals=[]
 for j,dest in enumerate(d['neighbors']):
  upwards=(d['id']=='tower' and dest=='stair') or (d['id']=='stair' and dest=='solar')
  a=ledges[-1] if upwards else floor
  x=(a['x']+90 if a['x']>=mid-60 else a['x']+a['w']-85) if upwards else right-75
  y=a['y']
  world+=path(f'M{x-33} {y-8}V{y-126}Q{x} {y-168} {x+33} {y-126}V{y-8}',p['cloth'],p['top'],7)
  world+=ellipse(x,y-7,42,10,p['top'],i,2)+txt(x,y-181,f'P{j+1}',20,i,text_anchor='middle')
  portals.append({'label':f'P{j+1}','to':dest,'x':x,'y':y,'support':a['id']})
 npcs=HUMAN_NPCS[d['id']]
 for j,name in enumerate(npcs):
  a=ledges[-2] if d['id']=='solar' else floor
  world+=npc_marker(a['x']+125+j*100 if d['id']=='solar' else mid+140,a['y']-8,name,j+1,p)
 world+=use('lantern',left+350,ground-100,68,90)+txt(left+384,ground-110,'R',20,i,text_anchor='middle')
 s+=tag('g',world,id='tower-interior')
 y=ground+160
 s+=txt(60,y,'CLIMB THROUGH THE TOWER',19,p['cloth'],letter_spacing=2)
 s+=wrap(60,y+38,story,95 if w==1400 else 110,21,i,29)
 s+=txt(60,y+155,f'{n} raised landings · {n} stair flights · maintenance ladder & rope · {len(objects)} props',19,i)
 s+=wrap(60,y+196,'   ·   '.join(f"{q['label']} {names[q['to']]}" for q in portals)+'   ·   R: same-map recovery',105,19,i,26)
 s+=txt(60,y+255,'   ·   '.join(f'{j+1} {name}' for j,name in enumerate(npcs)),19,i)
 s+=txt(60,h-38,'DESIGN-0014 / DESIGN-0022 · VERTICAL CUTAWAY · EDITABLE DESIGN PROPOSAL',15,p['dark'])
 d.update(climbs=climbs,objects=objects,portals=portals,npcs=npcs,recovery_position={'x':left+384,'y':ground,'support':'street'})
 return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-labelledby="title desc">'+tag('title',ESC(d['name']+' — vertical tower interior'),id='title')+tag('desc',ESC(story),id='desc')+s+'</svg>'
