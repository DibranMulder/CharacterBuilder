extends SceneTree
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func settle() -> void:
	await process_frame
	await process_frame
	current_scene.set_physics_process(false)
func _run() -> void:
	var town = preload("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	root.add_child(town)
	current_scene = town
	town.set_physics_process(false)
	town.model.inventory.grant({"coins":43})
	town.model.health = 67
	var inventory = town.model.inventory
	town._toggle_town_map()
	check(town.map_panel.region_id == "open_lands" and town.map_panel.selected_node == "square","M opens hometown region with the hero selected")
	town.map_panel.open_region("open_lands")
	town.map_panel.select_node("trainers")
	town.map_panel._request_travel()
	check(not town.leaving and not town.map_panel.travel_button.visible,"unexplored submap can be inspected but cannot be travelled to")
	town._travel_from_map("trainers")
	check(not town.leaving,"travel controller also refuses unexplored destinations")
	town.map_panel.open_region("underdeep","stronghold")
	town.map_panel.select_node("underdeep_vh")
	town.map_panel._request_travel()
	check(not town.leaving and town.district_id == "square","unbuilt regions can be browsed without loading levels")
	town._toggle_town_map()
	# Known destinations simulate a returning hero's saved exploration.
	var visits: Dictionary = get_meta("wendmere_districts")
	for id in ["trainers","hall","tower"]:
		var visited = preload("res://prototypes/human_hometown/town_encounter.gd").new()
		visited.configure_map(preload("res://prototypes/human_hometown/districts.gd").spec(id))
		visits[id] = visited
	set_meta("wendmere_districts",visits)
	town._toggle_town_map()
	town.map_panel.open_region("open_lands")
	town.map_panel.select_node("tower")
	check(town.map_panel.travel_button.disabled,"known tower still requires story key")
	town.map_panel._request_travel()
	check(not town.leaving,"disabled travel cannot bypass the quest gate")
	town.map_panel.select_node("trainers")
	check(not town.leaving,"selecting a discovered map never teleports")
	town.map_panel._request_travel()
	await settle()
	check(current_scene.district_id == "trainers" and not current_scene.paused,"explicit Travel action resumes play")
	check(current_scene.model.inventory == inventory and inventory.coins == 43 and current_scene.model.health == 67,"travel preserves possessions and health")
	current_scene._toggle_town_map()
	current_scene.map_panel.open_region("open_lands")
	current_scene.map_panel.select_node("hall")
	current_scene.map_panel._request_travel()
	await settle()
	check(current_scene.district_id == "hall","discovered nonadjacent map remains available")
	current_scene.quest_stage = 3
	set_meta("wendmere_quest",3)
	current_scene._toggle_town_map()
	current_scene.map_panel.open_region("open_lands")
	current_scene.map_panel.select_node("tower")
	current_scene.map_panel._request_travel()
	await settle()
	check(current_scene.district_id == "tower","quest key allows deliberate tower travel")
	var at: Vector2 = current_scene.model.position
	current_scene._toggle_town_map()
	current_scene.map_panel.show_current()
	current_scene.map_panel._request_travel()
	check(not is_instance_valid(current_scene.map_panel) and current_scene.model.position == at,"current district closes map without relocating")
	current_scene.model.inventory.lineage = "goblin"
	current_scene._toggle_town_map()
	current_scene.map_panel.open_region("open_lands")
	current_scene.map_panel.select_node("hall")
	current_scene.map_panel._request_travel()
	check(is_instance_valid(current_scene.map_panel) and "Light" in current_scene.map_panel.status.text,"allegiance restriction still applies")
	if not failed: print("PASS: region-first atlas, read-only browsing, explicit discovered travel, gates and inventory")
	quit(1 if failed else 0)
