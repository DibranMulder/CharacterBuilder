extends SceneTree


func _initialize() -> void:
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	avatar.configure("human", CharacterCatalog.reference_loadout("human"))
	for facing in [&"right", &"left"]:
		avatar.set_facing(facing)
		# Rig labels are fixed in local space. The screen-left hip in the
		# right-facing pose is the near leg and must win at crossings.
		if avatar._bones.left_leg.z_index <= avatar._bones.right_leg.z_index:
			push_error("FAIL: near leg is behind the far leg when facing " + facing)
			quit(1)
			return
	avatar.free()
	print("PASS: human near leg stays in front in both mirrored facings")
	quit()
