extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/base_anatomy_showcase.png"
const VIEWPORT_SIZE := Vector2i(1600,900)
const TILE_SIZE := Vector2(400,450)
const EMPTY_LOADOUT := {
	"weapon":"none", "offhand":"none", "armor":"none", "pants":"none",
	"boots":"none", "head":"none", "back":"none", "accessory":"none",
}


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
	var race_ids := CharacterCatalog.race_ids()
	for race_index in race_ids.size():
		_add_tile(canvas,Vector2(race_index%4,race_index/4)*TILE_SIZE,race_ids[race_index],race_index)
	Engine.time_scale = 0.0
	for frame in 6:
		await process_frame
	var texture := viewport.get_texture()
	if texture == null:
		push_error("No render texture; run this tool with a graphics display")
		Engine.time_scale = 1.0
		quit(1)
		return
	var image := texture.get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		Engine.time_scale = 1.0
		quit(1)
		return
	Engine.time_scale = 1.0
	print("PASS: rendered unarmored front/rear anatomy for all 8 lineages to %s" % OUTPUT_PATH)
	quit()


func _add_tile(canvas: Node2D,origin: Vector2,race_id: String,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,380),Vector2(TILE_SIZE.x-16,62)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(20,18)
	title.text = "%s / BASE ANATOMY" % String(CharacterCatalog.race(race_id).name).to_upper()
	title.add_theme_font_size_override("font_size",19)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	for view_index in 2:
		var avatar := Avatar.new()
		avatar.position = origin+Vector2(125+view_index*150,378)
		var preview_scale := .78 if race_id == "frost_troll" else (.66 if race_id == "centaur" else .9)
		avatar.scale = Vector2.ONE*preview_scale
		canvas.add_child(avatar)
		avatar.configure(race_id,EMPTY_LOADOUT)
		avatar.play_motion(&"stand")
		if view_index == 1:
			avatar._set_back_view(true)
			avatar._bones.rig.scale.x = -absf(avatar._bones.rig.scale.x)
		var view_label := Label.new()
		view_label.position = origin+Vector2(92+view_index*150,65)
		view_label.text = "FRONT" if view_index == 0 else "REAR"
		view_label.add_theme_font_size_override("font_size",13)
		view_label.add_theme_color_override("font_color",Color("a8bbce"))
		canvas.add_child(view_label)


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
