extends SceneTree
const Avatar = preload("res://src/modular_character.gd")
const Catalog = preload("res://src/builder_skill_catalog.gd")

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var avatar := Avatar.new()
	root.add_child(avatar)
	avatar.configure("human",CharacterCatalog.reference_loadout("human"))
	assert(Catalog.all().size() == 11)
	for facing in [&"left",&"right"]:
		avatar.set_facing(facing)
		for skill in Catalog.all():
			assert(avatar.play_skill_preview(skill.id),skill.id)
			var tween: Tween = avatar._active_tween
			for i in 960: tween.custom_step(1.0/120.0)
			assert(not avatar._gesturing,"Failed to finish "+skill.id)
			for bone in avatar._rest:
				assert(avatar._bones[bone].position.is_equal_approx(avatar._rest[bone].position),skill.id+" position "+bone)
				assert(is_equal_approx(avatar._bones[bone].rotation,avatar._rest[bone].rotation),skill.id+" rotation "+bone)
			assert(avatar.facing == facing)
			avatar.play_skill_preview(skill.id)
			avatar._active_tween.custom_step(.2)
			avatar.play_motion(&"run")
			assert(avatar._gesture_effects.is_empty(),"Effects must cancel with motion")
			avatar.stop_motion()
	avatar.equip(&"weapon","none")
	avatar.equip(&"offhand","none")
	for skill in Catalog.HUMAN:
		assert(avatar.play_skill_preview(skill.id),"Innate skills must work unarmed")
		avatar.stop_motion()
	for skill in Catalog.SWORD:
		assert(not avatar.play_skill_preview(skill.id),"Sword required")
	avatar.equip(&"weapon","sword")
	assert(not avatar.play_skill_preview("sword_guarded_riposte"),"Shield required")
	avatar.play_skill_preview("sword_heavy_cut")
	avatar._active_tween.custom_step(.2)
	avatar.equip(&"weapon","bow")
	assert(not avatar._gesturing and avatar._gesture_effects.is_empty(),"Equipment cancels preview")
	avatar.play_skill_preview("human_rally")
	avatar._active_tween.custom_step(.5)
	avatar.set_facing(&"right")
	assert(not avatar._gesturing and avatar._gesture_effects.is_empty(),"Facing cancels preview")
	avatar.configure("goblin",CharacterCatalog.reference_loadout("goblin"))
	assert(not avatar.play_skill_preview("human_rally"),"Lineage required")
	assert(not avatar.play_skill_preview("unknown"))
	avatar.free()
	var builder: Node = load("res://main.tscn").instantiate()
	root.add_child(builder)
	await process_frame
	var panel = builder.skills_panel
	panel.show()
	for category in 2:
		panel._select_category(category)
		for index in panel.skills.size():
			panel._select_skill(index)
			await process_frame
			assert(panel.size.y <= 624,"Skill panel overflows: "+panel.selected_id)
			assert(panel.preview.get_global_rect().end.y <= 626,"Preview button clipped")
	builder.free()
	print("PASS: 11 skills, both facings, recovery, interruption, equipment and lineage requirements, builder layout")
	quit()
