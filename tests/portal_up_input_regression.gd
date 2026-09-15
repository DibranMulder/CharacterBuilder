extends SceneTree
var failed := false
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func key(scene: Node, code: Key) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = code
	scene._unhandled_key_input(event)
func run() -> void:
	var tide = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	root.add_child(tide)
	tide.set_physics_process(false)
	var destination: String = tide.MAPS[0].neighbors[0]
	tide.model.position = tide.portal_point(0)
	tide._physics_process(0)
	check(tide.map_index == 0,"standing on Tidekin portal does not auto-travel")
	key(tide,KEY_E)
	check(tide.map_index == 0,"E does not activate Tidekin portals")
	key(tide,KEY_M)
	key(tide,KEY_UP)
	check(tide.map_index == 0,"Up cannot travel behind the atlas")
	key(tide,KEY_M)
	key(tide,KEY_UP)
	check(tide.model.map_id == destination and tide.model.grounded,"Up uses the portal instead of jumping")
	tide.queue_free()
	await process_frame
	var training = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	root.add_child(training)
	training.set_physics_process(false)
	training._start_tutorial()
	training.tutorial.actions.merge({"trail/move":true,"trail/jump":true,"trail/platform":true})
	training.model.position = Vector2(training.model.world_width-65,480)
	training._physics_process(0)
	check(training.tutorial.index == 0,"training no longer auto-travels")
	key(training,KEY_UP)
	check(training.tutorial.index == 1 and training.model.grounded,"Up activates training portal")
	training.queue_free()
	await process_frame
	var town = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	root.add_child(town)
	current_scene = town
	town.set_physics_process(false)
	var portal: Dictionary = town.district.portals[0]
	town.model.position = Vector2(portal.x,portal.y)
	town.travel_grace = 0
	town._physics_process(0)
	check(not town.leaving,"standing on hometown portal does not auto-travel")
	key(town,KEY_UP)
	for i in 4:
		await process_frame
		if current_scene != null: current_scene.set_physics_process(false)
	check(current_scene.district_id == portal.to,"Up activates hometown portal")
	if not failed: print("PASS: Up portal activation, E isolation, no automatic travel, grounded arrival and menu input isolation")
	quit(1 if failed else 0)
