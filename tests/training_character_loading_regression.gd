extends SceneTree

const Clearing := preload("res://prototypes/training_clearing/training_clearing.tscn")
const Builder := preload("res://main.tscn")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for lineage in CharacterCatalog.race_ids():
		var outfit := CharacterCatalog.reference_loadout(lineage)
		outfit.head = "none"
		set_meta("training_character", {"lineage": lineage, "loadout": outfit.duplicate()})
		var clearing := Clearing.instantiate()
		root.add_child(clearing)
		if clearing.avatar.race_id != lineage or clearing.avatar.loadout != outfit:
			_fail("clearing must preserve the complete builder configuration for " + lineage)
			return
		for slot in CharacterCatalog.SLOT_ORDER:
			if clearing.avatar.loadout[slot] != outfit[slot]:
				_fail("outfit changed for %s / %s" % [lineage, slot])
				return
		clearing.avatar.present_static_pose("guard")
		clearing.avatar.present_static_pose("air")
		clearing._physics_process(1.0 / 60)
		if not clearing.avatar.projectile_socket().is_finite():
			_fail("weapon socket must be finite for " + lineage)
			return
		clearing._restart()
		if clearing.avatar.race_id != lineage or clearing.avatar.loadout != outfit or clearing.model.weapon != outfit.weapon:
			_fail("restart lost selected lineage")
			return
		clearing.free()
		var builder := Builder.instantiate()
		root.add_child(builder)
		if builder.avatar.race_id != lineage or builder.avatar.loadout != outfit:
			_fail("return to builder lost original outfit for " + lineage)
			return
		builder.free()
	remove_meta("training_character")
	print("PASS: eight lineages preserve exact builder loadouts and weapon rules through play, restart and return")
	quit()

func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
