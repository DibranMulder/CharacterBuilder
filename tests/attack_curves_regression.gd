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
	if absf(jab_chamber_angle) > 2.0 or absf(jab_strike_angle) > 2.0:
		_fail("jab must retract and extend along one horizontal line")
		return
	if absf(jab[0].forearm) <= absf(jab[1].forearm):
		_fail("jab chamber must bend more deeply than its extended strike")
		return
	if jab[0].forearm > -100.0 or jab[1].upper > -50.0:
		_fail("jab must use a deep chamber and a long forward extension")
		return
	var forehand_overhead_angle: float = forehand[1].upper + forehand[1].forearm
	var forehand_strike_angle: float = forehand[2].upper + forehand[2].forearm
	var forehand_reachback_angle: float = forehand[0].upper + forehand[0].forearm
	var forehand_followthrough_angle: float = forehand[3].upper + forehand[3].forearm
	if absf(forehand_reachback_angle + 260.0) > 2.0:
		_fail("forehand must angle the weapon up and back past the face")
		return
	if absf(forehand_overhead_angle + 110.0) > 2.0:
		_fail("forehand must load the weapon into a high diagonal guard")
		return
	var reachback_elbow_angle: float = 180.0-absf(forehand[0].forearm)
	if absf(reachback_elbow_angle-110.0) > 1.0 or forehand[0].forearm >= 0:
		_fail("forehand reach-back must retain a strongly folded elbow")
		return
	if absf(forehand_strike_angle - 30.0) > 2.0:
		_fail("forehand must slash diagonally through the target")
		return
	if absf(forehand_followthrough_angle - 80.0) > 2.0:
		_fail("forehand must continue beyond the target into its follow-through")
		return
	if forehand_strike_angle-forehand_overhead_angle < 130.0 or forehand[2].duration > 0.13:
		_fail("forehand cutting phase must be broad and fast")
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
