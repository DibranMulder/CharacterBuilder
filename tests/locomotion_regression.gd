extends SceneTree

const Avatar := preload("res://src/modular_character.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if Avatar.MOTIONS != [&"idle", &"stand", &"run", &"stairs", &"climb"]:
		_fail("expected idle, stand, run, stairs, and ladder-climb motions")
		return
	if Avatar.BIPED_RUN_CYCLE.size() != 8:
		_fail("biped run must use the reference's eight-phase cadence")
		return
	if Avatar.CENTAUR_RUN_CYCLE.size() != 8:
		_fail("centaur run must use a full eight-phase diagonal-pair gallop")
		return
	if Avatar.BIPED_STAIR_CYCLE.size() != 8 or Avatar.CENTAUR_STAIR_CYCLE.size() != 4:
		_fail("stairs need topology-specific full alternating step cycles")
		return
	if Avatar.FAE_RUN_WING_CYCLE.size() != Avatar.BIPED_RUN_CYCLE.size() or Avatar.FAE_STAIR_WING_CYCLE.size() != Avatar.BIPED_STAIR_CYCLE.size():
		_fail("Fae locomotion needs one authored wing pose per biped run and stair frame")
		return
	if Avatar.FAE_RUN_WING_CYCLE.max()-Avatar.FAE_RUN_WING_CYCLE.min() < 45.0 or Avatar.FAE_STAIR_WING_CYCLE.max()-Avatar.FAE_STAIR_WING_CYCLE.min() < 20.0:
		_fail("Fae run and stair wing cycles lack distinct flap ranges")
		return
	if Avatar.IDLE_MOTION_PROFILES.size() != CharacterCatalog.RACES.size():
		_fail("every lineage must define its own idle breathing profile")
		return
	var idle_fingerprints := {}
	for race_id in CharacterCatalog.race_ids():
		var idle_profile: Dictionary = Avatar.IDLE_MOTION_PROFILES.get(race_id,{})
		for required_channel in ["speed","bob","torso","head","arm","forearm","leg","tail","wing"]:
			if not idle_profile.has(required_channel):
				_fail("%s idle profile is missing its %s channel" % [race_id,required_channel])
				return
		var fingerprint := "%s|%s|%s|%s|%s|%s|%s|%s|%s" % [idle_profile.speed,idle_profile.bob,idle_profile.torso,idle_profile.head,idle_profile.arm,idle_profile.forearm,idle_profile.leg,idle_profile.tail,idle_profile.wing]
		if idle_fingerprints.has(fingerprint):
			_fail("%s duplicates the idle cadence of %s" % [race_id,idle_fingerprints[fingerprint]])
			return
		idle_fingerprints[fingerprint] = race_id
	for phase_index in [0,3,4,7]:
		var stride: Dictionary = Avatar.BIPED_RUN_CYCLE[phase_index].rotations
		if absf(stride.left_leg-stride.right_leg) < 80.0:
			_fail("biped run phase %d lacks the reference's extended stride" % phase_index)
			return
	for phase_index in [2,6]:
		var recovery: Dictionary = Avatar.BIPED_RUN_CYCLE[phase_index].rotations
		if maxf(absf(recovery.left_shin),absf(recovery.right_shin)) < 70.0:
			_fail("biped run phase %d lacks a tucked recovery knee" % phase_index)
			return
	for phase_index in Avatar.CENTAUR_RUN_CYCLE.size():
		var gallop: Dictionary = Avatar.CENTAUR_RUN_CYCLE[phase_index].rotations
		if not is_equal_approx(float(gallop.horse_leg_0),float(gallop.horse_leg_3)) or not is_equal_approx(float(gallop.horse_leg_1),float(gallop.horse_leg_2)):
			_fail("centaur run phase %d broke its readable diagonal leg pairs" % phase_index)
			return
	for phase_index in [0,3,4,7]:
		var extended_gallop: Dictionary = Avatar.CENTAUR_RUN_CYCLE[phase_index].rotations
		if absf(float(extended_gallop.horse_leg_0)-float(extended_gallop.horse_leg_1)) < 75.0:
			_fail("centaur run phase %d lacks a fully extended gallop silhouette" % phase_index)
			return
	for phase_index in [2,6]:
		var passing_gallop: Dictionary = Avatar.CENTAUR_RUN_CYCLE[phase_index].rotations
		if maxf(absf(float(passing_gallop.horse_shin_0)),absf(float(passing_gallop.horse_shin_1))) < 70.0:
			_fail("centaur run phase %d lacks a tucked passing knee" % phase_index)
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
	if avatar._gear.weapon.get_parent() != avatar._bones.right_forearm or avatar._gear.offhand.get_parent() != avatar._bones.left_forearm or not avatar._gear.offhand.shield_exterior:
		_fail("right-facing equipment did not restore its original hand presentation")
		return
	avatar.configure("human",{"weapon":"sword","offhand":"none","back":"long_cape","accessory":"scarf"})
	avatar._idle_phase = 0.0
	avatar._process(.2)
	if is_zero_approx(avatar._gear.back.rotation) or is_zero_approx(avatar._gear.accessory.rotation):
		_fail("idle breathing must carry subtle secondary motion into cape and scarf")
		return
	avatar.play_motion(&"stand")
	if not is_zero_approx(avatar._gear.back.rotation) or not is_zero_approx(avatar._gear.accessory.rotation):
		_fail("static Stand must restore cape and scarf to their authored hang")
		return
	avatar.play_motion(&"run")
	avatar._active_tween.custom_step(Avatar.RUN_FRAME_DURATION*3.0)
	if avatar._gear.back.rotation_degrees < 10.0 or avatar._gear.accessory.rotation_degrees < 5.0:
		_fail("running must stream cape and scarf behind the wearer")
		return
	avatar.stop_motion()
	avatar.play_motion(&"stairs")
	avatar._active_tween.custom_step(Avatar.STAIR_FRAME_DURATION*3.0)
	if avatar._gear.back.rotation_degrees < 4.0 or avatar._gear.accessory.rotation_degrees < 2.0:
		_fail("stairs must carry restrained cape and scarf follow-through")
		return
	avatar.stop_motion()
	avatar.play_motion(&"climb")
	avatar._active_tween.custom_step(.56)
	if avatar._gear.back.rotation_degrees < 5.0 or avatar._gear.accessory.rotation_degrees < 3.0:
		_fail("ladder climbing must alternate cape and scarf sway")
		return
	avatar.stop_motion()
	if not is_zero_approx(avatar._gear.back.rotation) or not is_zero_approx(avatar._gear.accessory.rotation):
		_fail("stopping locomotion must restore cape and scarf without drift")
		return
	for pole_weapon in ["spear","staff","branch_staff"]:
		avatar.configure("human",{"weapon":pole_weapon})
		avatar.play_motion(&"run")
		for phase_index in Avatar.BIPED_RUN_CYCLE.size():
			avatar._active_tween.custom_step(Avatar.RUN_FRAME_DURATION)
			var pole: GearVisual = avatar._gear.weapon
			pole.force_update_transform()
			var pole_axis := pole.to_global(pole.reach_endpoint())-pole.global_position
			if absf(pole_axis.x) > 1.0 or pole_axis.y >= 0.0:
				_fail("running %s must remain vertically upright in every run phase" % pole_weapon)
				return
			if absf(pole.global_position.x-avatar._bones.head.global_position.x) < float(avatar._profile.head.x)*.45:
				_fail("running %s grip crossed the face in phase %d" % [pole_weapon,phase_index])
				return
		avatar.stop_motion()
		avatar.play_motion(&"stairs")
		for phase_index in Avatar.BIPED_STAIR_CYCLE.size():
			avatar._active_tween.custom_step(Avatar.STAIR_FRAME_DURATION)
			var stair_pole: GearVisual = avatar._gear.weapon
			stair_pole.force_update_transform()
			var stair_axis := stair_pole.to_global(stair_pole.reach_endpoint())-stair_pole.global_position
			if absf(stair_axis.x) > 1.0 or stair_axis.y >= 0.0:
				_fail("stair-climbing %s must remain vertically upright in every step phase" % pole_weapon)
				return
			if absf(stair_pole.global_position.x-avatar._bones.head.global_position.x) < float(avatar._profile.head.x)*.45:
				_fail("stair-climbing %s grip crossed the face in phase %d" % [pole_weapon,phase_index])
				return
		avatar.stop_motion()
	avatar.configure("human",{"weapon":"sword","offhand":"none"})
	for blade_motion in [&"run",&"stairs"]:
		avatar.play_motion(blade_motion)
		var blade_cycle_size: int = Avatar.BIPED_RUN_CYCLE.size() if blade_motion == &"run" else Avatar.BIPED_STAIR_CYCLE.size()
		var blade_frame_duration: float = Avatar.RUN_FRAME_DURATION if blade_motion == &"run" else Avatar.STAIR_FRAME_DURATION
		for phase_index in blade_cycle_size:
			avatar._active_tween.custom_step(blade_frame_duration)
			var carried_sword: GearVisual = avatar._gear.weapon
			carried_sword.force_update_transform()
			var blade_axis: Vector2 = carried_sword.to_global(carried_sword.reach_endpoint())-carried_sword.global_position
			if blade_axis.x <= 0.0 or absf(blade_axis.y) > 18.0:
				_fail("%s sword must stay in a low forward carry instead of crossing the face in phase %d" % [blade_motion,phase_index])
				return
		avatar.stop_motion()
	avatar.configure("frost_troll",CharacterCatalog.reference_loadout("frost_troll"))
	for heavy_motion in [&"run",&"stairs"]:
		avatar.play_motion(heavy_motion)
		var heavy_cycle_size: int = Avatar.BIPED_RUN_CYCLE.size() if heavy_motion == &"run" else Avatar.BIPED_STAIR_CYCLE.size()
		var heavy_frame_duration: float = Avatar.RUN_FRAME_DURATION if heavy_motion == &"run" else Avatar.STAIR_FRAME_DURATION
		for phase_index in heavy_cycle_size:
			avatar._active_tween.custom_step(heavy_frame_duration)
			avatar.call("_update_two_handed_axe_grip")
			var great_axe: GearVisual = avatar._gear.weapon
			great_axe.force_update_transform()
			if absf(great_axe.global_position.x-avatar._bones.head.global_position.x) < float(avatar._profile.head.x)*.55:
				_fail("Frost Troll %s great-axe grip crossed the face in phase %d" % [heavy_motion,phase_index])
				return
			var heavy_support_socket: Vector2 = avatar._bones.left_forearm.to_global(Vector2(0,float(avatar._profile.arm)*.48))
			if heavy_support_socket.distance_to(great_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)) > 1.0:
				_fail("Frost Troll %s support hand detached in phase %d" % [heavy_motion,phase_index])
				return
		avatar.stop_motion()
	avatar.configure("goblin",{"weapon":"crossbow","offhand":"none"})
	for motion_id in [&"run",&"stairs"]:
		avatar.play_motion(motion_id)
		var cycle_size: int = Avatar.BIPED_RUN_CYCLE.size() if motion_id == &"run" else Avatar.BIPED_STAIR_CYCLE.size()
		var frame_duration: float = Avatar.RUN_FRAME_DURATION if motion_id == &"run" else Avatar.STAIR_FRAME_DURATION
		for phase_index in cycle_size:
			avatar._active_tween.custom_step(frame_duration)
			avatar.call("_update_crossbow_support_grip")
			var carried_crossbow: GearVisual = avatar._gear.weapon
			carried_crossbow.force_update_transform()
			var crossbow_axis := carried_crossbow.to_global(carried_crossbow.reach_endpoint())-carried_crossbow.global_position
			if crossbow_axis.x <= 0.0 or absf(crossbow_axis.y) > 1.0:
				_fail("%s crossbow must remain level and forward instead of crossing the face" % motion_id)
				return
			var support_socket: Vector2 = avatar._bones.left_forearm.to_global(Vector2(0,float(avatar._profile.arm)*.48))
			var stock_grip: Vector2 = carried_crossbow.to_global(GearVisual.CROSSBOW_SECOND_GRIP)
			if support_socket.distance_to(stock_grip) > 1.0:
				_fail("%s crossbow support hand detached from the stock" % motion_id)
				return
		avatar.stop_motion()
	avatar.configure("human",{"weapon":"sword","offhand":"shield"})
	avatar.play_motion(&"run")
	avatar._active_tween.custom_step(Avatar.RUN_FRAME_DURATION*2.0-.01)
	var pre_boundary_leg: float = avatar._bones.left_leg.rotation_degrees
	avatar._active_tween.custom_step(.01)
	var boundary_leg: float = avatar._bones.left_leg.rotation_degrees
	avatar._active_tween.custom_step(.01)
	var post_boundary_leg: float = avatar._bones.left_leg.rotation_degrees
	if absf(boundary_leg-pre_boundary_leg) < 1.5 or absf(post_boundary_leg-boundary_leg) < 1.5:
		_fail("dense biped run interpolation must not stall at internal pose joins")
		return
	avatar.stop_motion()

	for race_id in CharacterCatalog.race_ids():
		avatar.configure(race_id, {})
		var idle_profile: Dictionary = Avatar.IDLE_MOTION_PROFILES[race_id]
		avatar.play_motion(&"stand")
		if avatar.current_motion != &"stand" or avatar._active_tween != null or avatar._gesturing:
			_fail("%s stand must be a static, non-looping presentation" % race_id)
			return
		var stand_rig_y: float = avatar._bones.rig.position.y
		var stand_torso: float = avatar._bones.torso.rotation
		var stand_left_arm: float = avatar._bones.left_arm.rotation
		avatar._process(.5)
		if not is_equal_approx(avatar._bones.rig.position.y,stand_rig_y) or not is_equal_approx(avatar._bones.torso.rotation,stand_torso) or not is_equal_approx(avatar._bones.left_arm.rotation,stand_left_arm):
			_fail("%s stand drifted instead of holding the authored rest pose" % race_id)
			return
		avatar.play_motion(&"idle")
		avatar._idle_phase = 0.0
		avatar._process(.1)
		var expected_breath := sin(.1*float(idle_profile.speed))
		if not is_equal_approx(avatar._bones.rig.position.y,avatar._rest.rig.position.y+expected_breath*float(idle_profile.bob)):
			_fail("%s idle cadence did not apply its lineage-specific body rise" % race_id)
			return
		if is_equal_approx(avatar._bones.torso.rotation,avatar._rest.torso.rotation) or is_equal_approx(avatar._bones.head.rotation,avatar._rest.head.rotation):
			_fail("%s idle must breathe through opposing torso and head motion" % race_id)
			return
		if is_equal_approx(avatar._bones.left_arm.rotation,avatar._rest.left_arm.rotation) or is_equal_approx(avatar._bones.left_forearm.rotation,avatar._rest.left_forearm.rotation):
			_fail("%s idle must carry secondary motion through its arm chain" % race_id)
			return
		if race_id == "centaur" and is_equal_approx(avatar._bones.horse_tail.rotation,avatar._rest.horse_tail.rotation):
			_fail("centaur idle must sway its equine tail")
			return
		if race_id == "fae":
			if not avatar._bones.has("left_wing") or not avatar._bones.has("right_wing"):
				_fail("fae idle needs two registered wing bones")
				return
			var left_wing_delta: float = avatar._bones.left_wing.rotation-avatar._rest.left_wing.rotation
			var right_wing_delta: float = avatar._bones.right_wing.rotation-avatar._rest.right_wing.rotation
			if is_zero_approx(left_wing_delta) or not is_equal_approx(left_wing_delta,-right_wing_delta):
				_fail("fae idle wings must flutter in an opposing pair")
				return
		if CharacterCatalog.race(race_id).topology == "centaur":
			if avatar._gear.pants.visible:
				_fail("centaur must not render biped pants")
				return
		elif race_id == "human":
			for side in ["left", "right"]:
				var surface = avatar._bones[side + "_leg"].get_node("HumanLimbSurface")
				if surface.lower != avatar._bones[side + "_shin"] or surface.pants != avatar.loadout.pants:
					_fail("human trousers must share the continuous animated knee surface")
					return
		else:
			if not avatar._bones.left_leg.has_node("LeftPantsThigh") or not avatar._bones.right_leg.has_node("RightPantsThigh"):
				_fail("%s pants must have separate thigh pieces attached to the animated legs" % race_id)
				return
			if not avatar._bones.left_shin.has_node("LeftPantsShin") or not avatar._bones.right_shin.has_node("RightPantsShin"):
				_fail("%s pants must articulate across the knee joints" % race_id)
				return
		if CharacterCatalog.race(race_id).topology == "centaur":
			if avatar._head_base.get_node("Sprite").position.y < -22.5:
				_fail("centaur authored head must overlap the torso socket instead of floating above it")
				return
			if not avatar._bones.has("horse_neck") or not avatar._bones.has("horse_tail"):
				_fail("centaur must have distinct equine neck/withers and tail parts")
				return
			if avatar._bones.torso.position.x <= avatar._bones.horse_body.position.x:
				_fail("centaur humanoid torso must rise from the horse's front rather than its center")
				return
		var knee_bone := "horse_shin_0" if CharacterCatalog.race(race_id).topology == "centaur" else "left_shin"
		if not avatar._bones.has(knee_bone):
			_fail("%s run rig has no knee/shin joint" % race_id)
			return
		avatar.play_motion(&"run")
		avatar._bones.rig.position.y = 13.0
		avatar._process(.1)
		if not is_equal_approx(avatar._bones.rig.position.y,13.0):
			_fail("%s idle breathing overwrote active locomotion" % race_id)
			return
		avatar._bones.rig.position.y = avatar._rest.rig.position.y
		if avatar.current_motion != &"run" or avatar._active_tween == null:
			_fail("%s did not start its run loop" % race_id)
			return
		var run_sample_time := Avatar.RUN_FRAME_DURATION*3.0
		avatar._active_tween.custom_step(run_sample_time)
		if race_id == "fae":
			var run_left_wing_delta: float = avatar._bones.left_wing.rotation-avatar._rest.left_wing.rotation
			var run_right_wing_delta: float = avatar._bones.right_wing.rotation-avatar._rest.right_wing.rotation
			if absf(rad_to_deg(run_left_wing_delta)) < 5.0 or not is_equal_approx(run_left_wing_delta,-run_right_wing_delta):
				_fail("Fae run must flap its registered wing pair symmetrically")
				return
		if avatar._bones.torso.rotation_degrees <= 0.0:
			_fail("%s run pose leans its head and torso backward instead of into the run" % race_id)
			return
		if CharacterCatalog.race(race_id).topology != "centaur":
			var torso_part: PartVisual = avatar._bones.torso.get_child(0)
			var torso_waist: Vector2 = torso_part.to_global(Vector2(0,torso_part.size.y))
			var leg_center: Vector2 = avatar._bones.hip.global_position
			if torso_waist.distance_to(leg_center) > 1.0:
				_fail("%s running torso must remain aligned with the center of its legs" % race_id)
				return
		var run_bone := "horse_leg_0" if CharacterCatalog.race(race_id).topology == "centaur" else "left_leg"
		if is_equal_approx(avatar._bones[run_bone].rotation, avatar._rest[run_bone].rotation):
			_fail("%s run loop did not move its legs" % race_id)
			return
		if is_equal_approx(avatar._bones[knee_bone].rotation, avatar._rest[knee_bone].rotation):
			_fail("%s run loop left its knee rigid" % race_id)
			return
		var minimum_knee_bend := 50.0 if CharacterCatalog.race(race_id).topology == "centaur" else 60.0
		if absf(avatar._bones[knee_bone].rotation_degrees) < minimum_knee_bend:
			_fail("%s run pose knee bend is too shallow" % race_id)
			return

		avatar.play_motion(&"stairs")
		if avatar.current_motion != &"stairs" or avatar._active_tween == null:
			_fail("%s did not start its stair cycle" % race_id)
			return
		var stair_sample_time := Avatar.STAIR_FRAME_DURATION*(2.0 if CharacterCatalog.race(race_id).topology == "centaur" else 4.0)
		avatar._active_tween.custom_step(stair_sample_time)
		if race_id == "fae":
			var stair_left_wing_delta: float = avatar._bones.left_wing.rotation-avatar._rest.left_wing.rotation
			var stair_right_wing_delta: float = avatar._bones.right_wing.rotation-avatar._rest.right_wing.rotation
			if absf(rad_to_deg(stair_left_wing_delta)) < 4.0 or not is_equal_approx(stair_left_wing_delta,-stair_right_wing_delta):
				_fail("Fae stairs must use a restrained symmetric wing balance")
				return
		if avatar._bones.rig.position.y > -7.5:
			_fail("%s stair cycle does not lift body weight onto the next tread" % race_id)
			return
		if avatar._head_visual.back_view or avatar._gear.armor.back_view or avatar._gear.head.back_view or avatar._gear.accessory.back_view:
			_fail("%s stairs must preserve side-facing anatomy and equipment" % race_id)
			return
		if avatar._gear.weapon.get_parent() != avatar._bones.right_forearm or avatar._gear.offhand.get_parent() != avatar._bones.left_forearm:
			_fail("%s stairs must keep wielded equipment in both hands" % race_id)
			return
		if avatar._gear.weapon.carried_on_back or avatar._gear.offhand.carried_on_back:
			_fail("%s stairs incorrectly used the ladder back-mount presentation" % race_id)
			return
		if CharacterCatalog.race(race_id).topology == "centaur":
			for leg_index in 4:
				if not avatar._bones["horse_leg_%d" % leg_index].visible:
					_fail("centaur stairs must retain all four articulated legs")
					return
			if avatar._bones.horse_body.get_child(0).back_view:
				_fail("centaur stairs must retain the authored side-view horse body")
				return
			if is_equal_approx(avatar._bones.horse_shin_2.rotation,avatar._rest.horse_shin_2.rotation):
				_fail("centaur stairs left its forward knee rigid")
				return
		elif maxf(absf(avatar._bones.left_shin.rotation_degrees),absf(avatar._bones.right_shin.rotation_degrees)) < 70.0:
			_fail("%s stairs need a visibly lifted passing knee" % race_id)
			return
		avatar.set_facing(&"left")
		if avatar._bones.rig.scale.x >= 0:
			_fail("%s stair cycle did not preserve left-facing ascent" % race_id)
			return
		avatar.set_facing(&"right")

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
		if race_id == "fae":
			var climb_left_wing_delta: float = avatar._bones.left_wing.rotation-avatar._rest.left_wing.rotation
			var climb_right_wing_delta: float = avatar._bones.right_wing.rotation-avatar._rest.right_wing.rotation
			if absf(rad_to_deg(climb_left_wing_delta)) < 5.0 or not is_equal_approx(climb_left_wing_delta,-climb_right_wing_delta):
				_fail("Fae ladder climb must fold and balance its wings as a pair")
				return
		if not avatar._head_visual.back_view:
			_fail("%s climb loop did not switch to the rear view" % race_id)
			return
		if not avatar._gear.armor.back_view:
			_fail("%s climb loop did not switch modular armor to its rear view" % race_id)
			return
		if not avatar._gear.head.back_view:
			_fail("%s climb loop did not switch modular headgear to its rear view" % race_id)
			return
		if not avatar._gear.accessory.back_view:
			_fail("%s climb loop did not switch modular accessories to their rear view" % race_id)
			return
		if CharacterCatalog.race(race_id).topology == "centaur":
			var torso_center_x := avatar.to_local(avatar._bones.torso.global_position).x
			if not is_zero_approx(torso_center_x):
				_fail("centaur climbing spine must align with the ladder center")
				return
			avatar.set_facing(&"left")
			if not is_zero_approx(avatar.to_local(avatar._bones.torso.global_position).x):
				_fail("centaur climbing spine lost ladder center when facing changed")
				return
			avatar.set_facing(&"right")
			var horse_body_visual: PartVisual = avatar._bones.horse_body.get_child(0)
			if not horse_body_visual.back_view:
				_fail("centaur climb must switch the horse body to a top/rear view")
				return
			var horse_body_sprite: BaseAnatomyVisual = horse_body_visual.get_node("AuthoredAnatomy")
			var horse_neck_sprite: BaseAnatomyVisual = avatar._bones.horse_neck.get_child(0).get_node("AuthoredAnatomy")
			if not horse_body_sprite.back_view or not horse_neck_sprite.back_view:
				_fail("centaur climb did not propagate the rear view into authored equine sprites")
				return
			if not is_equal_approx(avatar._bones.horse_body.position.x,avatar._bones.torso.position.x):
				_fail("centaur climbing body must center beneath its humanoid torso instead of extending left")
				return
			for leg_index in 4:
				if avatar._bones["horse_leg_%d" % leg_index].visible:
					_fail("centaur horse legs must be hidden while climbing")
					return
			if not avatar._horse_tail_base.back_view:
				_fail("centaur climb did not switch to the rear tail sprite")
				return
			if avatar._bones.horse_tail.z_index <= avatar._bones.horse_body.z_index:
				_fail("centaur rear tail must render above the horse body while climbing")
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
		if race_id == "fae" and (not is_equal_approx(avatar._bones.left_wing.rotation,avatar._rest.left_wing.rotation) or not is_equal_approx(avatar._bones.right_wing.rotation,avatar._rest.right_wing.rotation)):
			_fail("Fae wings did not return to their authored rest angles")
			return
		if avatar._head_visual.back_view:
			_fail("%s did not restore its side-facing head after climbing" % race_id)
			return
		if avatar._gear.armor.back_view:
			_fail("%s did not restore modular armor after climbing" % race_id)
			return
		if avatar._gear.head.back_view:
			_fail("%s did not restore modular headgear after climbing" % race_id)
			return
		if avatar._gear.accessory.back_view:
			_fail("%s did not restore modular accessories after climbing" % race_id)
			return
		if CharacterCatalog.race(race_id).topology == "centaur":
			var restored_horse_body_visual: PartVisual = avatar._bones.horse_body.get_child(0)
			if restored_horse_body_visual.back_view:
				_fail("centaur horse body did not restore its side view after climbing")
				return
			if restored_horse_body_visual.get_node("AuthoredAnatomy").back_view:
				_fail("centaur authored horse body did not restore its side texture after climbing")
				return
			for leg_index in 4:
				if not avatar._bones["horse_leg_%d" % leg_index].visible:
					_fail("centaur horse legs did not return after climbing")
					return
			if avatar._bones.horse_tail.z_index != -4:
				_fail("centaur side tail did not return behind the rump")
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

	print("PASS: all 8 races stand, idle with secondary motion, run, climb stairs, and climb ladders rear-facing")
	quit()


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
