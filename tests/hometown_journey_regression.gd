extends SceneTree
const Scene = preload("res://prototypes/human_hometown/human_hometown.tscn")
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func travel(destination: String) -> void:
	var town = current_scene
	var portal := {}
	for entry in town.district.portals:
		if entry.to == destination: portal = entry
	check(not portal.is_empty(),"connected to "+destination)
	if portal.is_empty(): return
	town.model.position = Vector2(portal.x,portal.y)
	town.model.grounded = true
	town.model.velocity = Vector2.ZERO
	town.travel_grace = 0
	town._check_district_exit()
	await process_frame
	await process_frame
	current_scene.set_physics_process(false)
	check(current_scene.district_id == destination,"portal loads "+destination)
func talk(id: String) -> void:
	var town = current_scene
	for resident in town.residents:
		if resident.id == id: town.model.position = Vector2(resident.x-35,480)
	town.model.grounded = true
	town.model.velocity = Vector2.ZERO
	town._talk_to_rowan()
	check(is_instance_valid(town.dialogue),"can speak to "+id)
	town._close_rowan()
func _run() -> void:
	var town = Scene.instantiate()
	root.add_child(town)
	current_scene = town
	town.set_physics_process(false)
	town.model.inventory.grant({"coins":57})
	talk("elowen")
	check(town.quest_stage == 1,"Elowen starts investigation")
	for destination in ["approach","gatehouse","barracks","hall"]: await travel(destination)
	var hall = current_scene
	for portal in hall.district.portals:
		if portal.to == "tower": hall.model.position = Vector2(portal.x,portal.y)
	hall._check_district_exit()
	check(not hall.leaving and hall.gate_notice_time > 0,"sealed tower physically refuses entry")
	await travel("archive")
	talk("meriel")
	await travel("hall")
	await travel("barracks")
	talk("aldren")
	check(current_scene.quest_stage == 3,"captain grants key after archive")
	for destination in ["hall","tower","stair","solar"]: await travel(destination)
	talk("lyra")
	check(current_scene.quest_stage == 4,"heir-warden advances story")
	for destination in ["stair","tower","hall","barracks","gatehouse","approach","square"]: await travel(destination)
	talk("elowen")
	check(current_scene.quest_stage == 5 and current_scene.model.inventory.coins == 57,"round trip completes quest without changing money")
	current_scene._toggle_town_map()
	check(is_instance_valid(current_scene.map_panel) and current_scene.paused,"map panel opens without travel")
	current_scene._toggle_town_map()
	await travel("approach")
	current_scene.model.inventory.lineage = "goblin"
	current_scene.model.position = Vector2(2330,480)
	current_scene._check_district_exit()
	check(not current_scene.leaving and current_scene.model.map_id == "wendmere_approach" and current_scene.model.position.x < 2300,"guardian repels opposing allegiance within approach")
	if not failed: print("PASS: real portal story roundtrip, sealed tower, conversations, map UI, inventory and guardian denial")
	quit(1 if failed else 0)
