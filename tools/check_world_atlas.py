"""Compare the authored hometown atlas against DESIGN-0014's Mermaid graphs."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / 'src/world/atlas.json').read_text())
doc = (ROOT / 'docs/game/0014-hometown-maps.md').read_text().split('## Home-town portal graphs', 1)[1]
blocks = re.findall(r'```mermaid\n(.*?)```', doc, re.S)
regions = {r['id']: r for r in data['regions']}
order = ['open_lands', 'tidekin_sea', 'elder_forests', 'sky_reaches', 'broken_mountains', 'underdeep', 'ember_desert', 'ice_lands']

def clean(name):
    name = re.split(r'<br\s*/?>', name)[0]
    name = re.sub(r'[★✦⚑\[\](){}]', '', name).strip().casefold()
    return name.removeprefix('the ').replace('&amp;', 'and').replace('&', 'and')

pattern = re.compile(r'\b([A-Za-z]\w*)(?:\[{1,2}([^\]]+)\]{1,2}|\({1,3}([^\)]+)\){1,3}|\{{1,2}([^}]+)\}{1,2})')
failures = []
for rid, block in zip(order, blocks):
    names = {}
    graph_lines = []
    for line in block.splitlines():
        if 'subgraph ' in line or '.world map.' in line:
            continue
        for match in pattern.finditer(line):
            names[match[1]] = clean(next(x for x in match.groups()[1:] if x is not None))
        plain = pattern.sub(lambda match: match[1], line)
        graph_lines.append(re.sub(r'\|[^|]*\|', '', plain))
    canonical_edges = set()
    for line in graph_lines:
        for a, b in re.findall(r'(?=(\b[A-Za-z]\w*)\s*(?:---|-->|==>)\s*([A-Za-z]\w*))', line):
            canonical_edges.add(frozenset([names[a], names[b]]))
    region = regions[rid]
    nodes = {n['id']: clean(n['name']) for n in region['nodes'] if n['source'] == 'DESIGN-0014'}
    authored_edges = {frozenset([nodes[e['a']], nodes[e['b']]]) for e in region['edges'] if e['a'] in nodes and e['b'] in nodes}
    if set(names.values()) != set(nodes.values()):
        failures.append(f'{rid}: name mismatch {set(names.values()) ^ set(nodes.values())}')
    if canonical_edges != authored_edges:
        failures.append(f'{rid}: portal mismatch {canonical_edges ^ authored_edges}')
if failures:
    raise SystemExit('\n'.join(failures))
print('PASS: all 127 hometown names and every reciprocal connection match DESIGN-0014')

# DESIGN-0015's first graph is the world-level road topology.
world_doc = (ROOT / 'docs/game/0015-world-map-layout.md').read_text()
world_graph = re.findall(r'```mermaid\n(.*?)```', world_doc, re.S)[0]
aliases = dict(SKY='sky_reaches', SEA='tidekin_sea', OPEN='open_lands', FOR='elder_forests', ASH='ashen_scar', MARCH='shattered_march', GLOAM='gloamfen', VERD='verdant_maw', MTN='broken_mountains', DEEP='underdeep', DES='ember_desert', ICE='ice_lands')
world_graph = re.sub(r'\|[^|]*\|', '', world_graph)
expected = {frozenset([aliases[a], aliases[b]]) for a,b in re.findall(r'\b([A-Z]+)\s*---\s*([A-Z]+)\b', world_graph)}
actual = {frozenset([road['a'], road['b']]) for road in data['routes']}
assert expected == actual, f'World road mismatch: {expected ^ actual}'
print('PASS: all 15 world connections match DESIGN-0015')
