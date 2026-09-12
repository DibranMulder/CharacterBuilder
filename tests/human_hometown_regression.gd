extends SceneTree
const TownScene = preload("res://prototypes/human_hometown/human_hometown.tscn")
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func _run() -> void:
	var town = TownScene.instantiate()
	root.add_child(town)
	current_scene = town
	town.set_physics_process(false)
	check(town.model.map_id == "wendmere_square" and town.model.enemies.is_empty(),"hometown is a safe map")
	check(town.model.world_width == 2400 and town.model.recovery_anchor.x == 350,"town has its own bounds and recovery anchor")
	check(not town.tutorial_button.visible and town.attack_button.visible,"town controls use final visibility")
	town._start_tutorial()
	check(not town.leaving,"training cannot be entered away from the road exit")
	check(town.sentries.size() == 2,"guarded entrance and training road")
	check(town.model.rowan.home.x == 1600,"merchant home belongs to the town")
	for i in 1000: town.model.rowan.step(.02,Vector2(420,480),true)
	check(absf(town.model.rowan.position.x-1600) < 30,"merchant patrol stays at the market")
	town.model.position.x = 1560
	town.model.inventory.grant({"coins":12})
	town._talk_to_rowan()
	check(is_instance_valid(town.dialogue) and town.paused,"merchant dialogue pauses town")
	town._open_shop()
	check(town.model.buy_from_rowan(0,town.model.inventory.revision).ok,"market supports buying")
	check(town.model.inventory.coins == 6,"purchase charges real local coins")
	town._close_rowan()
	var inventory = town.model.inventory
	var profile = town.model.progression
	town.model.health = 72
	town.model.mana = 61
	town.model.lineage_cooldowns[0] = 2.0
	town.model.position.x = town.model.world_width-60
	town._start_tutorial()
	await process_frame
	await process_frame
	var clearing = current_scene
	clearing.set_physics_process(false)
	check(clearing.model.map_id == "trail","east road enters the first training map")
	check(clearing.model.inventory == inventory and clearing.model.progression == profile,"town-to-training keeps possessions and progression")
	check(clearing.model.health == 72 and clearing.model.mana >= 61 and clearing.model.mana < 63,"travel does not refill resources")
	check(clearing.model.inventory.coins == 6,"travel never duplicates currency")
	clearing.model.inventory.grant({"coins":8,"items":[{"slot":"weapon","id":"crossbow"}]})
	check(clearing.model.change_equipment(0),"training can change equipment")
	clearing._equipment_changed()
	clearing.model.position.x = 60
	clearing._travel_map()
	await process_frame
	await process_frame
	var returned = current_scene
	returned.set_physics_process(false)
	check(returned.model.map_id == "wendmere_square","return restores the hometown")
	check(returned.model.inventory.coins == 14 and returned.model.weapon == "crossbow","earned loot and gear come back to town")
	check(returned.avatar.loadout.weapon == "crossbow","returned appearance matches equipment")
	check(returned.model.position.x < returned.model.world_width-85,"return cannot bounce through the outbound exit")
	check(has_meta("wendmere_training_route"),"return keeps the training maps available for revisiting")
	returned.model.health = 0
	returned.model.death_time = .01
	returned.model.step(.02,0,false)
	check(returned.model.position == returned.model.recovery_anchor,"recovery stays in the hometown")
	returned._restart()
	check(returned.model.inventory.coins == 14 and returned.model.weapon == "crossbow","restarting the town walk keeps purchases and equipment")
	for i in 5: await process_frame
	var changes := [0]
	for node in returned.get_children():
		if node is Button: node.visibility_changed.connect(func(): changes[0] += 1)
	for i in 30:
		returned._update_view(0)
		await process_frame
	check(changes[0] == 0,"hometown does not reintroduce tutorial visibility churn")
	var route = get_meta("wendmere_training_route")
	route.record("town_roundtrip")
	returned.model.position.x = returned.model.world_width-60
	returned._start_tutorial()
	await process_frame
	await process_frame
	var revisited = current_scene
	revisited.set_physics_process(false)
	check(revisited.tutorial == route and revisited.tutorial.actions.has("town_roundtrip"),"reentering training preserves its map and objective state")
	check(revisited.model.position.x > 85 and revisited.model.inventory.coins == 14,"reentry keeps loot and clears the return trigger")
	if not failed: print("PASS: hometown bounds, merchant, patrol, travel, shared inventory, return, recovery and stable controls")
	quit(1 if failed else 0)
