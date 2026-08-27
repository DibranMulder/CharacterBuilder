extends SceneTree

const Avatar := preload("res://src/modular_character.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var attacks := Avatar.WEAPON_ATTACKS
	if attacks != [&"jab", &"forehand", &"backhand"]:
		_fail("expected exactly jab, forehand, and backhand")
		return

	var jab: Array = Avatar.ATTACK_CURVES.jab
	var forehand: Array = Avatar.ATTACK_CURVES.forehand
	var backhand: Array = Avatar.ATTACK_CURVES.backhand
	var jab_chamber_angle: float = jab[0].upper + jab[0].forearm
	var jab_strike_angle: float = jab[1].upper + jab[1].forearm
	if absf(jab_chamber_angle + 90.0) > 2.0 or absf(jab_strike_angle + 90.0) > 2.0:
		_fail("jab must retract and extend along one horizontal line")
		return
	if jab[0].forearm >= jab[1].forearm:
		_fail("jab chamber must bend more deeply than its extended strike")
		return
	if jab[0].forearm > -150.0:
		_fail("jab must retract the hand nearly back to the shoulder")
		return
	var forehand_overhead_angle: float = forehand[1].upper + forehand[1].forearm
	var forehand_strike_angle: float = forehand[2].upper + forehand[2].forearm
	var forehand_reachback_angle: float = forehand[0].upper + forehand[0].forearm
	if absf(forehand_reachback_angle + 225.0) > 2.0:
		_fail("forehand must angle the weapon up and back past the face")
		return
	if absf(forehand_overhead_angle + 180.0) > 2.0:
		_fail("forehand must raise the weapon vertically overhead")
		return
	for pose in [forehand[0], forehand[1]]:
		var elbow_interior_angle: float = 180.0 - absf(pose.forearm)
		if absf(elbow_interior_angle - 120.0) > 1.0:
			_fail("forehand rearward poses must keep an approximately 120-degree elbow bend")
			return
		if pose.forearm >= 0:
			_fail("forehand elbow must fold toward the weapon side, not reverse away from it")
			return
	if absf(forehand_strike_angle + 45.0) > 2.0:
		_fail("forehand must smash diagonally down and forward")
		return
	if backhand[0].upper <= 0 or backhand[1].upper >= 0:
		_fail("backhand must reverse from across the body to the weapon side")
		return

	var avatar := Avatar.new()
	root.add_child(avatar)
	await process_frame
	for attack in attacks:
		avatar.play_weapon_attack(attack)
		if avatar._active_tween == null or not avatar._active_tween.is_valid():
			_fail("%s did not create an animation" % attack)
			return

	print("PASS: jab, forehand, and backhand use distinct two-joint arm curves")
	quit()


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
