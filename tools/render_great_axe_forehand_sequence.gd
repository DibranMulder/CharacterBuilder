extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/great_axe_forehand_sequence.png"
const VIEWPORT_SIZE := Vector2i(1500,430)
const TILE_SIZE := Vector2(300,430)
const SAMPLES := [
	{"title":"TWO-HANDED REST", "time":0.0},
	{"title":"REAR OVERHEAD LOAD", "time":.22},
	{"title":"DIAGONAL GUARD", "time":.32},
	{"title":"DRIVEN CONTACT", "time":.45},
	{"title":"CONTINUOUS FOLLOW", "time":.55},
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
		_add_sample(canvas,Vector2(index*TILE_SIZE.x,0),SAMPLES[index],index)
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
	print("PASS: rendered smoothed Frost Troll great-axe Forehand to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D,origin: Vector2,sample: Dictionary,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,370),Vector2(TILE_SIZE.x-16,52)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(16,20)
	title.text = sample.title
	title.add_theme_font_size_override("font_size",15)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(150,370)
	avatar.scale = Vector2.ONE*.86
	canvas.add_child(avatar)
	avatar.configure("frost_troll",CharacterCatalog.reference_loadout("frost_troll"))
	if float(sample.time) > 0.0:
		avatar.play_weapon_attack(&"forehand")
		avatar._active_tween.custom_step(float(sample.time))
		avatar._active_tween.pause()
		avatar._process(0.0)


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
