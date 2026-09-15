extends SceneTree
var failed := false
const Catalog = preload("res://src/world/world_catalog.gd")
const Travel = preload("res://src/world/test_map_travel.gd")
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func settle() -> void:
	for i in 5:
		await process_frame
		if current_scene != null: current_scene.set_physics_process(false)
func teleport(id: String) -> void:
	var scene = current_scene
	scene._toggle_world_map()
	scene.map_panel.open_region(Catalog.node(id).region)
	scene.map_panel.select_node(id)
	check(scene.map_panel.teleport_button.visible and not scene.map_panel.teleport_button.disabled,"test teleport offered for "+id)
	scene.map_panel.teleport_button.pressed.emit()
	await settle()
	check(current_scene.model.map_id == Catalog.node(id).runtime_id,"teleport reaches selected runtime map: "+id)
	check(not current_scene.paused and not is_instance_valid(current_scene.map_panel),"teleport resumes play")
	check(current_scene.model.position == current_scene.model.recovery_anchor,"arrival has a safe recovery anchor")
func run() -> void:
	var supported := 0
	for region in Catalog.regions():
		for node in region.nodes:
			if not Travel.destination(node.id).is_empty(): supported += 1
	check(supported == 58,"all 15 hometown, 39 Tidekin and 4 training maps resolve")
	check(Travel.destination("missing").is_empty() and Travel.destination("underdeep_vh").is_empty(),"unbuilt and unknown maps cannot teleport")
	var scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	scene.model.inventory.coins = 57
	scene.model.health = 67
	var inventory = scene.model.inventory
	var progression = scene.model.progression
	scene._toggle_world_map()
	scene.map_panel.open_region("underdeep")
	scene.map_panel.select_node("underdeep_vh")
	check(scene.map_panel.teleport_button.disabled,"unbuilt map clearly disables testing shortcut")
	scene.map_panel._request_test_teleport()
	check(not has_meta("map_test_transfer"),"disabled teleport does not queue a transfer")
	scene._toggle_world_map()
	await teleport("tidekin_sea_return_116")
	check(current_scene.repaired.is_empty(),"testing does not complete shrine tasks")
	await teleport("tower")
	check(current_scene.quest_stage == 0,"testing bypasses a sealed tower without completing its quest")
	await teleport("grove")
	check(current_scene.tutorial.index == 3,"training test teleport chooses the requested map")
	await teleport("market")
	check(current_scene.model.inventory == inventory and inventory.coins == 57,"cross-region teleport preserves possessions")
	check(current_scene.model.progression == progression and current_scene.model.health == 67,"teleport preserves progression and living hero health")
	current_scene._toggle_world_map()
	check(current_scene.map_panel.selected_node == "market","map identifies the destination after teleport")
	current_scene._toggle_world_map()
	if not failed: print("PASS: all 58 playable destinations, disabled unbuilt maps, gated test jumps, safe spawn and character preservation")
	quit(1 if failed else 0)
