extends SceneTree
const Avatar = preload("res://prototypes/training_clearing/vanguard_visual.gd")
const Skills = preload("res://prototypes/sparring_arena/lineage_skills.gd")

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	for lineage in CharacterCatalog.race_ids():
		for facing in [&"left",&"right"]:
			var avatar := Avatar.new()
			root.add_child(avatar)
			var outfit := CharacterCatalog.reference_loadout(lineage)
			avatar.configure(lineage,outfit)
			avatar.set_facing(facing)
			var started: Array[String] = []
			avatar.gesture_started.connect(func(value): started.append(value))
			for skill in Skills.kit(lineage):
				avatar.present_arena_action(skill,&"forehand")
				assert(started[-1] == CharacterCatalog.race(lineage).gestures[skill.gesture].name)
				assert(avatar.loadout == outfit and avatar.facing == facing)
				var tween: Tween = avatar._active_tween
				tween.custom_step(skill.windup-.005)
				assert(avatar._gesture_effects.is_empty(),"No effect before gameplay release")
				tween.custom_step(.006)
				var motion_id := "%s_%d"%[lineage,skill.gesture]
				if motion_id in ["centaur_0","goblin_0"]:
					assert(avatar._gesture_effects.is_empty(),"No duplicate cosmetic projectiles")
				else:
					assert(not avatar._gesture_effects.is_empty(),"Builder effect at gameplay release")
					assert(avatar._gesture_effects[-1].effect_id == Avatar.RACE_GESTURE_EFFECTS[motion_id].effect)
				tween.custom_step(skill.recovery+.01)
				assert(not avatar._gesturing,"Recovery must fit the combat action")
				avatar.present_static_pose("idle")
				assert(avatar._gesture_effects.is_empty())
			avatar.present_arena_action(Skills.kit(lineage)[0],&"forehand")
			avatar.play_motion(&"run")
			assert(avatar.current_motion == &"run" and avatar._gesture_effects.is_empty())
			avatar.free()
	print("PASS: all 32 skills use builder gestures in both facings, timed release/recovery, effects and interruption")
	quit()
