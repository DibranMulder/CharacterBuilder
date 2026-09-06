extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func advance(avatar: ModularCharacter, seconds: float) -> void:
	for step in int(round(seconds * 1000)):
		if avatar._active_tween:
			avatar._active_tween.custom_step(.001)


func _run() -> void:
	for race in CharacterCatalog.race_ids():
		var avatar := ModularCharacter.new()
		root.add_child(avatar)
		avatar.configure(race, CharacterCatalog.reference_loadout(race))
		for facing in [&"left", &"right"]:
			avatar.set_facing(facing)
			avatar.play_motion(&"jump")
			advance(avatar, .16)
			assert(avatar._bones.rig.position.y > 0, "Jump must crouch before takeoff")
			advance(avatar, .28)
			assert(avatar._bones.rig.position.y < -30, "Jump must reach an airborne apex")
			advance(avatar, .28)
			assert(absf(avatar._bones.rig.position.y) < 1, "Jump must return to ground before landing compression")
			advance(avatar, .30)
			assert(avatar.current_motion == &"stand", "Jump is a one-shot motion")
			assert(avatar._bones.rig.position.is_equal_approx(Vector2.ZERO))
			avatar.play_motion(&"jump")
			advance(avatar, .4)
			avatar.play_motion(&"stand")
			assert(avatar._bones.rig.position.is_equal_approx(Vector2.ZERO), "Interrupting jump must restore ground height")
		avatar.free()
	print("PASS: all lineages jump, land, recover and interrupt in both facings")
	quit()
