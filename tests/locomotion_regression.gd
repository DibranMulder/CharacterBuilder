extends SceneTree

const Avatar := preload("res://src/modular_character.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if Avatar.MOTIONS != [&"idle", &"run", &"climb"]:
		_fail("expected idle, run, and climb motions")
		return
	var avatar := Avatar.new()
	root.add_child(avatar)
	await process_frame
	var mirrored_weapon: GearVisual = avatar._gear.weapon
	mirrored_weapon.force_update_transform()
	var right_grip := mirrored_weapon.global_position - avatar.global_position
	var right_tip := mirrored_weapon.to_global(mirrored_weapon.reach_endpoint()) - avatar.global_position
	avatar.set_facing(&"left")
	if avatar.facing != &"left" or avatar._bones.rig.scale.x >= 0:
		_fail("left facing must mirror the complete modular rig")
		return
	if avatar._gear.weapon.get_parent() != avatar._bones.right_forearm:
		_fail("left-facing weapon must remain on the fixed anatomical right-arm socket")
		return
	if avatar._gear.offhand.get_parent() != avatar._bones.left_forearm or not avatar._gear.offhand.shield_exterior:
		_fail("left-facing shield must stay on the offhand and show its exterior")
		return
	mirrored_weapon.force_update_transform()
	var left_grip := mirrored_weapon.global_position - avatar.global_position
	var left_tip := mirrored_weapon.to_global(mirrored_weapon.reach_endpoint()) - avatar.global_position
	var expected_left_grip := Vector2(-right_grip.x, right_grip.y)
	var expected_left_tip := Vector2(-right_tip.x, right_tip.y)
	if not left_grip.is_equal_approx(expected_left_grip) or not left_tip.is_equal_approx(expected_left_tip):
		_fail("left-facing weapon pose must be an exact horizontal mirror of right-facing")
		return
	avatar.set_facing(&"right")
	if avatar._gear.weapon.get_parent() != avatar._bones.right_forearm or avatar._gear.offhand.get_parent() != avatar._bones.left_forearm or avatar._gear.offhand.shield_exterior:
		_fail("right-facing equipment did not restore its original hand presentation")
		return

	for race_id in CharacterCatalog.race_ids():
		avatar.configure(race_id, {})
		var knee_bone := "horse_shin_0" if CharacterCatalog.race(race_id).topology == "centaur" else "left_shin"
		if not avatar._bones.has(knee_bone):
			_fail("%s run rig has no knee/shin joint" % race_id)
			return
		avatar.play_motion(&"run")
		if avatar.current_motion != &"run" or avatar._active_tween == null:
			_fail("%s did not start its run loop" % race_id)
			return
		avatar._active_tween.custom_step(.16)
		var run_bone := "horse_leg_0" if CharacterCatalog.race(race_id).topology == "centaur" else "left_leg"
		if is_equal_approx(avatar._bones[run_bone].rotation, avatar._rest[run_bone].rotation):
			_fail("%s run loop did not move its legs" % race_id)
			return
		if is_equal_approx(avatar._bones[knee_bone].rotation, avatar._rest[knee_bone].rotation):
			_fail("%s run loop left its knee rigid" % race_id)
			return

		avatar.play_motion(&"climb")
		if avatar.current_motion != &"climb" or avatar._active_tween == null:
			_fail("%s did not start its climb loop" % race_id)
			return
		avatar._active_tween.custom_step(.28)
		var forearm_length: float = CharacterCatalog.race(race_id).arm * .48
		var torso: Node2D = avatar._bones.torso
		var left_pull_a := torso.to_local(avatar._bones.left_forearm.to_global(Vector2(0,forearm_length)))
		var right_pull_a := torso.to_local(avatar._bones.right_forearm.to_global(Vector2(0,forearm_length)))
		avatar._active_tween.custom_step(.28)
		var left_pull_b := torso.to_local(avatar._bones.left_forearm.to_global(Vector2(0,forearm_length)))
		var right_pull_b := torso.to_local(avatar._bones.right_forearm.to_global(Vector2(0,forearm_length)))
		var left_pull_delta := left_pull_b.y-left_pull_a.y
		var right_pull_delta := right_pull_b.y-right_pull_a.y
		if absf(left_pull_delta) < 5.0 or absf(right_pull_delta) < 5.0 or left_pull_delta*right_pull_delta >= 0.0:
			_fail("%s climb loop must alternate two meaningful opposing arm pulls" % race_id)
			return
		if not avatar._head_visual.back_view:
			_fail("%s climb loop did not switch to the rear view" % race_id)
			return
		var weapon: GearVisual = avatar._gear.weapon
		var shield: GearVisual = avatar._gear.offhand
		if weapon.get_parent() != avatar._bones.torso or shield.get_parent() != avatar._bones.torso:
			_fail("%s did not move equipped weapon and shield onto its back" % race_id)
			return
		if not weapon.carried_on_back or not shield.carried_on_back:
			_fail("%s back-mounted equipment did not switch presentation" % race_id)
			return
		if is_equal_approx(avatar._bones.right_arm.rotation, avatar._rest.right_arm.rotation):
			_fail("%s climb loop did not alternate its reaching arms" % race_id)
			return
		avatar.stop_motion()
		if avatar.current_motion != &"idle":
			_fail("%s did not return to idle" % race_id)
			return
		if avatar._head_visual.back_view:
			_fail("%s did not restore its side-facing head after climbing" % race_id)
			return
		if weapon.get_parent() != avatar._bones.right_forearm or shield.get_parent() != avatar._bones.left_forearm:
			_fail("%s did not return equipment to its hand sockets" % race_id)
			return
		avatar.set_facing(&"left")
		avatar.play_motion(&"run")
		if avatar._bones.rig.scale.x >= 0:
			_fail("%s did not preserve left orientation while running" % race_id)
			return
		avatar.stop_motion()
		avatar.set_facing(&"right")

	print("PASS: all 8 races run both directions, climb rear-facing, and return to idle")
	quit()


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
