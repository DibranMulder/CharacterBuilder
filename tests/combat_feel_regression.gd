extends SceneTree
const Duel = preload("res://prototypes/sparring_arena/duel.gd")
const Reaction = preload("res://src/ui/combat_reaction.gd")

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var duel := Duel.new()
	duel.configure("human",CharacterCatalog.reference_loadout("human"),"human")
	var target = duel.fighters[1]
	target.guarding = true
	duel._hit(0,20,"melee",260)
	assert(target.health == 95 and target.flash == 0)
	assert(duel.events[-1].kind == "blocked" and duel.events[-1].target == 1)
	target.guarding = false
	target.ward = 30
	duel.events.clear()
	duel._hit(0,20,"melee",260)
	assert(target.health == 95 and target.ward == 10)
	assert(duel.events.size() == 1 and duel.events[0].kind == "ward")
	duel.events.clear()
	duel._hit(0,20,"melee",260)
	assert(target.health == 85 and duel.events.size() == 2)
	assert(duel.events[0].text == "ABSORB 10" and duel.events[1].text == "10")
	duel.fighters[0].health = 50
	duel.events.clear()
	duel._hit(0,20,"drain",260)
	assert(duel.fighters[0].health == 60)
	assert(duel.events[0].kind == "heal" and duel.events[0].target == 0)
	var reaction := Reaction.new()
	reaction.receive({"kind":"dealt","direction":-1.0})
	reaction.advance(.08)
	assert(reaction.offset().x < 0 and reaction.offset().length() <= 8)
	reaction.advance(1)
	assert(reaction.offset() == Vector2.ZERO and reaction.tint() == Color.WHITE)
	for kind in ["heal","ward","blocked"]:
		reaction.receive({"kind":kind})
		assert(reaction.offset() == Vector2.ZERO and reaction.tint() != Color.WHITE)
	# Skill releases must use the supplied gesture origin, not a torso default.
	duel.configure("goblin",CharacterCatalog.reference_loadout("goblin"),"human")
	assert(duel.fighters[0].request(0))
	duel.muzzles[0] = Vector2(315,320)
	duel._release(0)
	assert(duel.projectiles[-1].position == Vector2(315,320))
	var clearing = preload("res://prototypes/training_clearing/encounter.gd").new()
	clearing.inventory.configure("goblin",CharacterCatalog.reference_loadout("goblin"))
	assert(clearing.begin_lineage_skill(0))
	clearing._release_lineage_skill(Vector2(205,333))
	assert(clearing.projectiles[-1].position == Vector2(205,333))
	# A melee swing cannot hit behind its locked facing or outside its reach.
	duel.configure("human",CharacterCatalog.reference_loadout("human"),"goblin")
	duel.fighters[0].request(0)
	duel.fighters[1].position.x = 200
	duel._release(0)
	assert(duel.fighters[1].health == 100)
	duel.fighters[1].position.x = 410
	duel._release(0)
	assert(duel.fighters[1].health == 100)
	print("PASS: distinct block/absorption/healing, bounded recoil, gesture projectile origins, facing and reach")
	quit()
