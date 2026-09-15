extends SceneTree
const Catalog = preload("res://src/world/world_catalog.gd")
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func _run() -> void:
	var regions := Catalog.regions()
	check(regions.size() == 12,"all eight homelands and four frontiers exist")
	check(Catalog.data().routes.size() == 15,"all canonical world connections exist")
	var art = preload("res://src/world/region_art.gd")
	var chronicle = preload("res://src/ui/chronicle_theme.gd")
	var original_fill: Color = chronicle.create().get_stylebox("normal","Button").fill
	var artwork_paths := {}
	for spec in regions:
		var texture: Texture2D = art.background(spec.id)
		check(texture != null,"region has a PNG background: "+spec.id)
		if texture != null:
			check(texture.get_width() >= 1000 and texture.get_height() >= 600,"region image has sufficient resolution")
			check(not artwork_paths.has(texture.resource_path),"regions use distinct images")
			artwork_paths[texture.resource_path] = true
		var local_map = preload("res://src/ui/world_map.gd").new()
		local_map.current = spec.nodes[0].id
		root.add_child(local_map)
		check(local_map.region_id == spec.id and local_map.selected_node == local_map.current,"each region opens locally with its current node")
		check(local_map.focused_group.is_empty(),"default fits the entire region, not a building")
		for crossing in local_map.crossing_targets:
			for heading in local_map.group_targets.values():
				check(not crossing.get_global_rect().intersects(heading.get_global_rect()),"region crossings never cover landmark headings: "+spec.id)
		check(local_map.theme.get_stylebox("normal","Button").fill == art.ink(spec.id),"region controls use their own palette")
		local_map.show_world()
		check(local_map.region_id.is_empty() and local_map.theme == chronicle.create(),"World restores the shared global theme")
		local_map.free()
	check(chronicle.create().get_stylebox("normal","Button").fill == original_fill,"regional themes never mutate shared game styles")
	var hometown_counts := {"open_lands":15,"tidekin_sea":17,"elder_forests":16,"sky_reaches":17,"broken_mountains":13,"underdeep":19,"ember_desert":16,"ice_lands":14}
	var all_ids := {}
	for spec in regions:
		var ids: Array = spec.nodes.map(func(entry): return entry.id)
		var positions := Catalog.positions(spec.id)
		check(positions.size() == ids.size(),"each map has an authored terrain position")
		for point in positions.values(): check(Rect2(Vector2.ZERO,Catalog.REGION_SIZE).has_point(point),"map pins stay inside the region painting")
		for i in ids.size():
			for j in range(i+1,ids.size()):
				var first := Rect2(positions[ids[i]]-Vector2(36,36),Vector2(72,72))
				var second := Rect2(positions[ids[j]]-Vector2(36,36),Vector2(72,72))
				check(not first.intersects(second),spec.id+" map markers do not overlap: "+ids[i]+" / "+ids[j])
		if spec.kind == "homeland":
			check(spec.nodes.filter(func(entry): return entry.group != "wilds").size() == hometown_counts[spec.id],spec.id+" complete hometown roster")
			var stronghold: Array = spec.nodes.filter(func(entry): return entry.group == "stronghold")
			check(stronghold.size() >= 5 and stronghold.size() <= 10,spec.id+" stronghold contains five to ten maps")
		else:
			var depths: Array = spec.nodes.filter(func(entry): return "_depth_" in entry.id)
			check(depths.size() == 10,spec.id+" contains ten consecutive dungeon depths")
			for i in range(1,10): check(Catalog.neighbors(spec.id,spec.id+"_depth_"+str(i)).has(spec.id+"_depth_"+str(i+1)),"consecutive dungeon route")
		for entry in spec.nodes:
			check(not all_ids.has(entry.id),"globally unique map ID: "+entry.id)
			all_ids[entry.id] = true
			check(not Catalog.neighbors(spec.id,entry.id).is_empty(),"return route for "+entry.id)
			if spec.id == "tidekin_sea":
				check(entry.runtime_id == entry.id,"playable shoreline maps resolve to their runtime IDs")
			elif spec.id != "open_lands": check(entry.runtime_id.is_empty(),"unbuilt submaps have no gameplay target")
			if entry.group in ["stronghold","story"]: check(entry.access == spec.allegiance,"stronghold and story access remain gated")
		for edge in spec.edges: check(edge.a in ids and edge.b in ids,"route references existing maps")
		# Every submap is reachable, including leaf return routes.
		var found: Array = [ids[0]]
		var cursor := 0
		while cursor < found.size():
			for next in Catalog.neighbors(spec.id,found[cursor]):
				if next not in found: found.append(next)
			cursor += 1
		check(found.size() == ids.size(),spec.id+" is a connected region graph")
	for road in Catalog.data().routes:
		var a := Catalog.region(road.a)
		var b := Catalog.region(road.b)
		check(not a.is_empty() and not b.is_empty(),"world route endpoints exist")
		check(not (a.kind == "homeland" and b.kind == "homeland" and a.allegiance != b.allegiance),"cross-allegiance route goes through neutral frontier")
	check(Catalog.roads("ice_lands").size() == 1 and Catalog.roads("ice_lands")[0].a == "broken_mountains","ice lands reached only through mountains")
	var map = preload("res://src/ui/world_map.gd").new()
	map.current = "square"
	map.explored = ["square","market"]
	root.add_child(map)
	check(map.region_id == "open_lands" and map.selected_node == "square","atlas opens at current region and selects the hero")
	var traveled := [false]
	map.travel_requested.connect(func(_id): traveled[0] = true)
	for spec in regions:
		map.open_region(spec.id)
		check(map.targets.size() == spec.nodes.size(),"all submaps have region markers in "+spec.id)
		for entry in spec.nodes:
			map.select_node(entry.id)
			check(map.selected_node == entry.id,"every submap can be inspected")
			check(not map.detail.text.is_empty(),"every submap shows route and access details")
		if spec.kind == "homeland":
			map.focus_group("stronghold")
			check(map.focused_group == "stronghold","each stronghold can be zoomed into")
		map.show_world()
		check(map.targets.size() == 12 and map.region_id.is_empty(),"back returns to world without detailed nodes")
	check(not traveled[0] and map.explored == ["square","market"],"inspection neither travels nor changes discovery")
	map.show_current()
	check(map.region_id == "open_lands" and map.selected_node == "square","You locates current submap")
	map.show_world()
	map.select_region("underdeep")
	map.set_zoom(1.4)
	map.step_zoom(1.25)
	check(map.region_id == "underdeep","zooming through selected region opens its map")
	map.set_zoom(map.min_zoom)
	map.step_zoom(.8)
	check(map.region_id.is_empty(),"zooming out of region returns to world")
	map.queue_free()
	await process_frame
	if not failed: print("PASS: 12 regions, 210 submaps, 15 world roads, strongholds, dungeon chains, hierarchy and read-only discovery")
	quit(1 if failed else 0)
