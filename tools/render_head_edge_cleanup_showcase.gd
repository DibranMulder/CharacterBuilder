extends SceneTree

const BaseAnatomy := preload("res://src/base_anatomy_visual.gd")
const OUTPUT_PATH := "res://artifacts/head_edge_cleanup_showcase.png"
const VIEWPORT_SIZE := Vector2i(1600,800)
const TILE_SIZE := Vector2(400,400)


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
	for index in race_ids.size():
		_add_tile(canvas,Vector2(index%4,index/4)*TILE_SIZE,race_ids[index],index)
	for frame in 6:
		await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		quit(1)
		return
	print("PASS: rendered keyed head edge close-ups to %s" % OUTPUT_PATH)
	quit()


func _add_tile(canvas: Node2D,origin: Vector2,race_id: String,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	var title := Label.new()
	title.position = origin+Vector2(20,17)
	title.text = String(CharacterCatalog.race(race_id).name).to_upper()
	title.add_theme_font_size_override("font_size",22)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	_add_label(canvas,origin+Vector2(82,60),"FRONT")
	_add_label(canvas,origin+Vector2(267,60),"BACK")
	var front := BaseAnatomy.new().setup(race_id,"head",Vector2(170,170),false)
	front.position = origin+Vector2(115,245)
	canvas.add_child(front)
	var back := BaseAnatomy.new().setup(race_id,"head",Vector2(170,170),true)
	back.position = origin+Vector2(285,245)
	canvas.add_child(back)
	_add_rect(canvas,Rect2(origin+Vector2(22,350),Vector2(356,2)),Color(0.45,0.75,0.78,.22),-80)


func _add_label(parent: Node,position_: Vector2,text_: String) -> void:
	var label := Label.new()
	label.position = position_
	label.text = text_
	label.add_theme_font_size_override("font_size",14)
	label.add_theme_color_override("font_color",Color("91a4bb"))
	parent.add_child(label)


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
