extends SceneTree
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Model = preload("res://prototypes/tidekin_sea/region_encounter.gd")
const Catalog = preload("res://src/world/world_catalog.gd")
const Residents = preload("res://prototypes/tidekin_sea/residents.gd")
var failed := false
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://designs/map-layouts/manifest.json"))
	var routes := 0
	for authored in manifest.maps:
		if authored.region != "tidekin_sea": continue
		var spec := Region.spec(authored.id)
		var model = Model.new()
		model.configure_region(spec)
		model.enemies.clear()
		var sx: float = spec.width/authored.viewBox[2]
		for i in authored.platforms.size():
			var p: Dictionary = authored.platforms[i]
			var expected := Vector2(p.x*sx,480+(p.y-authored.floor.y)*.9)
			check(model.platforms[i].position.distance_to(expected)<.01,spec.id+" matches SVG landing "+p.id)
		var neighbors: Array = Catalog.neighbors("tidekin_sea",spec.id)
		neighbors.sort()
		var expected_neighbors: Array = authored.neighbors.duplicate()
		expected_neighbors.sort()
		check(neighbors==expected_neighbors,spec.id+" atlas matches SVG connections")
		for portal in spec.portals:
			var found := false
			for original in authored.portals:
				if original.to == portal.to:
					var expected := Vector2(original.x*sx,480+(original.y-authored.floor.y)*.9)
					found = expected.distance_to(Vector2(portal.point[0],portal.point[1]))<.01
			check(found,spec.id+" portal occupies its SVG location")
		# Start at each connector's supported lower end and use actual physics.
		for climb in spec.climbs:
			model.position = Vector2(climb.bottom[0],climb.bottom[1])
			model.velocity = Vector2.ZERO
			model.grounded = true
			model.climb_axis = -1
			var top := Vector2(climb.top[0],climb.top[1])
			for frame in 1200:
				model.step(1.0/60,0,false)
				if model.position.distance_to(top)<1: break
			check(model.position.distance_to(top)<1,spec.id+" climb reaches "+climb.to)
			model.position = top
			model.velocity = Vector2.ZERO
			model.climb_axis = 1
			var bottom := Vector2(climb.bottom[0],climb.bottom[1])
			for frame in 1200:
				model.step(1.0/60,0,false)
				if model.position.distance_to(bottom)<1: break
			check(model.position.distance_to(bottom)<1,spec.id+" climb descends to "+climb.from)
			routes += 1
		model.climb_axis = 0
		model.position = Vector2(spec.width-42,-200)
		model.velocity = Vector2.ZERO
		for frame in 180: model.step(1.0/60,0,false)
		check(model.grounded and model.position.y==480,spec.id+" safe floor return")
	var people := Residents.for_map("tidekin_sea_cm",3600)
	var start: float = people[0].x
	for i in 120: Residents.advance(people,1.0/60,i/60.0,Vector2(-1000,480),false)
	check(people[0].x!=start,"offscreen residents continue walking")
	start = people[0].x
	Residents.advance(people,1,2,Vector2(start+30,480),false)
	check(people[0].x==start and people[0].facing==1,"resident stops and faces approaching hero")
	Residents.advance(people,1,3,Vector2(-1000,480),true)
	check(people[0].x==start,"conversation stops walking")
	var scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene.camera_x = 2400
	scene._update_view(0)
	var visual = scene.resident_nodes[0]
	check(not visual.visible,"offscreen resident is culled")
	var pose: Transform2D = visual.sprite.transform
	var texture: Texture2D = visual.sprite.texture
	scene.model.active_time += 2
	Residents.advance(scene.residents,1,2,Vector2(3400,480),false)
	scene._update_view(0)
	check(visual.sprite.transform==pose and visual.sprite.texture==texture,"hidden resident avoids visual updates and texture uploads")
	scene.camera_x = 0
	scene._update_view(0)
	check(visual.visible and visual.sprite.transform!=pose,"resident animation resumes at current simulation time")
	check(visual.get_child_count()==1 and visual.sprite is Sprite2D,"resident uses a sprite without a builder rig or viewport")
	scene.camera_y = -1200
	check(not scene._creature_in_view(Vector2(500,480),340),"creatures below upper galleries are culled")
	check(scene._creature_in_view(Vector2(500,-300),340),"full creature/effect margin remains visible near viewport edge")
	scene.camera_y = 0
	scene.repaired.wells = true
	for spec in Region.maps():
		for destination in spec.neighbors:
			scene.enter_map(Region.index_of(spec.id),false)
			check(scene.travel_to(destination),"authored exit travels to "+destination)
			for portal in Region.spec(destination).portals:
				if portal.to==spec.id:
					check(scene.model.position.distance_to(Vector2(portal.point[0]+44,portal.point[1]))<.01,"arrival uses matching destination portal")
					check(absf(scene.camera_y-minf(0,scene.model.position.y-425))<.01,"camera shows raised arrival immediately")
	scene.queue_free()
	await process_frame
	if not failed: print("PASS: SVG geometry, atlas edges, raised portals, %d supported climbs, floor return and resident routines" % routes)
	quit(1 if failed else 0)
