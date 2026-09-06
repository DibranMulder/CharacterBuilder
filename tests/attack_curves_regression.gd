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
	var spear_jab: Array = Avatar.WEAPON_ATTACK_CURVES.spear.jab
	if jab.map(func(phase: Dictionary): return phase.phase) != ["chamber","strike","follow"]:
		_fail("jab must accelerate from chamber through contact into a decelerating carry")
		return
	if forehand.map(func(phase: Dictionary): return phase.phase) != ["chamber","guard","strike","follow"]:
		_fail("forehand must flow through chamber, guard, strike, and follow-through")
		return
	if backhand.map(func(phase: Dictionary): return phase.phase) != ["chamber","guard","strike","follow"]:
		_fail("backhand must flow through chamber, guard, strike, and follow-through")
		return
	if Avatar.ATTACK_PHASE_EASING.strike.trans != Tween.TRANS_QUAD or Avatar.ATTACK_PHASE_EASING.strike.ease != Tween.EASE_IN or Avatar.ATTACK_PHASE_EASING.follow.trans != Tween.TRANS_QUAD or Avatar.ATTACK_PHASE_EASING.follow.ease != Tween.EASE_OUT:
		_fail("attack contact must use matched quadratic acceleration and follow-through")
		return
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
	var backhand_chamber_angle: float = backhand[0].torso+backhand[0].upper+backhand[0].forearm
	var backhand_guard_angle: float = backhand[1].torso+backhand[1].upper+backhand[1].forearm
	var backhand_strike_angle: float = backhand[2].torso+backhand[2].upper+backhand[2].forearm
	var backhand_follow_angle: float = backhand[3].torso+backhand[3].upper+backhand[3].forearm
	if backhand_chamber_angle < 125.0 or backhand_guard_angle < 65.0:
		_fail("backhand must load the blade across the body on a low diagonal")
		return
	if backhand_strike_angle > -50.0 or backhand[2].x < 24.0 or backhand[2].duration > .12:
		_fail("backhand must accelerate into a long rising contact pose")
		return
	if backhand_follow_angle > -80.0 or backhand[3].x < 15.0:
		_fail("backhand must carry hand and blade beyond contact before recovery")
		return
	if spear_jab.map(func(phase: Dictionary): return phase.phase) != ["chamber","strike","follow","recover"]:
		_fail("spear jab must chamber, thrust through contact, and recover upright")
		return
	for phase_index in [0,1,2]:
		var phase: Dictionary = spear_jab[phase_index]
		var world_spear_angle: float = fposmod(90.0+phase.torso+phase.upper+phase.forearm+phase.weapon_rotation,360.0)
		if minf(world_spear_angle,360.0-world_spear_angle) > 2.0:
			_fail("spear jab chamber and thrust must keep the shaft horizontal")
			return
	if spear_jab[0].upper < 80.0 or spear_jab[0].x > -25.0 or spear_jab[1].x < 35.0:
		_fail("spear jab must attack from a deep low chamber with long extension")
		return
	if not is_equal_approx(float(spear_jab[3].weapon_rotation),180.0):
		_fail("spear jab must return the shaft upright")
		return

	var avatar := Avatar.new()
	root.add_child(avatar)
	await process_frame
	for continuity_attack in [&"forehand",&"backhand"]:
		var continuity := _measure_contact_continuity(avatar,continuity_attack)
		if float(continuity.ratio) > 2.15:
			_fail("%s weapon-tip speed snapped %.2fx across contact" % [continuity_attack,continuity.ratio])
			return
		if float(continuity.direction_dot) < .90:
			_fail("%s weapon tip changed direction abruptly at contact (dot %.3f)" % [continuity_attack,continuity.direction_dot])
			return
	var jab_continuity := _measure_contact_continuity(avatar,&"jab")
	if float(jab_continuity.ratio) > 2.15 or float(jab_continuity.direction_dot) < .90:
		_fail("sword jab must carry smoothly through contact (ratio %.2f, dot %.3f)" % [jab_continuity.ratio,jab_continuity.direction_dot])
		return
	var spear_continuity := _measure_contact_continuity(avatar,&"jab","duneborn","spear","spear")
	if float(spear_continuity.ratio) > 2.15 or float(spear_continuity.direction_dot) < .90:
		_fail("spear jab must carry smoothly through contact (ratio %.2f, dot %.3f)" % [spear_continuity.ratio,spear_continuity.direction_dot])
		return
	for continuity_attack in [&"forehand",&"backhand"]:
		var continuity := _measure_contact_continuity(avatar,continuity_attack,"frost_troll","axe","two_handed_axe")
		if float(continuity.ratio) > 2.15:
			_fail("great-axe %s tip speed snapped %.2fx across contact" % [continuity_attack,continuity.ratio])
			return
		if float(continuity.direction_dot) < .90:
			_fail("great-axe %s tip changed direction abruptly at contact (dot %.3f)" % [continuity_attack,continuity.direction_dot])
			return
	if not avatar.has_node("Rig/SlashTrail"):
		_fail("weapon rig must include a procedural slash trail")
		return
	avatar.configure("human",{"weapon":"sword","offhand":"none","back":"long_cape","accessory":"scarf"})
	for attack_profile in [
		{"id":&"jab","time":.30},
		{"id":&"forehand","time":.38},
		{"id":&"backhand","time":.33},
	]:
		avatar.play_weapon_attack(attack_profile.id)
		avatar._active_tween.custom_step(attack_profile.time)
		var biped_stance_delta := absf(avatar._bones.left_leg.rotation_degrees-rad_to_deg(avatar._rest.left_leg.rotation))+absf(avatar._bones.left_shin.rotation_degrees-rad_to_deg(avatar._rest.left_shin.rotation))+absf(avatar._bones.right_leg.rotation_degrees-rad_to_deg(avatar._rest.right_leg.rotation))+absf(avatar._bones.right_shin.rotation_degrees-rad_to_deg(avatar._rest.right_shin.rotation))
		if biped_stance_delta < 45.0 or is_equal_approx(avatar._bones.rig.position.y,avatar._rest.rig.position.y):
			_fail("%s must transfer weight through a planted four-bone biped stance (%.1f degrees, y %.2f)" % [attack_profile.id,biped_stance_delta,avatar._bones.rig.position.y])
			return
		if attack_profile.id == &"forehand":
			avatar._active_tween.custom_step(.06)
			if avatar._gear.back.rotation_degrees < 10.0 or avatar._gear.accessory.rotation_degrees < 5.0:
				_fail("weapon contact must pull cape and scarf through the strike")
				return
	avatar.configure("centaur",{"weapon":"sword","offhand":"none"})
	avatar.play_weapon_attack(&"forehand")
	avatar._active_tween.custom_step(.38)
	var centaur_stance_delta := 0.0
	for leg_index in 4:
		centaur_stance_delta += absf(avatar._bones["horse_leg_%d" % leg_index].rotation_degrees-rad_to_deg(avatar._rest["horse_leg_%d" % leg_index].rotation))
		centaur_stance_delta += absf(avatar._bones["horse_shin_%d" % leg_index].rotation_degrees-rad_to_deg(avatar._rest["horse_shin_%d" % leg_index].rotation))
	if centaur_stance_delta < 90.0 or is_equal_approx(avatar._bones.horse_tail.rotation,avatar._rest.horse_tail.rotation):
		_fail("centaur attacks must brace all four legs and counterbalance with the tail")
		return
	avatar.configure("human",{"weapon":"sword","offhand":"none"})
	var slash_trail: Node = avatar.get_node("Rig/SlashTrail")
	avatar.play_weapon_attack(&"forehand")
	avatar._active_tween.custom_step(.34)
	if not slash_trail.get("active"):
		_fail("forehand must start its trail at the cutting phase")
		return
	avatar._active_tween.custom_step(.23)
	if slash_trail.get("active"):
		_fail("forehand trail must stop before the recovery pose")
		return
	avatar.play_weapon_attack(&"backhand")
	avatar._active_tween.custom_step(.21)
	if slash_trail.get("active"):
		_fail("backhand anticipation must not trail before its loaded guard settles")
		return
	avatar._active_tween.custom_step(.08)
	if not slash_trail.get("active"):
		_fail("backhand must start its trail at the rising contact phase")
		return
	avatar._active_tween.custom_step(.23)
	if slash_trail.get("active"):
		_fail("backhand trail must stop before weapon recovery")
		return
	avatar.play_weapon_attack(&"jab")
	avatar._active_tween.custom_step(.23)
	if not slash_trail.get("active"):
		_fail("jab must start a straight trail during its forward extension")
		return
	avatar._active_tween.custom_step(.21)
	if slash_trail.get("active"):
		_fail("jab trail must stop before weapon recovery")
		return
	avatar.equip(&"weapon","spear")
	avatar.play_weapon_attack(&"jab")
	avatar._active_tween.custom_step(.23)
	if not slash_trail.get("active"):
		_fail("spear jab must trail its horizontal thrust")
		return
	avatar._active_tween.custom_step(.23)
	if slash_trail.get("active"):
		_fail("spear jab trail must stop before the spear rotates upright")
		return
	avatar.equip(&"weapon","bow")
	if avatar.available_weapon_attacks() != [&"fire_bow"]:
		_fail("bow must expose its dedicated Fire Bow attack")
		return
	avatar.play_weapon_attack(&"fire_bow")
	avatar._active_tween.custom_step(.30)
	if avatar._gear.weapon.bow_draw <= 1.0:
		_fail("Fire Bow must visibly pull the bowstring")
		return
	if GearVisual.STORYBOOK_ARROW != Avatar.STORYBOOK_ARROW_PROJECTILE or GearVisual.STORYBOOK_ARROW.get_size() != Vector2(80,18):
		_fail("drawn and released bows must share the authored arrow sprite")
		return
	if _lower_body_delta(avatar) < 45.0 or is_equal_approx(avatar._bones.torso.rotation,avatar._rest.torso.rotation) or is_equal_approx(avatar._bones.rig.position.y,avatar._rest.rig.position.y):
		_fail("Fire Bow must settle into a planted archer stance while drawing")
		return
	avatar._active_tween.custom_step(.10)
	var bow: GearVisual = avatar._gear.weapon
	var drawn_nock: Vector2 = bow.to_global(Vector2(-40.0-bow.bow_draw,0))
	var drawing_hand: Vector2 = avatar._bones.right_forearm.to_global(Vector2(0,float(avatar._profile.arm)*.48))
	if drawn_nock.distance_to(drawing_hand) > 10.0:
		_fail("Fire Bow offhand must meet the drawn nock beside the face")
		return
	avatar._active_tween.custom_step(.10)
	if not avatar.has_node("FiredArrow"):
		_fail("Fire Bow must release a visible arrow")
		return
	var fired_arrow: Sprite2D = avatar.get_node("FiredArrow")
	if fired_arrow.texture != Avatar.STORYBOOK_ARROW_PROJECTILE or fired_arrow.texture.get_size() != Vector2(80,18):
		_fail("Fire Bow must release the authored true-alpha arrow sprite")
		return
	if not fired_arrow.get_children().is_empty():
		_fail("authored fired arrow must not retain procedural line or polygon children")
		return
	var fired_tip := fired_arrow.to_global(Vector2(fired_arrow.texture.get_width()*.5,0))
	var release_bow_tip: Vector2 = fired_arrow.get_meta("release_bow_tip")
	if fired_tip.distance_to(release_bow_tip) > 1.0:
		_fail("released arrow tip must continue from the fully drawn authored arrow without a visible jump (%.2f px)" % fired_tip.distance_to(release_bow_tip))
		return
	if Avatar.BALLISTIC_PROJECTILE_TRANSITION != Tween.TRANS_LINEAR:
		_fail("detached arrows and bolts must leave at constant ballistic speed")
		return
	avatar._active_tween.custom_step(.07)
	if avatar._right_hand_base.part_id != "hand_open" or avatar._right_hand_base.z_index != 7:
		_fail("bow drawing hand must relax immediately after recoil rather than grip empty string through recovery")
		return
	var detached_arrow_position := fired_arrow.global_position
	avatar._bones.rig.position += Vector2(20,10)
	avatar._bones.rig.force_update_transform()
	if fired_arrow.global_position.distance_to(detached_arrow_position) > .01:
		_fail("released arrow must not inherit archer recoil or footwork after detaching")
		return
	avatar.equip(&"weapon","staff")
	if avatar.available_weapon_attacks() != [&"cast_spell"]:
		_fail("staff must expose its dedicated Cast Spell attack")
		return
	avatar.play_weapon_attack(&"cast_spell")
	avatar._active_tween.custom_step(.31)
	if _lower_body_delta(avatar) < 45.0 or is_equal_approx(avatar._bones.rig.position.y,avatar._rest.rig.position.y):
		_fail("Cast Spell must gather and release from a grounded casting stance")
		return
	if not avatar.has_node("StaffSpell"):
		_fail("Cast Spell must release a visible projectile from the staff")
		return
	var staff_spell: Sprite2D = avatar.get_node("StaffSpell")
	if staff_spell.texture != Avatar.STORYBOOK_SPELL_PROJECTILE or staff_spell.texture.get_size() != Vector2(44,44):
		_fail("Cast Spell must release the authored true-alpha crystal-energy sprite")
		return
	var staff_tip: Vector2 = avatar._gear.weapon.to_global(avatar._gear.weapon.reach_endpoint())
	var spell_origin: Vector2 = avatar.get_node("StaffSpell").global_position
	if staff_tip.distance_to(spell_origin) > 1.0:
		_fail("Cast Spell projectile must originate at the authored staff crystal")
		return
	avatar._active_tween.custom_step(.12)
	if avatar._bones.rig.position.x < 9.0 or avatar._bones.torso.rotation_degrees < 1.0 or avatar._bones.left_arm.rotation_degrees < -90.0:
		_fail("Cast Spell must carry both arms and the torso through a readable post-release follow-through")
		return
	avatar._active_tween.custom_step(.23)
	if absf(avatar._bones.rig.position.x-avatar._rest.rig.position.x) > 2.0 or absf(avatar._bones.right_arm.rotation-avatar._rest.right_arm.rotation) > .12:
		_fail("Cast Spell follow-through must recover continuously into the captured rest pose")
		return
	avatar.configure("fae",{"weapon":"branch_staff","offhand":"none"})
	if avatar.available_weapon_attacks() != [&"cast_spell"]:
		_fail("branch staff must share the dedicated Cast Spell attack family")
		return
	avatar.play_weapon_attack(&"cast_spell")
	avatar._active_tween.custom_step(.31)
	if not avatar.has_node("StaffSpell"):
		_fail("branch staff must release a visible spell projectile")
		return
	var branch_tip: Vector2 = avatar._gear.weapon.to_global(avatar._gear.weapon.reach_endpoint())
	var branch_spell_origin: Vector2 = avatar.get_node("StaffSpell").global_position
	if branch_tip.distance_to(branch_spell_origin) > 1.0:
		_fail("branch staff spell must originate at its forked crown")
		return
	avatar.configure("goblin",{"weapon":"crossbow","offhand":"none"})
	if avatar.available_weapon_attacks() != [&"fire_crossbow"]:
		_fail("crossbow must expose its dedicated Fire Crossbow attack")
		return
	if not avatar._gear.weapon.crossbow_loaded or GearVisual.STORYBOOK_CROSSBOW_BOLT != Avatar.STORYBOOK_CROSSBOW_BOLT:
		_fail("crossbow must begin with the authored bolt visibly loaded on its rail")
		return
	avatar.play_weapon_attack(&"fire_crossbow")
	avatar._active_tween.custom_step(.31)
	if not avatar._gear.weapon.crossbow_loaded:
		_fail("crossbow rail bolt must remain visible throughout the sighting beat")
		return
	avatar._active_tween.custom_step(.08)
	avatar.call("_update_crossbow_support_grip")
	if _lower_body_delta(avatar) < 45.0 or is_equal_approx(avatar._bones.rig.position.y,avatar._rest.rig.position.y):
		_fail("Fire Crossbow must sight and recoil from a grounded firing stance")
		return
	if not avatar.has_node("FiredBolt"):
		_fail("Fire Crossbow must release a visible bolt")
		return
	if avatar._gear.weapon.crossbow_loaded:
		_fail("crossbow rail bolt must disappear exactly when its flying bolt spawns")
		return
	var fired_bolt: Sprite2D = avatar.get_node("FiredBolt")
	if fired_bolt.texture != Avatar.STORYBOOK_CROSSBOW_BOLT or fired_bolt.texture.get_size() != Vector2(64,20) or fired_bolt.scale != Vector2.ONE*float(avatar._profile.scale):
		_fail("Fire Crossbow must release a compact authored bolt sprite")
		return
	var support_hand: Vector2 = avatar._bones.left_forearm.to_global(Vector2(0,float(avatar._profile.arm)*.48))
	var support_grip: Vector2 = avatar._gear.weapon.to_global(GearVisual.CROSSBOW_SECOND_GRIP)
	var support_distance := support_hand.distance_to(support_grip)
	if support_distance > 1.0:
		_fail("crossbow support hand detached from the forward stock while firing (%.2f px)" % support_distance)
		return
	avatar.stop_motion()
	if not avatar._gear.weapon.crossbow_loaded:
		_fail("crossbow must restore its loaded rail after recovery or interruption")
		return
	avatar.configure("centaur",{"weapon":"bow","offhand":"none"})
	avatar.play_weapon_attack(&"fire_bow")
	avatar._active_tween.custom_step(.40)
	if _lower_body_delta(avatar) < 120.0 or is_equal_approx(avatar._bones.horse_tail.rotation,avatar._rest.horse_tail.rotation):
		_fail("centaur bow draw must brace all four legs and counterbalance with its tail")
		return
	avatar.configure("centaur",{"weapon":"staff","offhand":"none"})
	avatar.play_weapon_attack(&"cast_spell")
	avatar._active_tween.custom_step(.31)
	if _lower_body_delta(avatar) < 120.0 or is_equal_approx(avatar._bones.horse_tail.rotation,avatar._rest.horse_tail.rotation):
		_fail("centaur staff casting must brace all four legs and counterbalance with its tail")
		return
	avatar.configure("human",{"weapon":"spear","offhand":"none"})
	for attack in attacks:
		avatar.play_weapon_attack(attack)
		if avatar._active_tween == null or not avatar._active_tween.is_valid():
			_fail("%s did not create an animation" % attack)
			return

	print("PASS: melee curves, grounded bow release, and staff casting work across both topologies")
	quit()


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)


func _lower_body_delta(avatar: ModularCharacter) -> float:
	var bone_names: Array = ["horse_tail","horse_leg_0","horse_shin_0","horse_leg_1","horse_shin_1","horse_leg_2","horse_shin_2","horse_leg_3","horse_shin_3"] if avatar._profile.topology == "centaur" else ["left_leg","left_shin","right_leg","right_shin"]
	var delta := 0.0
	for bone_name in bone_names:
		delta += absf(avatar._bones[bone_name].rotation_degrees-rad_to_deg(avatar._rest[bone_name].rotation))
	return delta


func _measure_contact_continuity(avatar: ModularCharacter,attack_id: StringName,race := "human",weapon_id := "sword",curve_id := "sword") -> Dictionary:
	const sample_step := 1.0/240.0
	avatar.configure(race,{"weapon":weapon_id,"offhand":"none"})
	var curve: Array = Avatar.ATTACK_CURVES[attack_id] if curve_id == "sword" else Avatar.WEAPON_ATTACK_CURVES[curve_id][attack_id]
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
	while elapsed < contact_time+sample_step*1.5:
		avatar._active_tween.custom_step(sample_step)
		weapon.force_update_transform()
		var tip := weapon.to_global(weapon.reach_endpoint())
		velocities.append((tip-previous_tip)/sample_step)
		elapsed += sample_step
		sample_times.append(elapsed)
		previous_tip = tip
	var before: Vector2 = velocities[_nearest_attack_sample(sample_times,contact_time-sample_step*.5)]
	var after: Vector2 = velocities[_nearest_attack_sample(sample_times,contact_time+sample_step*.5)]
	var ratio := maxf(before.length(),after.length())/maxf(minf(before.length(),after.length()),.001)
	return {"ratio":ratio,"direction_dot":before.normalized().dot(after.normalized())}


func _nearest_attack_sample(times: Array[float],target: float) -> int:
	var nearest := 0
	var distance := INF
	for index in times.size():
		var candidate := absf(times[index]-target)
		if candidate < distance:
			distance = candidate
			nearest = index
	return nearest
