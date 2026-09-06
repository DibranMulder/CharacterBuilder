extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const GestureEffect := preload("res://src/gesture_effect_visual.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if Avatar.RACE_GESTURE_MOTIONS.size() != CharacterCatalog.RACES.size()*3:
		_fail("every lineage gesture must own an action-specific motion profile")
		return
	if Avatar.RACE_GESTURE_EFFECTS.size() != CharacterCatalog.RACES.size()*3:
		_fail("every lineage gesture must own a semantic impact effect")
		return
	if Avatar.RACE_GESTURE_FOOTWORK.size() != CharacterCatalog.RACES.size()*3:
		_fail("every lineage gesture must own a lower-body action profile")
		return
	if GestureEffect.BOLT != Avatar.STORYBOOK_CROSSBOW_BOLT or GestureEffect.BOLT.get_size() != Vector2(64,20):
		_fail("Goblin Snap Shot must share the authored Fire Crossbow bolt")
		return
	var profile_fingerprints := {}
	var effect_ids := {}
	for race_id in CharacterCatalog.race_ids():
		var avatar := Avatar.new()
		root.add_child(avatar)
		var gesture_loadout := CharacterCatalog.reference_loadout(race_id)
		gesture_loadout.back = "cape"
		gesture_loadout.accessory = "scarf"
		avatar.configure(race_id,gesture_loadout)
		await process_frame
		var sampled_poses := {}
		for gesture_index in 3:
			var motion_id := "%s_%d" % [race_id,gesture_index]
			if not Avatar.RACE_GESTURE_MOTIONS.has(motion_id):
				_fail("missing unique motion profile for %s" % motion_id)
				return
			if not Avatar.RACE_GESTURE_EFFECTS.has(motion_id):
				_fail("missing impact effect profile for %s" % motion_id)
				return
			if not Avatar.RACE_GESTURE_FOOTWORK.has(motion_id):
				_fail("missing lower-body action profile for %s" % motion_id)
				return
			var profile: Dictionary = Avatar.RACE_GESTURE_MOTIONS[motion_id]
			var effect_profile: Dictionary = Avatar.RACE_GESTURE_EFFECTS[motion_id]
			var footwork_profile: Dictionary = Avatar.RACE_GESTURE_FOOTWORK[motion_id]
			if footwork_profile.kind not in ["crouch","leap","cast","slash","lunge","gallop","rear","dash","hover","smash","brace"] or float(footwork_profile.intensity) < .6 or float(footwork_profile.intensity) > 1.0:
				_fail("%s has an invalid gesture footwork archetype or intensity" % motion_id)
				return
			if effect_ids.has(effect_profile.effect):
				_fail("%s duplicates the named effect of %s" % [motion_id,effect_ids[effect_profile.effect]])
				return
			effect_ids[effect_profile.effect] = motion_id
			if effect_profile.anchor not in ["head","torso","weapon","hand","front","ground"]:
				_fail("%s uses an unknown effect anchor" % motion_id)
				return
			var fingerprint := "%s|%s|%s" % [profile.windup,profile.impact,profile.times]
			if profile_fingerprints.has(fingerprint):
				_fail("%s duplicates the motion profile of %s" % [motion_id,profile_fingerprints[fingerprint]])
				return
			profile_fingerprints[fingerprint] = motion_id
			avatar.play_gesture(gesture_index)
			if motion_id == "centaur_0":
				avatar._active_tween.custom_step(float(profile.times[0])*.8)
				if avatar.loadout.weapon != "bow" or avatar._gear.weapon.bow_draw < 12.0:
					_fail("Centaur Gallop Shot must visibly draw its authored nocked arrow during anticipation")
					return
				avatar._active_tween.custom_step(float(profile.times[0])*.2+float(profile.times[1])+.001)
			else:
				avatar._active_tween.custom_step(float(profile.times[0])+float(profile.times[1])+.001)
			avatar._process(0.0)
			if avatar._gesture_effects.is_empty() or not is_instance_valid(avatar._gesture_effects[-1]):
				_fail("%s reaches impact without spawning its named effect" % motion_id)
				return
			var effect: Node2D = avatar._gesture_effects[-1]
			if effect.get("effect_id") != effect_profile.effect:
				_fail("%s spawned the wrong gesture effect" % motion_id)
				return
			var expected_effect_local_position: Vector2 = avatar._gesture_effect_anchor(effect_profile.anchor)+effect_profile.get("offset",Vector2.ZERO)
			var expected_effect_global_position: Vector2 = avatar._bones.rig.to_global(expected_effect_local_position)
			if effect.global_position.distance_to(expected_effect_global_position) > .5:
				_fail("%s effect spawned before its final anchored impact pose" % motion_id)
				return
			var detached_effect: bool = effect_profile.anchor in Avatar.DETACHED_GESTURE_EFFECT_ANCHORS
			if detached_effect != (effect.get_parent() == avatar):
				_fail("%s effect uses the wrong bound/detached motion space" % motion_id)
				return
			if detached_effect:
				var released_global_position := effect.global_position
				var original_rig_position: Vector2 = avatar._bones.rig.position
				avatar._bones.rig.position += Vector2(17,9)
				avatar._bones.rig.force_update_transform()
				if effect.global_position.distance_to(released_global_position) > .01:
					_fail("%s released effect is dragged by post-impact rig recovery" % motion_id)
					return
				avatar._bones.rig.position = original_rig_position
				avatar._bones.rig.force_update_transform()
			if motion_id == "centaur_0" and avatar._gear.weapon.bow_draw > .01:
				_fail("Centaur Gallop Shot must release its nocked arrow when the flying effect spawns")
				return
			if motion_id == "goblin_0" and (avatar.loadout.weapon != "crossbow" or effect_profile.effect != "snap_shot"):
				_fail("Goblin Snap Shot must stage the reference crossbow and bolt effect")
				return
			if motion_id == "goblin_0" and avatar._gear.weapon.crossbow_loaded:
				_fail("Goblin Snap Shot must unload the crossbow rail when its bolt effect spawns")
				return
			var lower_body_delta := _lower_body_delta(avatar)
			var minimum_delta := 75.0 if CharacterCatalog.race(race_id).topology == "centaur" else 25.0
			if lower_body_delta < minimum_delta:
				_fail("%s leaves its lower body inert at impact (%.1f degrees)" % [motion_id,lower_body_delta])
				return
			if avatar._gear.back.rotation_degrees < 7.0 or avatar._gear.accessory.rotation_degrees < 4.0:
				_fail("%s impact leaves its cape or scarf rigid" % motion_id)
				return
			if race_id == "fae":
				var left_wing_delta: float = avatar._bones.left_wing.rotation-avatar._rest.left_wing.rotation
				var right_wing_delta: float = avatar._bones.right_wing.rotation-avatar._rest.right_wing.rotation
				if absf(rad_to_deg(left_wing_delta)) < 12.0 or not is_equal_approx(left_wing_delta,-right_wing_delta):
					_fail("%s must stage its registered wing pair at impact" % motion_id)
					return
			var sampled := Vector4(
				avatar._bones.torso.rotation_degrees,
				avatar._bones.left_arm.rotation_degrees,
				avatar._bones.right_arm.rotation_degrees,
				avatar._bones.rig.position.y)
			var sampled_key := "%0.2f|%0.2f|%0.2f|%0.2f" % [sampled.x,sampled.y,sampled.z,sampled.w]
			if sampled_poses.has(sampled_key):
				_fail("%s gestures %d and %d produce the same sampled silhouette" % [race_id,sampled_poses[sampled_key],gesture_index])
				return
			sampled_poses[sampled_key] = gesture_index
		avatar.play_motion(&"run")
		if avatar.find_child("GestureEffect",true,false) != null or not avatar._gesture_effects.is_empty():
			_fail("%s left a stale lineage effect after locomotion interrupted the gesture" % race_id)
			return
		if race_id == "goblin" and not avatar._gear.weapon.crossbow_loaded:
			_fail("interrupting Goblin Snap Shot must restore its loaded rail")
			return
		if race_id == "centaur" and avatar._gear.weapon.bow_draw > .01:
			_fail("interrupting Centaur Gallop Shot must restore its relaxed bowstring")
			return
		avatar.stop_motion()
		avatar.queue_free()
	print("PASS: all 24 lineage gestures use distinct full-body poses, named effects, and clean interruption")
	quit()


func _fail(message: String) -> void:
	printerr("FAIL: ",message)
	quit(1)


func _lower_body_delta(avatar: ModularCharacter) -> float:
	var bone_names: Array = ["horse_tail","horse_leg_0","horse_shin_0","horse_leg_1","horse_shin_1","horse_leg_2","horse_shin_2","horse_leg_3","horse_shin_3"] if avatar._profile.topology == "centaur" else ["left_leg","left_shin","right_leg","right_shin"]
	var delta := 0.0
	for bone_name in bone_names:
		delta += absf(avatar._bones[bone_name].rotation_degrees-rad_to_deg(avatar._rest[bone_name].rotation))
	return delta
