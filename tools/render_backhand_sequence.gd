extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/backhand_sequence.png"
const VIEWPORT_SIZE := Vector2i(1500,800)
const TILE_SIZE := Vector2(300,400)
const SAMPLES := [
	{"title":"IDLE GUARD", "time":0.0},
	{"title":"HIGH CROSS-BODY WINDUP", "time":0.20},
	{"title":"LOW LOADED GUARD", "time":0.28},
	{"title":"RISING CONTACT", "time":0.39},
	{"title":"FOLLOW-THROUGH", "time":0.51},
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
	for sample_index in SAMPLES.size():
		_add_sample(canvas,Vector2(sample_index*TILE_SIZE.x,0),SAMPLES[sample_index],"human")
		_add_sample(canvas,Vector2(sample_index*TILE_SIZE.x,TILE_SIZE.y),SAMPLES[sample_index],"frost_troll")
	for frame in 5:
		await process_frame
	var texture := viewport.get_texture()
	if texture == null:
		push_error("No render texture; run this tool with a graphics display")
		quit(1)
		return
	var image := texture.get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		quit(1)
		return
	print("PASS: rendered Human and Crag Troll five-stage backhand sequences to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D, origin: Vector2, sample: Dictionary, race_id: String) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,342),Vector2(TILE_SIZE.x-16,50)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(18,20)
	title.text = ("HUMAN / " if race_id == "human" else "TROLL / ")+String(sample.title)
	title.add_theme_font_size_override("font_size",15)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(150,342)
	avatar.scale = Vector2.ONE*(1.35 if race_id == "human" else .82)
	canvas.add_child(avatar)
	avatar.configure(race_id,{
		"weapon":"sword" if race_id == "human" else "axe", "offhand":"none",
		"armor":"cloth" if race_id == "human" else "leather", "pants":"leather",
		"boots":"leather" if race_id == "human" else "none",
		"head":"none", "back":"cape", "accessory":"none",
	})
	if float(sample.time) > 0.0:
		avatar.play_weapon_attack(&"backhand")
		avatar._active_tween.custom_step(float(sample.time))
		avatar._active_tween.pause()


func _add_rect(parent: Node, rect: Rect2, color: Color, z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([
		rect.position,
		rect.position+Vector2(rect.size.x,0),
		rect.end,
		rect.position+Vector2(0,rect.size.y),
	])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
