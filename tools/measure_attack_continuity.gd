extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const SAMPLE_STEP := 1.0/240.0
const SAMPLES := [
	{"race":"human", "weapon":"sword", "attack":&"jab", "curve":"sword"},
	{"race":"duneborn", "weapon":"spear", "attack":&"jab", "curve":"spear"},
	{"race":"human", "weapon":"sword", "attack":&"forehand", "curve":"sword"},
	{"race":"human", "weapon":"sword", "attack":&"backhand", "curve":"sword"},
	{"race":"frost_troll", "weapon":"axe", "attack":&"forehand", "curve":"two_handed_axe"},
	{"race":"frost_troll", "weapon":"axe", "attack":&"backhand", "curve":"two_handed_axe"},
]


func _initialize() -> void:
	_measure.call_deferred()


func _measure() -> void:
	var avatar := Avatar.new()
	root.add_child(avatar)
	await process_frame
	for sample in SAMPLES:
		var attack_id: StringName = sample.attack
		avatar.configure(sample.race,{"weapon":sample.weapon,"offhand":"none"})
		var curve: Array = Avatar.ATTACK_CURVES[attack_id] if sample.curve == "sword" else Avatar.WEAPON_ATTACK_CURVES[sample.curve][attack_id]
		var contact_time := 0.0
		for pose in curve:
			contact_time += float(pose.duration)
			if pose.phase == "strike":
				break
		avatar.play_weapon_attack(attack_id)
		var weapon: GearVisual = avatar._gear.weapon
		var previous_tip := weapon.to_global(weapon.reach_endpoint())
		var velocities: Array[Vector2] = []
		var sample_times: Array[float] = []
		var elapsed := 0.0
		while elapsed < contact_time+.05:
			avatar._active_tween.custom_step(SAMPLE_STEP)
			weapon.force_update_transform()
			var tip := weapon.to_global(weapon.reach_endpoint())
			velocities.append((tip-previous_tip)/SAMPLE_STEP)
			sample_times.append(elapsed+SAMPLE_STEP)
			previous_tip = tip
			elapsed += SAMPLE_STEP
		var before_index := _nearest_sample(sample_times,contact_time-SAMPLE_STEP*.5)
		var after_index := _nearest_sample(sample_times,contact_time+SAMPLE_STEP*.5)
		var before: Vector2 = velocities[before_index]
		var after: Vector2 = velocities[after_index]
		var ratio := maxf(before.length(),after.length())/maxf(minf(before.length(),after.length()),.001)
		var direction_dot := before.normalized().dot(after.normalized())
		print("%s %s %s contact: pre (%.1f, %.1f) %.1f px/s, post (%.1f, %.1f) %.1f px/s, ratio %.2f, direction dot %.3f" % [sample.race,sample.weapon,attack_id,before.x,before.y,before.length(),after.x,after.y,after.length(),ratio,direction_dot])
	quit()


func _nearest_sample(times: Array[float],target: float) -> int:
	var nearest := 0
	var distance := INF
	for index in times.size():
		var candidate := absf(times[index]-target)
		if candidate < distance:
			distance = candidate
			nearest = index
	return nearest
