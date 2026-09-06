extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/idle_stand_showcase.png"
const CANVAS_SIZE := Vector2i(1600,900)
const TILE_SIZE := Vector2(400,450)
func _initialize() -> void:
	_render.call_deferred()


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = CANVAS_SIZE
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas,Rect2(Vector2.ZERO,Vector2(CANVAS_SIZE)),Color("101a2b"),-100)
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
	print("PASS: rendered Stand and Idle comparison to %s" % OUTPUT_PATH)
	quit()


func _add_tile(canvas: Node2D,origin: Vector2,race_id: String,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(199,76),Vector2(2,330)),Color(0.45,0.75,0.78,.2),-80)
	var profile := CharacterCatalog.race(race_id)
	var title := Label.new()
	title.position = origin+Vector2(20,17)
	title.text = String(profile.name).to_upper()
	title.add_theme_font_size_override("font_size",23)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	_add_label(canvas,origin+Vector2(61,61),"STAND",Color("91a4bb"),14)
	_add_label(canvas,origin+Vector2(251,61),"IDLE CREST",Color("77d4cf"),14)
	var loadout := CharacterCatalog.reference_loadout(race_id)
	var avatar_scale := .66 if race_id != "frost_troll" else .58
	var stand_avatar := Avatar.new()
	stand_avatar.position = origin+Vector2(107,392)
	stand_avatar.scale = Vector2.ONE*avatar_scale
	canvas.add_child(stand_avatar)
	stand_avatar.configure(race_id,loadout)
	stand_avatar.play_motion(&"stand")
	var idle_avatar := Avatar.new()
	idle_avatar.position = origin+Vector2(293,392)
	idle_avatar.scale = Vector2.ONE*avatar_scale
	canvas.add_child(idle_avatar)
	idle_avatar.configure(race_id,loadout)
	idle_avatar.play_motion(&"idle")
	idle_avatar._idle_phase = 1.25
	idle_avatar._process(0.0)


func _add_label(parent: Node,position_: Vector2,text_: String,color: Color,size: int) -> void:
	var label := Label.new()
	label.position = position_
	label.text = text_
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	parent.add_child(label)


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
