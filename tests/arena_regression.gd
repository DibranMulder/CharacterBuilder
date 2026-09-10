extends SceneTree
const Duel = preload("res://prototypes/sparring_arena/duel.gd")
const Fighter = preload("res://prototypes/sparring_arena/fighter.gd")
const Skills = preload("res://prototypes/sparring_arena/lineage_skills.gd")

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	for lineage in CharacterCatalog.race_ids():
		assert(Skills.kit(lineage).size() == 4)
		for slot in 4:
			var duel = Duel.new()
			duel.configure(lineage,CharacterCatalog.reference_loadout(lineage),"human")
			duel.countdown = 0
			duel.brain_time = 100
			var actor = duel.fighters[0]
			actor.health = 50
			duel.fighters[1].position.x = 350
			assert(duel.request(slot),"Each lineage skill must activate")
			var cost: float = actor.skills[slot].mana
			assert(actor.mana == 100-cost and actor.cooldowns[slot] > 0)
			assert(not duel.request(slot),"No duplicate activation during commitment")
			for frame in 100: duel.step(.016,0,false)
			var kind: String = actor.skills[slot].kind
			if kind == "heal": assert(actor.health > 50)
			elif kind == "ward": assert(actor.ward > 0)
			elif kind == "retreat": assert(actor.position.x < 260)
			else: assert(duel.fighters[1].health < 100,"Offensive skill must resolve: "+lineage+" / "+kind)
			actor.action = {}
			actor.cooldowns[slot] = 0
			actor.mana = 0
			assert(not actor.request(slot) and actor.mana == 0)
		var sim = Duel.new()
		sim.configure("human",CharacterCatalog.reference_loadout("human"),lineage,1)
		for frame in 2400: sim.step(1.0/60,0,false)
		assert(sim.fighters[1].serial > 0,"Bot must use attacks")
		assert(sim.fighters[0].health < 100,"Bot must engage the player")
		for actor in sim.fighters:
			assert(actor.mana >= 0 and actor.mana <= 100 and actor.health >= 0)
	var duel = Duel.new()
	duel.configure("human",CharacterCatalog.reference_loadout("human"),"goblin")
	assert(not duel.request(0),"Countdown must block attacks")
	duel.countdown = 0
	duel.fighters[0].guarding = true
	duel.fighters[0].facing = 1
	duel._hit(1,20,"rootbolt",800)
	assert(duel.fighters[0].health == 95 and duel.fighters[0].rooted == 0)
	duel._hit(1,20,"rootbolt",100)
	assert(duel.fighters[0].health == 75 and duel.fighters[0].rooted > 0)
	assert(Duel._segment_hits(Vector2(0,400),Vector2(1000,400),Rect2(490,350,44,120)),"Swept projectiles must not tunnel")
	assert(not Duel._segment_hits(Vector2(0,200),Vector2(1000,200),Rect2(490,350,44,120)))
	duel.fighters[0].health = 0
	duel.step(.016,0,false)
	assert(duel.winner == 1)
	var frozen: Vector2 = duel.fighters[1].position
	duel.step(10,1,false)
	assert(duel.fighters[1].position == frozen and not duel.request(0))
	get_tree_meta()
	print("PASS: 32 skills, bot engagement for 8 lineages, mana/cooldown rules, guarding, swept hits, round freeze and arena UI")
	quit()

func get_tree_meta() -> void:
	var outfit := CharacterCatalog.reference_loadout("human")
	outfit.weapon = "crossbow"
	outfit.offhand = "none"
	set_meta("training_character",{"lineage":"human","loadout":outfit,"facing":&"left"})
	var scene = load("res://prototypes/sparring_arena/arena.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	assert(scene.model.fighters[0].loadout == outfit)
	assert(scene.avatars[0].loadout == outfit)
	assert(not "human" in scene.opponents and scene.skill_buttons.size() == 6)
	scene._set_paused(true)
	scene._attack(0)
	assert(scene.model.fighters[0].mana == 100)
	scene.rematch()
	assert(scene.model.countdown == 2 and not scene.paused)
	scene.model.countdown = 0
	var key := InputEventKey.new()
	key.physical_keycode = KEY_3
	key.pressed = true
	scene._unhandled_key_input(key)
	assert(scene.model.fighters[0].serial == 1)
	for child in scene.get_children():
		if child is Button and child.text == "←  A":
			child.button_down.emit()
			assert(scene.held.left and not scene.held.right)
			child.button_up.emit()
			assert(not scene.held.left)
	scene.free()
