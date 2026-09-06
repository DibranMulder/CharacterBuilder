extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/gesture_effect_showcase.png"
const VIEWPORT_SIZE := Vector2i(1800,1200)
const TILE_SIZE := Vector2(300,300)


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
	var sample_index := 0
	for race_id in CharacterCatalog.race_ids():
		for gesture_index in 3:
			_add_sample(canvas,Vector2(sample_index%6,sample_index/6)*TILE_SIZE,race_id,gesture_index,sample_index)
			sample_index += 1
	Engine.time_scale = 0.0
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
	Engine.time_scale = 1.0
	print("PASS: rendered all 24 named lineage gesture effects to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D, origin: Vector2, race_id: String, gesture_index: int, sample_index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(6,6),TILE_SIZE-Vector2(12,12)),Color("172740") if sample_index%2 == 0 else Color("192b43"),-90)
	var gesture: Dictionary = CharacterCatalog.race(race_id).gestures[gesture_index]
	var title := Label.new()
	title.position = origin+Vector2(14,13)
	title.text = "%s / %s" % [String(CharacterCatalog.race(race_id).name).to_upper(),String(gesture.name).to_upper()]
	title.add_theme_font_size_override("font_size",14)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(150,270)
	avatar.scale = Vector2.ONE*(.56 if race_id != "frost_troll" else .43)
	canvas.add_child(avatar)
	avatar.configure(race_id,CharacterCatalog.reference_loadout(race_id))
	var motion_id := "%s_%d" % [race_id,gesture_index]
	var motion: Dictionary = Avatar.RACE_GESTURE_MOTIONS[motion_id]
	avatar.play_gesture(gesture_index)
	avatar._active_tween.custom_step(float(motion.times[0])+float(motion.times[1])+.001)
	avatar._active_tween.pause()
	avatar._process(0.0)
	var effect: Node2D = avatar._gesture_effects[-1]
	effect.call("set_progress",.42)


func _add_rect(parent: Node, rect: Rect2, color: Color, z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
