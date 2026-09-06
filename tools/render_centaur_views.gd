extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/centaur_views.png"
const VIEWPORT_SIZE := Vector2i(1000, 620)


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

	_add_view(canvas,Vector2(250,500),"SIDE / IDLE",false)
	_add_view(canvas,Vector2(750,500),"REAR / CLIMB",true)

	for frame in 6:
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
	print("PASS: rendered Centaur side and climbing views to %s" % OUTPUT_PATH)
	quit()


func _add_view(canvas: Node2D, position_: Vector2, title_text: String, climbing: bool) -> void:
	_add_rect(canvas,Rect2(position_+Vector2(-225,-430),Vector2(450,440)),Color("192b43"),-90)
	var floor_color := Color("21384c")
	_add_rect(canvas,Rect2(position_+Vector2(-225,-35),Vector2(450,45)),floor_color,-80)
	var title := Label.new()
	title.position = position_+Vector2(-205,-410)
	title.text = title_text
	title.add_theme_font_size_override("font_size",24)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)

	var avatar := Avatar.new()
	avatar.position = position_+Vector2(0,-35)
	avatar.scale = Vector2.ONE*1.65
	canvas.add_child(avatar)
	avatar.configure("centaur",{
		"weapon":"bow", "offhand":"none", "armor":"woodland_harness", "pants":"none",
		"head":"none", "back":"quiver", "accessory":"amulet",
	})
	if climbing:
		avatar.play_motion(&"climb")
		avatar._active_tween.custom_step(.28)


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
