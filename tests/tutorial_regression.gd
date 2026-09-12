extends SceneTree
const Clearing = preload("res://prototypes/training_clearing/training_clearing.tscn")
var failures := 0
func _initialize() -> void: _run.call_deferred()
func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: "+message)

func _run() -> void:
	var scene = Clearing.instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	check(not scene.tutorial.started,"free clearing remains the default")
	scene._start_tutorial()
	var guide = scene.tutorial
	var trail = scene.model
	var inventory = trail.inventory
	var progress = trail.progression
	check(trail.map_id == "trail" and trail.enemies.is_empty(),"first map is safe")
	check(not trail.can_talk_to_rowan(),"no invisible merchant on the trail")
	trail.position.x = trail.world_width-50
	scene._travel_map()
	check(scene.model == trail,"exit waits for movement practice")
	trail.position = Vector2(160,480)
	for i in 65: trail.step(.02,1,false)
	check(trail.jump(),"jump succeeds on ground")
	for i in 65: trail.step(.02,0,false)
	scene._update_view(0)
	check(trail.grounded and trail.position.y == 390,"real physics lands on the trail ledge")
	check(guide.map_ready(),"walking, jumping and landing open the exit")
	trail.position = Vector2(trail.world_width-50,480)
	trail.health = 83
	trail.mana = 71
	trail.lineage_cooldowns[0] = 2
	scene._travel_map()
	var yard = scene.model
	check(yard != trail and yard.map_id == "yard" and yard.enemies.size() == 2,"portal loads a separate combat map")
	check(yard.inventory == inventory and yard.progression == progress,"map transitions share inventory and hero progression")
	check(yard.health == 83 and yard.mana == 71 and yard.lineage_cooldowns[0] == 2,"travel cannot refill resources or cooldowns")
	check(yard.position == Vector2(160,480),"arrival clears the portal trigger")
	var exploration_before: int = progress.xp.exploration
	yard.step(.01,0,false)
	check(progress.xp.exploration == exploration_before+25,"new map discoveries do not collide with the trail")
	yard.step(.01,0,false)
	check(progress.xp.exploration == exploration_before+25,"remaining in a discovered section cannot farm exploration")
	yard.position.x = 60
	scene._travel_map()
	check(scene.model == trail and guide.index == 0,"west portal returns to the same trail")
	check(trail.position.x == trail.world_width-160,"return arrival does not immediately bounce back")
	trail.position.x = trail.world_width-50
	scene._travel_map()
	check(scene.model == yard,"visited map state is reused")
	yard.position = Vector2(160,480)
	check(yard.begin_attack(),"weapon practice accepted")
	yard.attack_time = 0
	yard.lineage_cooldowns[0] = 0
	check(yard.begin_lineage_skill(0),"first lineage skill is available")
	yard.attack_time = 0
	scene._potion("mana")
	check(guide.actions.has("mana"),"successful potion use counts")
	yard.potion_cooldown = 0
	yard.health = 50
	scene._potion("hp")
	check(guide.actions.has("health"),"health prompt responds to actual healing")
	# Real hits/rewards exercise the loot gate; damage amount just shortens combat.
	for enemy in yard.enemies: yard._damage_enemy(enemy,false,999)
	check(not guide.map_ready(),"loot must be collected before leaving")
	for drop in yard.loot.duplicate():
		yard.position = drop.position
		yard.step(.01,0,false)
	check(guide.map_ready(),"combat and collected rewards open camp")
	yard.position = Vector2(yard.world_width-50,480)
	scene._travel_map()
	var camp = scene.model
	check(camp.map_id == "camp" and camp.enemies.is_empty() and camp.rowan_enabled,"camp is a separate safe trading map")
	check(camp.inventory.coins == 16,"coins survive map transfer exactly once")
	camp.position.x = 250
	scene._talk_to_rowan()
	check(scene.paused and is_instance_valid(scene.dialogue),"merchant remains usable")
	scene._open_shop()
	check(not camp.buy_from_rowan(999,camp.inventory.revision).ok,"invalid purchase rejected")
	check(not guide.actions.has("buy"),"failed action does not complete training")
	check(camp.buy_from_rowan(0,camp.inventory.revision).ok,"buy a potion with earned coins")
	check(camp.sell_to_rowan(-1,"hp",camp.inventory.revision).ok,"sell a spare potion")
	scene._close_rowan()
	scene._toggle_inventory()
	check(camp.change_equipment(0),"equip the crossbow earned in the yard")
	scene._equipment_changed()
	scene._update_view(0)
	check(scene.menu_hint.visible and not scene.tutorial_panel.visible,"menus get a short contextual hint")
	scene._toggle_inventory()
	scene._toggle_skills()
	scene.skill_overview.show_disciplines()
	scene._update_view(0)
	check(guide.actions.has("disciplines"),"discipline page visit counts")
	scene._toggle_skills()
	check(guide.map_ready(),"trading, equipment and progression open the final map")
	camp.position = Vector2(camp.world_width-50,480)
	camp.projectiles.append({"life":1})
	scene._travel_map()
	check(scene.model == camp,"projectiles prevent unsafe transfer")
	camp.projectiles.clear()
	scene._toggle_pause()
	scene._travel_map()
	check(scene.model == camp,"paused menus cannot transfer")
	scene._toggle_pause()
	scene._travel_map()
	var grove = scene.model
	check(grove.map_id == "grove" and grove.enemies.size() == 1 and grove.enemies[0].elite,"final map has its own elite")
	check(grove.weapon == "crossbow" and scene.avatar.loadout.weapon == "crossbow","equipped appearance and combat stay in sync")
	grove.health = 0
	grove.death_time = .01
	grove.step(.02,0,false)
	check(grove.health == 100 and grove.position == grove.recovery_anchor and guide.index == 3,"death respawns in the current map")
	grove._damage_enemy(grove.enemies[0],false,999)
	scene._update_view(0)
	check(guide.finished,"final victory completes automatically")
	grove.position.x = 60
	scene._travel_map()
	check(scene.model == camp,"return to trading after completion")
	camp.position.x = 60
	scene._travel_map()
	check(scene.model == yard and yard.enemies.all(func(enemy): return enemy.hp <= 0),"returning never respawns defeated enemies")
	var coins: int = inventory.coins
	yard.step(.02,0,false)
	check(inventory.coins == coins,"revisits cannot duplicate rewards")
	scene._toggle_tutorial_hints()
	check(not guide.active and scene.attack_button.visible,"hiding hints retains touch controls")
	var current = scene.model
	scene._toggle_tutorial_hints()
	check(guide.active and scene.model == current,"hints resume without changing maps")
	scene._restart()
	check(scene.model.map_id == "trail" and scene.tutorial.actions.is_empty(),"restart resets the route")
	check(scene.model.inventory.coins == 0 and scene.model.weapon == "crossbow","restart keeps outfit but resets local loot")
	check(scene.tutorial.visits.size() == 1,"restart clears old encounter states")
	scene.free()
	for lineage in CharacterCatalog.race_ids():
		var outfit: Dictionary = CharacterCatalog.reference_loadout(lineage)
		outfit.weapon = "none"
		outfit.offhand = "none"
		set_meta("training_character",{"lineage":lineage,"loadout":outfit})
		set_meta("start_clearing_tutorial",true)
		var unarmed = Clearing.instantiate()
		root.add_child(unarmed)
		unarmed.set_physics_process(false)
		check(unarmed.model.weapon == "none" and unarmed.model.inventory.items.size() == 1,"unarmed "+lineage+" gets a pouch sword")
		unarmed._start_tutorial()
		check(unarmed.model.inventory.items.size() == 1,"resume never duplicates supplies")
		check(unarmed.model.change_equipment(0),"all lineages can equip training weapon")
		check(unarmed.model.begin_lineage_skill(0),"all lineages have a usable starting skill")
		unarmed.free()
	if failures == 0: print("PASS: four maps, physical traversal, action gates, shared gear, trading, recovery, return portals and all lineages")
	quit(1 if failures else 0)
