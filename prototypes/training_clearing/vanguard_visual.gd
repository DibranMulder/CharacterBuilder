extends "res://src/modular_character.gd"
## Temporary pose adapter; gameplay never reads the rig to decide damage.

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
