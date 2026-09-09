extends SceneTree

func _initialize() -> void:
	var visual = preload("res://prototypes/training_clearing/rowan_visual.gd").new()
	var art: Image = visual.ART.get_image()
	var failed := false
	# Read the actual opaque soles, not the rectangular image/crop boundary.
	for bounds in [Vector2i(320,500),Vector2i(595,690)]:
		var sole := Vector2.ZERO
		for y in range(1300,1420):
			for x in range(bounds.x,bounds.y):
				var pixel := art.get_pixel(x,y)
				if pixel.g < 0.6 and pixel.b < 0.5 and pixel.a > 0.9:
					sole = Vector2(x,y)
		var floor_gap: float = absf(visual.source_to_local(sole).y)
		print("Rowan sole ",sole," floor gap: ",floor_gap)
		if floor_gap > 1.0:
			failed = true
		for direction in [-1.0,1.0]:
			for frame in 60:
				visual.clock = frame*.1
				visual.facing = direction
				assert(absf(visual.source_to_local(sole).y) < 1,"Idle breathing must not lift either sole")
	visual.free()
	var npc = preload("res://prototypes/training_clearing/rowan_behavior.gd").new()
	var saw_walk := false
	var saw_speech := false
	for frame in 3600:
		npc.step(1.0/60,Vector2(160,480),true)
		assert(npc.position.y == 480 and absf(npc.position.x-330) <= 24)
		saw_walk = saw_walk or npc.walking
		saw_speech = saw_speech or not npc.speech.is_empty()
	assert(saw_walk and saw_speech,"Rowan should wander and speak in peaceful play")
	npc.begin_conversation(npc.position+Vector2(70,0))
	var stopped: Vector2 = npc.position
	npc.step(20,Vector2(400,480),true)
	assert(npc.position == stopped and not npc.walking and npc.facing == 1)
	assert(npc.speech.is_empty())
	npc.end_conversation()
	npc.step(1,npc.position-Vector2(70,0),true)
	assert(npc.position == stopped and npc.facing == -1,"Do not walk away from an approaching player")
	npc.step(20,Vector2(160,480),false)
	assert(npc.speech.is_empty() and not npc.walking,"Suppress chatter during combat")
	var model = preload("res://prototypes/training_clearing/encounter.gd").new()
	model.rowan.position.x = 306
	model.position.x = 194
	assert(model.can_talk_to_rowan(),"Interaction must follow the NPC, not his stall")
	model.rowan.position.x = 346
	assert(not model.can_talk_to_rowan())
	if failed:
		printerr("FAIL: both Rowan boots must meet the ground within one pixel")
	else:
		print("PASS: both soles grounded, idle facings, bounded patrol, conversation stop, ambient speech and moving interaction range")
	quit(1 if failed else 0)
