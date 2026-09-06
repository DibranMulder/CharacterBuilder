extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/fabric_motion_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,900)
const TILE_SIZE := Vector2(400,300)
const SAMPLES := [
	{"title":"STAND / AUTHORED HANG", "mode":"stand"},
	{"title":"IDLE / BREATHING DRIFT", "mode":"idle"},
	{"title":"RUN / TRAILING A", "mode":"run", "steps":[.17]},
	{"title":"RUN / TRAILING B", "mode":"run", "steps":[.255]},
	{"title":"STAIRS / RESTRAINED", "mode":"stairs", "steps":[.33]},
	{"title":"LADDER / FOLLOW", "mode":"climb", "steps":[.56]},
	{"title":"FOREHAND / CONTACT", "mode":"forehand", "steps":[.38,.06]},
	{"title":"BOW / FULL DRAW", "mode":"fire_bow", "weapon":"bow", "steps":[.40]},
	{"title":"CROSSCUT / IMPACT", "mode":"gesture", "gesture":0},
]


func _initialize() -> void:
	_render.call_deferred()


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas,Rect2(Vector2.ZERO,Vector2(VIEWPORT_SIZE)),Color("101a2b"),-100)
	for index in SAMPLES.size():
		_add_sample(canvas,Vector2(index%3,index/3)*TILE_SIZE,SAMPLES[index],index)
	Engine.time_scale = 0.0
	for frame in 6:
		await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		Engine.time_scale = 1.0
		quit(1)
		return
	Engine.time_scale = 1.0
	print("PASS: rendered cape and scarf secondary motion to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D,origin: Vector2,sample: Dictionary,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,252),Vector2(TILE_SIZE.x-16,40)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(20,18)
	title.text = sample.title
	title.add_theme_font_size_override("font_size",18)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(200,252)
	avatar.scale = Vector2.ONE*.94
	canvas.add_child(avatar)
	avatar.configure("human",{"weapon":sample.get("weapon","sword"),"offhand":"none","armor":"marsh_tunic","pants":"ranger","boots":"leather","head":"none","back":"long_cape","accessory":"scarf"})
	match sample.mode:
		"stand": avatar.play_motion(&"stand")
		"idle":
			avatar._idle_phase = 1.25
			avatar._process(0.0)
		"run", "stairs", "climb":
			avatar.play_motion(StringName(sample.mode))
			for step in sample.steps:
				avatar._active_tween.custom_step(float(step))
			avatar._active_tween.pause()
		"gesture":
			var motion: Dictionary = Avatar.RACE_GESTURE_MOTIONS.human_0
			avatar.play_gesture(int(sample.gesture))
			avatar._active_tween.custom_step(float(motion.times[0])+float(motion.times[1]))
			avatar._active_tween.pause()
			var effect: Node2D = avatar._bones.rig.get_node("GestureEffect")
			effect.call("set_progress",.42)
		_:
			avatar.play_weapon_attack(StringName(sample.mode))
			for step in sample.steps:
				avatar._active_tween.custom_step(float(step))
			avatar._active_tween.pause()


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
