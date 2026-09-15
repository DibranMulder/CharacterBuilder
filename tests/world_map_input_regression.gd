extends SceneTree
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func key(scene: Node, code: Key) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = code
	scene._unhandled_key_input(event)
func _run() -> void:
	for scene_path in ["res://prototypes/human_hometown/human_hometown.tscn","res://prototypes/training_clearing/training_clearing.tscn"]:
		var scene = load(scene_path).instantiate()
		root.add_child(scene)
		scene.set_physics_process(false)
		var at: Vector2 = scene.model.position
		var potions: int = scene.model.inventory.potions.mana
		key(scene,KEY_M)
		check(is_instance_valid(scene.map_panel) and scene.paused,"M opens atlas and pauses gameplay: "+scene_path)
		check(scene.map_panel.region_id == "open_lands","M opens the local region, including an uncharted training fallback")
		check(scene.model.inventory.potions.mana == potions,"M no longer consumes mana potion")
		scene.map_panel.open_region("ice_lands","stronghold")
		key(scene,KEY_I)
		check(not is_instance_valid(scene.inventory_panel),"atlas blocks conflicting inventory menu")
		key(scene,KEY_ESCAPE)
		check(not is_instance_valid(scene.map_panel) and not scene.paused,"Escape closes atlas and resumes")
		check(scene.model.position == at,"browsing remote stronghold never moves hero")
		scene._toggle_pause()
		key(scene,KEY_M)
		key(scene,KEY_M)
		check(scene.paused and not is_instance_valid(scene.map_panel),"opening from pause restores previous pause state")
		scene._toggle_pause()
		scene.world_map_button.pressed.emit()
		check(is_instance_valid(scene.map_panel),"visible Map button opens atlas")
		scene.map_panel.closed.emit()
		check(not scene.paused,"close button resumes gameplay")
		scene.queue_free()
		await process_frame
	if not failed: print("PASS: M / Escape / Map button in hometown and training, pause restoration, menu isolation and no travel")
	quit(1 if failed else 0)
