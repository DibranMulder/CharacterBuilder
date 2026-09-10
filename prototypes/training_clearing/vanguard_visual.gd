extends "res://src/modular_character.gd"
## Temporary pose adapter; gameplay never reads the rig to decide damage.
var _combat_gesture: Dictionary = {}

func present_static_pose(pose: String) -> void:
	stop_motion()
	if pose in ["guard", "air"]:
		play_motion(&"stand")
	if pose == "guard":
		_bones.left_arm.rotation_degrees = -45
		_bones.left_forearm.rotation_degrees = -60
		_bones.torso.rotation_degrees = -5
	elif pose == "air" and _profile.topology != "centaur":
		# The encounter moves the character through the air; only bend the limbs.
		_bones.left_leg.rotation_degrees = -28
		_bones.left_shin.rotation_degrees = 65
		_bones.right_leg.rotation_degrees = 22
		_bones.right_shin.rotation_degrees = 30

# The encounter owns moving, colliding projectiles. Do not spawn the builder's
# cosmetic projectiles as well; they would continue through targets after impact.
func _fire_arrow() -> void:
	_set_bow_drawing_hand(false)
	(_gear.weapon as GearVisual).set_bow_draw(0)

func _fire_crossbow_bolt() -> void:
	(_gear.weapon as GearVisual).set_crossbow_loaded(false)

func _release_staff_spell() -> void:
	pass

func projectile_socket() -> Vector2:
	var weapon := _gear.weapon as GearVisual
	return weapon.to_global(weapon.reach_endpoint())

func skill_projectile_socket(action: Dictionary) -> Vector2:
	if action.get("presentation","") == "cast": return _bones.rig.to_global(_gesture_effect_anchor("hand"))
	if not action.has("gesture"): return projectile_socket()
	var motion_id := "%s_%d"%[race_id,action.gesture]
	var effect: Dictionary = RACE_GESTURE_EFFECTS[motion_id]
	return _bones.rig.to_global(_gesture_effect_anchor(effect.anchor)+effect.get("offset",Vector2.ZERO))

# The arena owns timings and effects; this adapter only poses the equipped rig.
func present_arena_action(action: Dictionary, animation: StringName) -> void:
	_combat_gesture = action.duplicate() if action.has("gesture") else {}
	if not _combat_gesture.is_empty():
		play_gesture(int(action.gesture))
		return
	if action.get("presentation","") == "cast":
		_play_action(action.name,"cast")
		_active_tween.set_speed_scale(.38/action.windup)
		return
	if action.has("presentation"): animation = StringName(action.presentation)
	play_weapon_attack(animation)
	if _active_tween:
		var feels: Dictionary = preload("res://prototypes/training_clearing/encounter.gd").WEAPON_FEEL
		var feel: Dictionary = feels.get(loadout.weapon,feels.sword)
		var native_windup: float = maxf(.32,feel.duration-feel.release)
		_active_tween.set_speed_scale(native_windup/action.windup)

func _animate_race_gesture(profile: Dictionary, motion_id: String) -> void:
	if _combat_gesture.is_empty():
		super._animate_race_gesture(profile,motion_id)
		return
	# Retain the builder's anticipation/contact proportions, but reach contact
	# at the model's release time and complete recovery before the next action.
	var timed := profile.duplicate(true)
	var anticipation: float = profile.times[0]+profile.times[1]
	var factor: float = _combat_gesture.windup/anticipation
	timed.times[0] *= factor
	timed.times[1] *= factor
	timed.times[2] = _combat_gesture.recovery*.35
	timed["recovery_duration"] = _combat_gesture.recovery*.65
	super._animate_race_gesture(timed,motion_id)

func _spawn_race_gesture_effect(motion_id: String) -> void:
	if not _combat_gesture.is_empty() and motion_id in ["centaur_0","goblin_0"]:
		# Keep the release pose, but never let a cosmetic projectile fly through
		# a target after the authoritative projectile has already hit it.
		if motion_id == "goblin_0" and _uses_crossbow():
			(_gear.weapon as GearVisual).set_crossbow_loaded(false)
		if motion_id == "centaur_0" and loadout.weapon == "bow":
			(_gear.weapon as GearVisual).set_bow_draw(0)
		return
	super._spawn_race_gesture_effect(motion_id)
