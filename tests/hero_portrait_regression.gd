extends SceneTree
const Portrait = preload("res://src/ui/character_portrait.gd")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for lineage in CharacterCatalog.race_ids():
		var portrait := Portrait.new()
		root.add_child(portrait)
		var outfit := CharacterCatalog.reference_loadout(lineage)
		portrait.configure(lineage,outfit)
		assert(portrait.lineage == lineage and portrait.outfit == outfit)
		assert(portrait.character.loadout.head == outfit.head)
		assert(portrait.character.position.is_finite())
		assert(portrait.viewport.render_target_update_mode == SubViewport.UPDATE_ONCE)
		portrait.viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		portrait.configure(lineage,outfit)
		assert(portrait.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED, "unchanged portrait must remain cached")
		outfit.head = "helm" if outfit.head != "helm" else "none"
		portrait.configure(lineage,outfit)
		assert(portrait.character.loadout.head == outfit.head)
		assert(portrait.viewport.render_target_update_mode == SubViewport.UPDATE_ONCE)
		assert(not portrait.character._gear.weapon.visible)
		portrait.free()
	print("PASS: all lineage portraits, equipped headgear, finite framing and redraw caching")
	quit()
