extends SceneTree
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func frames() -> void:
	await process_frame
	await process_frame
func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event,true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event,true)
func click(at: Vector2, double := false) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	root.push_input(motion,true)
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = at
	event.global_position = at
	event.pressed = true
	event.double_click = double
	root.push_input(event,true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event,true)
func _run() -> void:
	var scene = preload("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	await frames()
	key(KEY_M)
	await frames()
	check(is_instance_valid(scene.map_panel),"real M event opens atlas")
	if not is_instance_valid(scene.map_panel): quit(1); return
	var map = scene.map_panel
	check(map.region_id == "open_lands","real M opens local region")
	click(map.back_button.get_global_rect().get_center())
	await frames()
	click(map.targets.underdeep.get_global_rect().get_center())
	await frames()
	check(map.selected_region == "underdeep" and map.region_id.is_empty(),"real single click selects region without opening it")
	click(map.targets.underdeep.get_global_rect().get_center(),true)
	await frames()
	check(map.region_id == "underdeep","real double click opens selected region")
	if map.region_id != "underdeep": quit(1); return
	click(map.group_targets.stronghold.get_global_rect().get_center())
	await frames()
	check(map.focused_group == "stronghold","stronghold heading zooms into internal maps")
	click(map.targets.underdeep_vh.get_global_rect().get_center())
	await frames()
	check(map.selected_node == "underdeep_vh","actual submap click opens map details")
	check(scene.district_id == "square","mouse navigation never travels")
	click(map.back_button.get_global_rect().get_center())
	await frames()
	check(map.region_id.is_empty(),"World button returns to overview")
	key(KEY_ESCAPE)
	await frames()
	check(not is_instance_valid(scene.map_panel) and not scene.paused,"real Escape resumes game")
	if not failed: print("PASS: viewport-dispatched M, region selection, double-click, stronghold zoom, submap inspection, World and Escape")
	quit(1 if failed else 0)
