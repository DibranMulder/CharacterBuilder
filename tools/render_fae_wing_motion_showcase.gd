extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/fae_wing_motion_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,900)
const TILE_SIZE := Vector2(400,300)
const SAMPLES := [
	{"title":"STAND / WINGS REST", "mode":"stand"},
	{"title":"IDLE / SOFT FLUTTER", "mode":"idle"},
	{"title":"RUN / DOWNSTROKE", "mode":"run", "time":.07},
	{"title":"RUN / UPSTROKE", "mode":"run", "time":.34},
	{"title":"STAIRS / BALANCE", "mode":"stairs", "time":.44},
	{"title":"LADDER / FOLDED", "mode":"climb", "time":.28},
	{"title":"WAND ARC / IMPACT", "mode":"gesture", "gesture":0},
	{"title":"GALE STEP / IMPACT", "mode":"gesture", "gesture":1},
	{"title":"STAR BLOOM / IMPACT", "mode":"gesture", "gesture":2},
]

var _render_failed := false


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
	if _render_failed:
		push_error("Aeralith wing showcase could not stage every required gesture effect")
		quit(1)
		return
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
	print("PASS: rendered Aeralith wing motion contract to %s" % OUTPUT_PATH)
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
	avatar.scale = Vector2.ONE*.86
	canvas.add_child(avatar)
	avatar.configure("fae",{"weapon":"branch_staff","offhand":"none","armor":"fae_tunic","pants":"baggy","boots":"wraps","head":"none","back":"none","accessory":"none"})
	match sample.mode:
		"stand": avatar.play_motion(&"stand")
		"idle":
			avatar._idle_phase = 1.25
			avatar._process(0.0)
		"gesture":
			var gesture_index: int = sample.gesture
			var motion: Dictionary = Avatar.RACE_GESTURE_MOTIONS["fae_%d" % gesture_index]
			avatar.play_gesture(gesture_index)
			# Gesture effects now spawn only after the final impact pose completes.
			# Step just beyond that callback and retrieve the tracked effect because
			# projectile/contact effects intentionally detach from the rig afterward.
			avatar._active_tween.custom_step(float(motion.times[0])+float(motion.times[1])+.001)
			avatar._process(0.0)
			avatar._active_tween.pause()
			if avatar._gesture_effects.is_empty() or not is_instance_valid(avatar._gesture_effects[-1]):
				_render_failed = true
				push_error("Missing completed-impact effect for Aeralith gesture %d" % gesture_index)
				return
			var effect: Node2D = avatar._gesture_effects[-1]
			effect.call("set_progress",.42)
		_:
			avatar.play_motion(StringName(sample.mode))
			avatar._active_tween.custom_step(float(sample.time))
			avatar._active_tween.pause()


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
