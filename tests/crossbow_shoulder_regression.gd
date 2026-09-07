extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	for race in CharacterCatalog.RACES:
		for facing in [&"right", &"left"]:
			if "--minimal" in OS.get_cmdline_user_args() and (race != "human" or facing != &"right"):
				continue
			avatar.configure(race, {"weapon": "crossbow", "offhand": "none"})
			avatar.set_facing(facing)
			avatar.play_weapon_attack(&"fire_crossbow")
			for frame in 90:
				avatar._active_tween.custom_step(1.0 / 120.0)
				avatar._process(0.0)
				if frame < 22 or frame > 54:
					continue
				var weapon: GearVisual = avatar._gear.weapon
				var stock: Vector2 = avatar._bones.torso.to_local(weapon.to_global(GearVisual.CROSSBOW_STOCK_BUTT))
				var shoulder: Vector2 = avatar._bones.right_arm.position + Vector2(0, 3)
				if stock.distance_to(shoulder) > 3.0:
					printerr("FAIL: %s %s crossbow stock is %.1fpx from the shoulder" % [race, facing, stock.distance_to(shoulder)])
					failures += 1
				var support: Vector2 = avatar._bones.left_forearm.to_global(Vector2(0, avatar._profile.arm * .48))
				if support.distance_to(weapon.to_global(GearVisual.CROSSBOW_SECOND_GRIP)) > .1:
					printerr("FAIL: support hand detached from shouldered crossbow")
					failures += 1
				var direction := 1.0 if facing == &"right" else -1.0
				if (weapon.to_global(weapon.reach_endpoint()).x - weapon.global_position.x) * direction <= 0:
					printerr("FAIL: shouldered crossbow must aim forward")
					failures += 1
			if absf(avatar._gear.weapon.rotation_degrees + 90.0) > .01:
				printerr("FAIL: crossbow did not recover its resting grip")
				failures += 1
			avatar.play_weapon_attack(&"fire_crossbow")
			avatar._active_tween.custom_step(.2)
			avatar.play_motion(&"stand")
			if absf(avatar._gear.weapon.rotation_degrees + 90.0) > .01:
				printerr("FAIL: interrupted crossbow did not recover its resting grip")
				failures += 1
	avatar.free()
	if failures == 0:
		print("PASS: all lineages shoulder the crossbow through aim, release and recoil with attached support hand, recovery and interruption")
	quit(1 if failures else 0)
