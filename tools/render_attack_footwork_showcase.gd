extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/attack_footwork_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,760)
const TILE_SIZE := Vector2(400,380)
const ATTACKS := [
	{"name":"JAB", "id":&"jab", "time":.30},
	{"name":"FOREHAND", "id":&"forehand", "time":.38},
	{"name":"BACKHAND", "id":&"backhand", "time":.39},
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
	for row in 2:
		for column in 3:
			_add_attack(canvas,Vector2(column,row)*TILE_SIZE,"human" if row == 0 else "centaur",ATTACKS[column])
	for frame in 6:
		await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		quit(1)
		return
	print("PASS: rendered biped and centaur attack footwork to %s" % OUTPUT_PATH)
	quit()


func _add_attack(canvas: Node2D,origin: Vector2,race_id: String,attack: Dictionary) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,322),Vector2(TILE_SIZE.x-16,50)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(20,18)
	title.text = "%s / %s WEIGHT TRANSFER" % [String(CharacterCatalog.race(race_id).name).to_upper(),attack.name]
	title.add_theme_font_size_override("font_size",17)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(190 if race_id == "human" else 205,310 if race_id == "centaur" else 322)
	avatar.scale = Vector2.ONE*(1.32 if race_id == "human" else .94)
	canvas.add_child(avatar)
	avatar.configure(race_id,{"weapon":"sword","offhand":"none","armor":"cloth" if race_id == "human" else "woodland_harness","pants":"ranger" if race_id == "human" else "none","boots":"leather" if race_id == "human" else "none","head":"none","back":"cape","accessory":"none"})
	avatar.play_weapon_attack(attack.id)
	avatar._active_tween.custom_step(float(attack.time))
	avatar._active_tween.pause()


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
