extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	for race in CharacterCatalog.RACES:
		for weapon in ["staff", "branch_staff"]:
			for facing in [&"right", &"left"]:
				if "--minimal" in OS.get_cmdline_user_args() and (race != "human" or weapon != "staff" or facing != &"right"):
					continue
				avatar.configure(race, {"weapon": weapon, "offhand": "none"})
				avatar.set_facing(facing)
				var gear: GearVisual = avatar._gear.weapon
				var rest_tip := gear.to_global(gear.reach_endpoint())
				avatar.play_weapon_attack(&"cast_spell")
				for sample in 36:
					avatar._active_tween.custom_step(1.0 / 120.0)
				var release_tip := gear.to_global(gear.reach_endpoint())
				for sample in 17:
					avatar._active_tween.custom_step(1.0 / 120.0)
				var tip := gear.to_global(gear.reach_endpoint())
				var direction := 1.0 if facing == &"right" else -1.0
				if (release_tip.x - rest_tip.x) * direction <= 0:
					printerr("FAIL: %s %s %s gathers behind the caster" % [race, weapon, facing])
					failures += 1
				if (tip.x - rest_tip.x) * direction <= 0 or (tip.x - gear.global_position.x) * direction <= 0:
					printerr("FAIL: %s %s %s casts backward (tip advance %.1f, aim %.1f)" % [race, weapon, facing, (tip.x - rest_tip.x) * direction, (tip.x - gear.global_position.x) * direction])
					failures += 1
				if (tip.x - release_tip.x) * direction < 0:
					printerr("FAIL: %s %s %s pulls the staff backward during follow-through" % [race, weapon, facing])
					failures += 1
				for sample in 36:
					avatar._active_tween.custom_step(1.0 / 120.0)
				if absf(gear.rotation_degrees - 180.0) > .01:
					printerr("FAIL: staff did not return to its upright rest angle")
					failures += 1
	avatar.free()
	if failures == 0:
		print("PASS: staff casts forward through gather and follow-through, then recovers upright")
	quit(1 if failures else 0)
