extends SceneTree
const Overlay = preload("res://prototypes/training_clearing/combat_overlay.gd")
const Encounter = preload("res://prototypes/training_clearing/encounter.gd")

func _initialize() -> void:
	var overlay := Overlay.new()
	root.add_child(overlay)
	for kind in ["dealt", "power", "taken", "blocked", "xp", "level", "notice"]:
		overlay.push({"kind":kind, "text":"24", "position":Vector2(400,300), "impact":Vector2(400,400)})
	assert(overlay.z_index > 100, "numbers must render above the rig")
	assert(overlay.floaters.size() == 7)
	assert(overlay.floaters[0].position != overlay.floaters[1].position)
	assert(overlay.hurt_time > 0)
	overlay.advance(.3)
	assert(overlay.hurt_time == 0 and overlay.floaters.size() == 7)
	overlay.advance(1)
	assert(overlay.floaters.is_empty())
	overlay.push({"text":"Recovered", "position":Vector2.ZERO})
	assert(overlay.floaters[0].kind == "notice")
	overlay.reset()
	assert(overlay.floaters.is_empty())
	# Supplied rig muzzle is the origin, in either facing. No tunnelling on a long step.
	for direction in [-1.0, 1.0]:
		var model = Encounter.new()
		model.weapon = "crossbow"
		model.position.x = 650 - 200 * direction
		model.facing = direction
		assert(model.begin_attack())
		var muzzle := Vector2(650 - 160 * direction, 365)
		model.step(.38, 0, false, muzzle)
		assert(model.enemies[0].hp == 24, "shot from supplied socket must hit once in either facing")
		assert(model.projectiles.is_empty())
	print("PASS: Field Notes categories, layering, spacing, expiry and aimed muzzle collision")
	quit()
