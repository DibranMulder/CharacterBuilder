extends SceneTree

const Avatar := preload("res://src/modular_character.gd")


func _initialize() -> void:
	var avatar: ModularCharacter = Avatar.new()
	root.add_child(avatar)
	avatar.configure("bogkin",avatar.loadout)
	var head_sprite: Sprite2D = avatar.get_node("Rig/Hip/torso/head/HeadSprite/Sprite")
	assert(head_sprite.flip_h, "Bogkin source head must be corrected from left-facing to anatomical right")

	avatar.set_facing(&"right")
	assert(avatar.get_node("Rig").scale.x > 0.0, "Bogkin right-facing rig was mirrored")
	avatar.set_facing(&"left")
	assert(avatar.get_node("Rig").scale.x < 0.0, "Bogkin left-facing rig was not mirrored")

	print("PASS: Bogkin head follows the shared left/right rig orientation")
	quit()
