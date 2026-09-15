extends SceneTree
const Journey = preload("res://prototypes/human_hometown/town_save.gd")
const Model = preload("res://prototypes/human_hometown/town_encounter.gd")
const Districts = preload("res://prototypes/human_hometown/districts.gd")
const Route = preload("res://prototypes/training_clearing/tutorial.gd")
var failed := false
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var model = Model.new()
	model.configure_map(Districts.spec("solar"))
	model.inventory.configure("human",CharacterCatalog.reference_loadout("human"))
	model.progression = Journey.Profiles.get_profile(self,"human")
	model.position = Vector2(1000,340)
	model.health = 37
	model.mana = 22
	model.stamina = 41
	model.inventory.grant({"coins":39,"items":[{"slot":"weapon","id":"axe"}]})
	model.potion_cooldown = 2
	model.lineage_cooldowns[0] = 12
	model.ward = 80
	model.ward_time = 1
	set_meta("wendmere_districts",{"solar":model})
	set_meta("wendmere_quest",4)
	var route = Route.new()
	var saved := Journey.capture(self,model,route)
	saved.saved_at -= 30
	# Exercise the actual safe Variant encoding used on disk, without player save access.
	saved = bytes_to_var(var_to_bytes(saved))
	var result := Journey.restore(self,saved)
	check(result.ok,"checkpoint restores")
	var loaded = get_meta("wendmere_districts").solar
	check(loaded.position == Vector2(1000,340) and loaded.map_id == "wendmere_solar","current map and legal position restore together")
	check(loaded.health == 37 and loaded.mana == 22 and loaded.stamina == 41,"reconnect does not replenish resources")
	check(loaded.inventory.coins == 39 and loaded.inventory.items.size() == 1,"possessions survive exactly once")
	check(loaded.potion_cooldown == 2 and loaded.lineage_cooldowns[0] == 12,"cooldowns are not reset")
	check(loaded.ward == 0 and get_meta("wendmere_quest") == 4,"expired ward stays expired and quest survives")
	saved.maps.wendmere_solar.position = Vector2(9000,9000)
	saved.maps.wendmere_solar.health = 0
	saved.maps.wendmere_solar.death_time = 2
	check(Journey.restore(self,saved).ok,"dead checkpoint restores")
	loaded = get_meta("wendmere_districts").solar
	check(loaded.health == 0 and loaded.position == loaded.recovery_anchor,"invalid position recovers locally without reviving a dead hero")
	loaded.step(2.1,0,false)
	check(loaded.health > 0 and loaded.map_id == "wendmere_solar","death finishes its same-map recovery")
	saved.maps["missing_map"] = saved.maps.wendmere_solar
	saved.current = "missing_map"
	check(not Journey.restore(self,saved).ok,"missing map reports unavailable instead of teleporting home")
	var square = Model.new()
	square.invulnerable = 9
	model.invulnerable = 0
	square.configure_map(Districts.spec("square"))
	square.carry_player_from(model)
	check(square.invulnerable == 0,"revisiting a map does not restore its old invulnerability")
	set_meta("wendmere_districts",{"square":square})
	model.skill_cooldown = 3.5
	var training = route.start(model)
	check(training.skill_cooldown == 3.5,"training entry preserves the action cooldown")
	training.position = Vector2(630,480)
	training.health = 19
	training.mana = 17
	route.record("checkpoint_roundtrip")
	var training_saved := Journey.capture(self,training,route)
	check(Journey.restore(self,training_saved).ok,"training excursion restores")
	var scene = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	check(scene.model.map_id == "trail" and scene.model.position == Vector2(630,480),"scene resumes training map and position without a portal reset")
	check(scene.model.health == 19 and scene.model.mana == 17 and scene.model.inventory.coins == 39,"scene resume retains resources and possessions")
	check(scene.tutorial.actions.has("checkpoint_roundtrip") and has_meta("wendmere_model"),"training objectives and the hometown return survive reconnect")
	scene._toggle_world_map()
	check(scene.map_panel.current == "trail" and scene.map_panel.is_explored("square") and scene.map_panel.is_explored("trail"),"atlas uses restored current map and saved discovery across training and hometown")
	check(not scene.map_panel.is_explored("market"),"restoring a journey does not reveal unvisited submaps")
	scene._toggle_world_map()
	scene.queue_free()
	await process_frame
	if not failed: print("PASS: checkpoint roundtrip, same-map recovery, resources, inventory, cooldowns, expired wards and unavailable maps")
	quit(1 if failed else 0)
