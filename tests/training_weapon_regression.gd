extends SceneTree
const Encounter = preload("res://prototypes/training_clearing/encounter.gd")

func _initialize() -> void:
	for weapon in CharacterCatalog.items_for(&"weapon"):
		var model = Encounter.new()
		model.configure_equipment({"weapon": weapon, "offhand": "lantern"})
		model.position.x = 430 if model.is_ranged() else 550
		var accepted: bool = model.begin_attack()
		if accepted != (weapon != "none"):
			_fail("empty weapon must not attack")
			return
		for frame in 90:
			model.step(1.0 / 60, 0, false)
		if weapon != "none" and model.enemies[0].hp != 50 - model.weapon_feel().damage:
			_fail("equipped %s must hit exactly once" % weapon)
			return
		model.step(.01, 0, true)
		if model.guarding:
			_fail("lantern must not grant shield guard")
			return
		model.configure_equipment({"weapon": weapon, "offhand": "dune_shield"})
		model.step(.01, 0, true)
		if not model.guarding:
			_fail("equipped shield must enable guard")
			return
	print("PASS: every equipped weapon resolves an attack; empty hand stays empty; guard follows offhand")
	quit()

func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
