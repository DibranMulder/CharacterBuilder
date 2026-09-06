extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/human_ranger_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,760)
const TILE_SIZE := Vector2(400,380)
const SAMPLES := [
	{"title":"FRONT / STAND", "mode":&"stand", "time":0.0},
	{"title":"SWORD / JAB", "mode":&"jab", "time":.30},
	{"title":"SWORD / FOREHAND", "mode":&"forehand", "time":.38},
	{"title":"SWORD / BACKHAND", "mode":&"backhand", "time":.39},
	{"title":"RANGER / RUN", "mode":&"run", "time":.24},
	{"title":"RANGER / STAIRS", "mode":&"stairs", "time":.32},
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
	for frame in 6:
		await process_frame
	var image := viewport.get_texture().get_image()
	var output := "res://artifacts/human_body_showcase.png" if "--bare" in OS.get_cmdline_user_args() else OUTPUT_PATH
	if image == null or image.save_png(output) != OK:
		push_error("Could not save %s" % output)
		quit(1)
		return
	print("PASS: rendered human pose showcase to %s" % output)
	quit()


func _add_sample(canvas: Node2D,origin: Vector2,sample: Dictionary,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,322),Vector2(TILE_SIZE.x-16,50)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(22,20)
	title.text = sample.title
	title.add_theme_font_size_override("font_size",19)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(200,322)
	avatar.scale = Vector2.ONE*1.18
	canvas.add_child(avatar)
	avatar.configure("human",{
		"weapon":"sword", "offhand":"none", "armor":"marsh_tunic",
		"pants":"ranger", "boots":"leather", "head":"none",
		"back":"long_cape", "accessory":"scarf",
	})
	var overrides: Dictionary = sample.get("loadout", {})
	for slot in overrides:
		avatar.equip(StringName(slot), overrides[slot])
	if "--left" in OS.get_cmdline_user_args():
		avatar.set_facing(&"left")
	if "--bare" in OS.get_cmdline_user_args():
		for slot in ["offhand", "armor", "pants", "boots", "head", "back", "accessory"]:
			avatar.equip(StringName(slot), "none")
	if sample.has("gesture"):
		avatar.play_gesture(int(sample.gesture))
	elif sample.mode in [&"jab",&"forehand",&"backhand",&"fire_bow",&"fire_crossbow",&"cast_spell"]:
		avatar.play_weapon_attack(sample.mode)
	else:
		avatar.play_motion(sample.mode)
	if avatar._active_tween:
		# Advance through callbacks and successive tween phases as the runtime
		# does; a single large step can initialize later phases at the wrong pose.
		var remaining := float(sample.time)
		while remaining > 0.0:
			var step := minf(remaining, 1.0 / 120.0)
			avatar._active_tween.custom_step(step)
			remaining -= step
		avatar._active_tween.pause()


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
