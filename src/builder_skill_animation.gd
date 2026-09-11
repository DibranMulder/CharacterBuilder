extends RefCounted
const Effect = preload("res://src/builder_skill_effect.gd")
const GOLD := Color("efbd62")
const IVORY := Color("fff0c2")

static func queue(avatar: Node, id: String) -> void:
	match id:
		"human_crosscut":
			avatar._animate_weapon_curve("forehand",1.1,IVORY,14,_contact.bind(avatar,"cross_first","hand"))
			avatar._animate_weapon_curve("backhand",1.35,GOLD,17,_contact.bind(avatar,"cross_second","hand"))
		"human_resolute_rush":
			avatar._tween_race_pose([12,-15,-75,75,-110,-22,3],.35)
			avatar._queue_attack_footwork("jab","chamber",.35)
			avatar._tween_race_pose([-14,-90,-10,-55,50,55,1],.22)
			avatar._queue_attack_footwork("jab","strike",.22)
			_effect(avatar,"rush","front",.55)
		"human_rally":
			avatar._tween_race_pose([-5,-125,15,100,-60,0,2],.4)
			_effect(avatar,"rally","body",1.8)
		"human_second_wind":
			avatar._tween_race_pose([12,-40,-90,35,-100,0,5],.8)
			_effect(avatar,"heal","body",3.0)
		"sword_basic_slash": avatar._animate_weapon_curve("forehand",1.0,IVORY,12,_contact.bind(avatar,"slash","tip"))
		"sword_quick_cut": avatar._animate_weapon_curve("backhand",1.8,IVORY,15,_contact.bind(avatar,"quick","tip"))
		"sword_heavy_cut": avatar._animate_weapon_curve("forehand",.7,GOLD,30,_contact.bind(avatar,"heavy","tip"))
		"sword_sweeping_edge": avatar._animate_weapon_curve("backhand",.85,GOLD,32,_contact.bind(avatar,"sweep","tip"))
		"sword_pommel_strike":
			avatar._tween_race_pose([-8,20,-80,-55,-75,-10,3],.28)
			avatar._active_tween.parallel().tween_property(avatar._gear.weapon,"rotation_degrees",90.0,.28)
			avatar._queue_attack_footwork("jab","chamber",.28)
			avatar._tween_race_pose([8,0,-70,-88,-4,16,1],.13)
			avatar._queue_attack_footwork("jab","strike",.13)
			_effect(avatar,"pommel","hand",.28)
		"sword_guarded_riposte":
			avatar._tween_race_pose([-8,-80,-40,35,-95,-8,3],.3)
			_effect(avatar,"guard","shield",.28)
			avatar._animate_weapon_curve("jab",1.35,IVORY,16,_contact.bind(avatar,"quick","tip"))
		"sword_blade_rhythm":
			avatar._animate_weapon_curve("forehand",1.4,GOLD,22,_contact.bind(avatar,"slash","tip"))
			avatar._animate_weapon_curve("backhand",1.5,IVORY,25,_contact.bind(avatar,"quick","tip"))
			avatar._animate_weapon_curve("jab",1.25,GOLD,12,_contact.bind(avatar,"crown","body"))
	# Every preview restores the complete rig smoothly, including a reversed grip.
	var first := true
	for bone_name in avatar._rest:
		for property in ["position","rotation","scale"]:
			if not first: avatar._active_tween.parallel()
			avatar._active_tween.tween_property(avatar._bones[bone_name],property,avatar._rest[bone_name][property],.3)
			first = false
	var weapon: Node2D = avatar._gear.get("weapon")
	if weapon:
		avatar._active_tween.parallel().tween_property(weapon,"rotation_degrees",avatar.WEAPON_GRIP_ROTATIONS.get(avatar.loadout.weapon,0.0),.3)
	avatar._active_tween.tween_callback(avatar._finish_gesture)

static func _effect(avatar: Node, kind: String, anchor: String, duration: float) -> void:
	# A child shares the rig's mirroring and the main animation's cancellation.
	var effect := _new_effect(avatar,kind)
	avatar._active_tween.tween_callback(_place.bind(avatar,effect,anchor))
	avatar._active_tween.tween_method(effect.set_progress,0.0,1.0,duration)
	avatar._active_tween.tween_callback(effect.hide)

static func _new_effect(avatar: Node, kind: String) -> Node2D:
	var effect := Effect.new()
	effect.kind = kind
	effect.z_index = 25
	effect.hide()
	avatar._bones.rig.add_child(effect)
	avatar._gesture_effects.append(effect)
	return effect

static func _place(avatar: Node, effect: Node2D, anchor: String) -> void:
	if anchor == "body":
		effect.position = Vector2(0,-105)
	elif anchor == "shield":
		effect.position = avatar._bones.rig.to_local(avatar._gear.offhand.global_position)
	else:
		effect.position = avatar._gesture_effect_anchor("weapon" if anchor == "tip" else anchor)
	effect.show()

static func _contact(avatar: Node, kind: String, anchor: String) -> void:
	var effect := _new_effect(avatar,kind)
	_place(avatar,effect,anchor)
	var tween := effect.create_tween()
	tween.tween_method(effect.set_progress,0.0,1.0,.6)
	tween.tween_callback(effect.queue_free)
