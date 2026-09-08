extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/centaur_gallop_showcase.png"
const VIEWPORT_SIZE := Vector2i(1600,420)
const TILE_SIZE := Vector2(200,420)
const PHASE_NAMES := ["CONTACT A","COMPRESS A","PASS A","REACH B","CONTACT B","COMPRESS B","PASS B","REACH A"]


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
	for phase_index in Avatar.CENTAUR_RUN_CYCLE.size():
		_add_phase(canvas,phase_index)
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
	print("PASS: rendered eight-phase Grove Centaur gallop to %s" % OUTPUT_PATH)
	quit()


func _add_phase(canvas: Node2D,phase_index: int) -> void:
	var origin := Vector2(phase_index*TILE_SIZE.x,0)
	_add_rect(canvas,Rect2(origin+Vector2(5,5),TILE_SIZE-Vector2(10,10)),Color("192b43") if phase_index%2 == 0 else Color("172740"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(5,350),Vector2(TILE_SIZE.x-10,60)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(12,16)
	title.text = "%d / %s" % [phase_index+1,PHASE_NAMES[phase_index]]
	title.add_theme_font_size_override("font_size",15)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(102,350)
	avatar.scale = Vector2.ONE*.72
	canvas.add_child(avatar)
	avatar.configure("centaur",CharacterCatalog.reference_loadout("centaur"))
	avatar.play_motion(&"run")
	avatar._active_tween.custom_step(Avatar.RUN_FRAME_DURATION*float(phase_index+1))
	avatar._active_tween.pause()


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
