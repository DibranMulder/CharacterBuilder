extends SceneTree
const Clearing = preload("res://prototypes/training_clearing/training_clearing.tscn")

func _initialize() -> void:
	_run.call_deferred()

func _mouse(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	root.push_input(event,true)

func _move(at: Vector2, relative: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = at
	event.relative = relative
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(event,true)

func _run() -> void:
	var scene = Clearing.instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene.model.inventory.grant({"items":[{"slot":"weapon","id":"crossbow"}]})
	scene._toggle_inventory()
	await process_frame
	await process_frame
	var panel = scene.inventory_panel
	var source: Vector2 = panel.tiles[0].get_global_rect().get_center()
	var target := Vector2.ZERO
	for tile in panel.tiles:
		if tile.equipment_slot == "weapon":
			target = tile.get_global_rect().get_center()
	_mouse(source,true)
	await process_frame
	assert(panel.selected_index == 0)
	_move(source+Vector2(30,0),Vector2(30,0))
	await process_frame
	assert(root.gui_is_dragging(), "mouse motion must initiate a real Godot GUI drag")
	_move(target,target-source-Vector2(30,0))
	_mouse(target,false)
	await process_frame
	assert(scene.model.weapon == "crossbow", "mouse drop must equip selected gear")
	assert(scene.avatar.loadout.weapon == "crossbow")
	assert(not root.gui_is_dragging())
	scene.free()
	print("PASS: real mouse drag preview, drop routing and visible equipment update")
	quit()
