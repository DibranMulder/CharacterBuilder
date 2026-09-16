#!/usr/bin/env python3
"""Render all delivered SVGs, contact sheets and verify the offline review UI."""
from pathlib import Path
from playwright.sync_api import sync_playwright
import json,argparse,html
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'designs/map-layouts'
p=argparse.ArgumentParser();p.add_argument('--all',action='store_true');args=p.parse_args()
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',headless=True,args=['--allow-file-access-from-files'])
 page=browser.new_page(viewport={'width':2600,'height':1540},device_scale_factor=1)
 out=OUT/'previews';out.mkdir(exist_ok=True)
 ids=['square','market','stair','open_lands_path_016','tidekin_sea_land','tidekin_sea_lag','tidekin_sea_fn','tidekin_sea_return_116']
 data=json.loads((OUT/'manifest.json').read_text());rows=data['maps'];report=[]
 for d in rows:
  if not args.all and d['id'] not in ids:continue
  page.goto((OUT/d['region']/(d['id']+'.svg')).as_uri())
  assert not page.locator('parsererror').count(),d['id']
  # Browser-computed text bounds catch long metadata labels escaping the sheet.
  outside=page.evaluate('''() => [...document.querySelectorAll('text')].filter(e=>{const b=e.getBBox();return b.x<0 || b.y<0 || b.x+b.width>2601 || b.y+b.height>1541}).map(e=>e.textContent)''')
  if outside:raise RuntimeError(d['id']+' out-of-sheet text: '+str(outside))
  page.screenshot(path=str(out/(d['id']+'.png')))
  report.append(d['id'])
 for ov in data['overviews']:
  page.goto((OUT/ov['file']).as_uri())
  size=page.evaluate('''() => ({width:+document.documentElement.getAttribute('width'),height:+document.documentElement.getAttribute('height')})''')
  page.set_viewport_size(size);page.screenshot(path=str(out/(Path(ov['file']).stem+'.png')))
 # Contact sheets preserve each complete artboard, ten designs per sheet.
 if args.all:
  page.goto((OUT/'index.html').as_uri())
  for region in ['open_lands','tidekin_sea']:
   group=[d for d in rows if d['region']==region]
   for batch in range(0,len(group),10):
    cells=''.join(f'<section><h2>{html.escape(d["name"])}</h2><img src="{(out/(d["id"]+".png")).as_uri()}"></section>' for d in group[batch:batch+10])
    page.set_viewport_size({'width':1800,'height':2900})
    page.set_content('<html><style>body{margin:0;padding:24px;background:#f7f1e4;color:#25434a;font:20px Arial}main{display:grid;grid-template-columns:1fr 1fr;gap:16px}h1{font:36px Georgia}h2{font:24px Georgia;margin:12px}section{border:1px solid #b7c8bc;background:#fff}img{width:100%;display:block}</style><h1>'+region+' · maps '+str(batch+1)+'–'+str(min(batch+10,len(group)))+'</h1><main>'+cells+'</main></html>')
    page.wait_for_function('''() => [...document.images].every(i=>i.complete && i.naturalWidth>0)''')
    page.locator('body').screenshot(path=str(out/f'contact-{region}-{batch//10+1}.png'))
 # Test the catalogue without network access or a local server.
 page.set_viewport_size({'width':1500,'height':1000});page.goto((OUT/'index.html').as_uri())
 assert page.locator('article').count()==80
 page.select_option('#region','tidekin_sea');assert page.locator('article:visible').count()==39
 page.select_option('#group','village');assert page.locator('article:visible').count()==7
 page.select_option('#region','');page.select_option('#group','');page.fill('#search','Winding Stair');assert page.locator('article:visible').count()==1
 page.fill('#search','');page.screenshot(path=str(out/'catalogue.png'))
 (OUT/'render-review.json').write_text(json.dumps({'renderer':'Chromium via Playwright','rendered_maps':report,'overviews':4,'xml_parser_errors':0,'detail_text_outside_sheet':0,'catalogue_filters':'80 all / 39 Tidekin / 7 Tidekin village / 1 Winding Stair'},indent=2)+'\n')
 print(f'Rendered {len(report)} SVG maps, four overviews; catalogue filters passed')
 browser.close()
