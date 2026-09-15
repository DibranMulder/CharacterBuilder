extends RefCounted
## Public atlas geography only. Reading a chart never grants exploration or loads a level.
static var _data: Dictionary = {}
static var _regions: Dictionary = {}
static var _nodes: Dictionary = {}
static var _layouts: Dictionary = {}
static var _positions: Dictionary = {}
const REGION_SIZE := Vector2(2400,1600)

static func data() -> Dictionary:
	if _data.is_empty():
		_data = JSON.parse_string(FileAccess.get_file_as_string("res://src/world/atlas.json"))
		for region in _data.regions:
			_regions[region.id] = region
			for node in region.nodes:
				_nodes[node.id] = node.merged({"region":region.id})
	return _data

static func regions() -> Array:
	return data().regions

static func region(id: String) -> Dictionary:
	data()
	return _regions.get(id,{})

static func node(id: String) -> Dictionary:
	data()
	return _nodes.get(id,{})

static func from_runtime(id: String) -> String:
	data()
	for key in _nodes:
		if not id.is_empty() and _nodes[key].runtime_id == id: return key
	return ""

static func roads(id: String) -> Array:
	return data().routes.filter(func(road): return road.a == id or road.b == id)

static func neighbors(region_id: String, node_id: String) -> Array:
	var result: Array = []
	for edge in region(region_id).edges:
		if edge.a == node_id: result.append(edge.b)
		elif edge.b == node_id: result.append(edge.a)
	return result

static func positions(region_id: String) -> Dictionary:
	if not _positions.has(region_id):
		if _layouts.is_empty():
			_layouts = JSON.parse_string(FileAccess.get_file_as_string("res://src/world/region_layouts.json"))
		var result := {}
		for id in _layouts.get(region_id,{}):
			var uv: Array = _layouts[region_id][id]
			result[id] = Vector2(uv[0],uv[1])*REGION_SIZE
		_positions[region_id] = result
	return _positions[region_id]

static func group_bounds(region_id: String, group_id: String) -> Rect2:
	if group_id.is_empty(): return Rect2(Vector2.ZERO,REGION_SIZE)
	var points := positions(region_id)
	var bounds := Rect2()
	var first := true
	for entry in region(region_id).nodes:
		if not group_id.is_empty() and entry.group != group_id: continue
		var at: Vector2 = points[entry.id]
		if first:
			bounds = Rect2(at,Vector2.ONE)
			first = false
		else: bounds = bounds.expand(at)
	return bounds.grow_individual(115,115,115,65)
