extends SceneTree

# Measured centers of the four leg exits in the v3 barrel painting, in atlas
# pixels: far hind, near hind, far fore, near fore. Verify against the rendered
# body transform, not the rig's own attachment constants.
const PAINTED_EXITS := [Vector2(270, 350), Vector2(194, 350), Vector2(477, 365), Vector2(395, 380)]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	avatar.configure("centaur", CharacterCatalog.reference_loadout("centaur"))
	for facing in [&"right", &"left"]:
		avatar.set_facing(facing)
		for action in [&"stand", &"run", &"stairs", &"jump", &"rear"]:
			avatar.play_motion(&"stand")
			if action == &"rear":
				avatar.play_gesture(1)
			else:
				avatar.play_motion(action)
			for sample in 24:
				if not _check_attachments(avatar, "%s/%s/%d" % [facing, action, sample]):
					quit(1)
					return
				if avatar._active_tween:
					avatar._active_tween.custom_step(1.0 / 24.0)
	avatar.free()
	print("PASS: four painted centaur leg attachments through stand, run, stairs, jump and rear in both facings")
	quit()


func _check_attachments(avatar: ModularCharacter, pose: String) -> bool:
	var body: Sprite2D = avatar._bones.horse_body.find_child("AuthoredAnatomy", true, false).get_node("Sprite")
	var atlas: AtlasTexture = body.texture
	for i in 4:
		var leg: Node2D = avatar._bones["horse_leg_%d" % i]
		var root_in_body := body.to_local(leg.global_position)
		var exit_in_body: Vector2 = PAINTED_EXITS[i] - atlas.region.get_center()
		var error_x := absf(root_in_body.x - exit_in_body.x) * absf(body.global_scale.x)
		if error_x > 2.0:
			push_error("Centaur %s leg %d misses its painted body exit by %.2f pixels" % [pose, i, error_x])
			return false
		var overlap := (exit_in_body.y - root_in_body.y) * absf(body.global_scale.y)
		if overlap < 4.0 or overlap > 24.0:
			push_error("Centaur %s leg %d must start inside its body attachment, overlap=%.2f" % [pose, i, overlap])
			return false
	return true
