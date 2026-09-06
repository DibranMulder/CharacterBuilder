extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const Ladder := preload("res://src/ladder_visual.gd")
const OUTPUT_PATH := "res://artifacts/utility_equipment_showcase.png"
const VIEWPORT_SIZE := Vector2i(1800,410)
const TILE_SIZE := Vector2(300,410)
const SAMPLES := [
	{"title":"LANTERN / UPRIGHT HAND", "offhand":"lantern", "climb":false},
	{"title":"LANTERN / RUN HANG", "offhand":"lantern", "climb":false, "motion":&"run", "time":.24},
	{"title":"LANTERN / STAIR HANG", "offhand":"lantern", "climb":false, "motion":&"stairs", "time":.32},
	{"title":"LANTERN / REAR STOW", "offhand":"lantern", "climb":true},
	{"title":"SPELLBOOK / REAR STOW", "offhand":"spellbook", "climb":true},
	{"title":"BOW / VISIBLE QUIVER", "offhand":"none", "climb":false, "weapon":"bow", "back":"quiver"},
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
	print("PASS: rendered utility hand, rear-stow, and quiver visibility states to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D,origin: Vector2,sample: Dictionary,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(7,7),TILE_SIZE-Vector2(14,14)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(7,350),Vector2(TILE_SIZE.x-14,53)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(15,18)
	title.text = sample.title
	title.add_theme_font_size_override("font_size",16)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var ground := origin+Vector2(150,350)
	if sample.climb:
		var ladder := Ladder.new()
		ladder.position = ground
		ladder.scale = Vector2.ONE*.67
		ladder.z_index = -12
		canvas.add_child(ladder)
	var avatar := Avatar.new()
	avatar.position = ground
	avatar.scale = Vector2.ONE*1.03
	canvas.add_child(avatar)
	avatar.configure("human",{
		"weapon":sample.get("weapon","sword"), "offhand":sample.offhand,
		"armor":"cloth", "pants":"ranger", "boots":"leather",
		"head":"none", "back":sample.get("back","none"), "accessory":"none",
	})
	if sample.climb:
		avatar.play_motion(&"climb")
		avatar._active_tween.custom_step(.28)
		avatar._active_tween.pause()
	elif sample.has("motion"):
		avatar.play_motion(sample.motion)
		avatar._active_tween.custom_step(float(sample.time))
		avatar._process(.25)
		avatar._active_tween.pause()
	else:
		avatar.play_motion(&"stand")


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
