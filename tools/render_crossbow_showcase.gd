extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/crossbow_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,760)
const TILE_SIZE := Vector2(400,380)
const SAMPLES := [
	{"title":"REST / TWO-HANDED", "mode":&"stand"},
	{"title":"SIGHT / GROUNDED", "mode":&"fire_crossbow", "time":.27},
	{"title":"FIRE / BOLT RELEASE", "mode":&"fire_crossbow", "time":.381},
	{"title":"RECOIL / ABSORB", "mode":&"fire_crossbow", "time":.43},
	{"title":"RUN / CARRY", "mode":&"run", "time":.25},
	{"title":"LADDER / BACK MOUNT", "mode":&"climb", "time":.32},
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
	Engine.time_scale = 0.0
	for index in SAMPLES.size():
		_add_sample(canvas,Vector2(index%3,index/3)*TILE_SIZE,SAMPLES[index],index)
	for frame in 6:
		await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		Engine.time_scale = 1.0
		quit(1)
		return
	Engine.time_scale = 1.0
	print("PASS: rendered Deep Goblin crossbow rest, fire, locomotion, and climb states to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D,origin: Vector2,sample: Dictionary,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,322),Vector2(TILE_SIZE.x-16,50)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(22,20)
	title.text = sample.title
	title.add_theme_font_size_override("font_size",20)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(150 if String(sample.title).begins_with("FIRE") else 200,322)
	avatar.scale = Vector2.ONE*1.65
	canvas.add_child(avatar)
	avatar.configure("goblin",{"weapon":"crossbow","offhand":"none","armor":"leather","pants":"leather","boots":"leather","head":"none","back":"pack","accessory":"goggles"})
	if sample.mode == &"stand":
		avatar.play_motion(&"stand")
	elif sample.mode == &"fire_crossbow":
		avatar.play_weapon_attack(&"fire_crossbow")
		avatar._active_tween.custom_step(float(sample.time))
		avatar._active_tween.pause()
		avatar.call("_update_crossbow_support_grip")
		if avatar.has_node("FiredBolt"):
			var bolt: Sprite2D = avatar.get_node("FiredBolt")
			if String(sample.title).begins_with("FIRE"):
				bolt.visible = false
				var released_bolt := Sprite2D.new()
				released_bolt.texture = bolt.texture
				released_bolt.position = origin+Vector2(330,255)
				released_bolt.scale = Vector2.ONE*1.65
				released_bolt.z_index = 30
				canvas.add_child(released_bolt)
			else:
				bolt.visible = false
	else:
		avatar.play_motion(sample.mode)
		avatar._active_tween.custom_step(float(sample.time))
		avatar._active_tween.pause()


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
