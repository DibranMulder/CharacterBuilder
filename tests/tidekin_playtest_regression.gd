extends SceneTree
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Model = preload("res://prototypes/tidekin_sea/region_encounter.gd")
var failed := false
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func run() -> void:
	var scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	check(Region.maps().size() == 39,"all 39 authored maps are playable")
	check(scene.model.map_id == "tidekin_sea_land" and scene.model.enemies.is_empty(),"safe landing spawn")
	scene._toggle_world_map()
	check(scene.map_panel.region_id == "tidekin_sea" and scene.map_panel.selected_node == scene.model.map_id,"map opens current region with the hero selected")
	check(not scene.map_panel.is_explored("tidekin_sea_site_001"),"unvisited pools remain under fog")
	scene._toggle_world_map()
	check(scene.travel_to("tidekin_sea_path_001"),"connected portal reaches Shallows")
	check(scene.model.enemies.size() == 6,"six farming spawns")
	check(not scene.travel_to("tidekin_sea_return_101"),"unconnected destinations cannot teleport")
	var enemy: Dictionary = scene.model.enemies[0]
	scene.model.position = Vector2(enemy.x-70,480)
	scene.model._update_enemy(enemy,.01)
	check(enemy.state == "windup","Skitters telegraph attacks")
	scene.model.invulnerable = 0
	var hp: float = scene.model.health
	scene.model._update_enemy(enemy,1)
	check(scene.model.health < hp,"Skitters deal damage")
	scene.model._damage_enemy(enemy,false,99999)
	check(enemy.hp == 0 and scene.model.loot.size() == 1,"defeated monsters drop loot")
	var kills: int = scene.model.kills
	scene.model._damage_enemy(enemy,false,99999)
	check(scene.model.kills == kills,"dead monsters cannot pay twice")
	scene.model.advance_population(40,true)
	check(enemy.hp == 0,"respawn never occurs on top of player")
	scene.model.position.x = 180
	scene.model.advance_population(1,true)
	check(enemy.hp == 0 and enemy.spawn_warning > 0,"visible spawn warns before returning")
	scene.model.advance_population(1.1,true)
	check(enemy.hp == enemy.max_hp,"regular enemies respawn after 30 seconds plus warning")
	scene.model._damage_enemy(enemy,false,99999)
	check(scene.travel_to("tidekin_sea_site_001"),"peaceful aid branch")
	scene._physics_process(31)
	check(enemy.hp > 0,"respawn timers continue while farming a neighboring map")
	for i in 3:
		scene.model.position = scene.model.fixture_point(i)
		scene.interact()
	check(scene.repaired.has("ripplefin"),"three separate aid stations restore Ripplefin")
	check(scene.model.enemies.is_empty(),"benevolent wildlife remains nonhostile")
	var covered := {}
	for spec in Region.maps():
		var model = Model.new()
		model.configure_region(spec)
		for species in spec.species: covered[species] = true
		for neighbor in spec.neighbors:
			check(spec.id in Region.spec(neighbor).neighbors,"reciprocal route: "+spec.id)
		for creature in model.enemies:
			check(creature.level >= spec.level and creature.level <= spec.level_max,"spawn levels fit map range")
			if not creature.boss: check(creature.home >= 600 and creature.home <= spec.width-450,"arrival areas clear")
		check(ResourceLoader.exists("res://assets/maps/tidekin/"+spec.art+".png"),"painted map kit exists")
	check(covered.size() == 16,"all sixteen creatures have regional encounters")
	check(not Region.allowed("tidekin_sea_gs","orc",true).is_empty(),"Citadel enforces allegiance")
	check(not Region.allowed("tidekin_sea_sc","human",false).is_empty(),"shrine requires investigation")
	scene.model.health = 0
	scene.model.death_time = .01
	scene.model.step(.1,0,false)
	check(scene.model.position == scene.model.recovery_anchor,"death recovers on same map")
	scene.free()
	if not failed: print("PASS: 39 maps, 16 creatures, combat, six-spawn farming, repeat rewards, safe respawns, inactive timers, aid, fog and gates")
	quit(1 if failed else 0)
