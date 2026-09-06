extends SceneTree

const Avatar := preload("res://src/modular_character.gd")

const OUTPUT_PATH := "res://artifacts/current_lineage_showcase.png"
const CANVAS_SIZE := Vector2i(1600, 900)
const TILE_SIZE := Vector2(400, 450)
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
	_add_rect(canvas, Rect2(Vector2.ZERO, Vector2(CANVAS_SIZE)), Color("101a2b"), -100)

	var race_ids := CharacterCatalog.race_ids()
	for index in race_ids.size():
		var race_id: String = race_ids[index]
		var column := index % 4
		var row := index / 4
		var tile_origin := Vector2(column, row) * TILE_SIZE
		_add_tile(canvas, tile_origin, race_id, index)

	for frame in 6:
		await process_frame
	var texture := viewport.get_texture()
	if texture == null:
		push_error("No render texture is available; run this tool with a graphics display instead of --headless")
		quit(1)
		return
	var image := texture.get_image()
	if image == null:
		push_error("The showcase render returned no image")
		quit(1)
		return
	var error := image.save_png(OUTPUT_PATH)
	if error != OK:
		push_error("Could not save showcase to %s (error %d)" % [OUTPUT_PATH, error])
		quit(1)
		return
	var leaked_key_pixels := _count_magenta_key_pixels(image)
	if leaked_key_pixels > 20:
		push_error("Showcase leaked %d chroma-magenta key pixels" % leaked_key_pixels)
		quit(1)
		return
	print("PASS: rendered all 8 lineages to %s" % OUTPUT_PATH)
	quit()


func _count_magenta_key_pixels(image: Image) -> int:
	var count := 0
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x,y)
			if color.r > .78 and color.b > .78 and color.g < .28 and color.a > .5:
				count += 1
	return count


func _add_tile(canvas: Node2D, origin: Vector2, race_id: String, index: int) -> void:
	var panel_color := Color("172740") if index % 2 == 0 else Color("192b43")
	_add_rect(canvas, Rect2(origin + Vector2(8, 8), TILE_SIZE - Vector2(16, 16)), panel_color, -90)
	_add_rect(canvas, Rect2(origin + Vector2(8, 377), TILE_SIZE - Vector2(16, 24)), Color("21384c"), -80)

	var glow := Polygon2D.new()
	glow.polygon = _ellipse_points(Vector2(120, 38), 32)
	glow.position = origin + Vector2(200, 363)
	glow.color = Color(0.26, 0.67, 0.78, 0.12)
	glow.z_index = -70
	canvas.add_child(glow)

	var avatar := Avatar.new()
	avatar.position = origin + Vector2(200, 362)
	avatar.scale = Vector2.ONE * (0.86 if race_id != "frost_troll" else 0.76)
	canvas.add_child(avatar)
	var showcase_loadout := CharacterCatalog.reference_loadout(race_id)
	avatar.configure(race_id, showcase_loadout)
	avatar._idle_phase = 0.55 + index * 0.31

	var profile := CharacterCatalog.race(race_id)
	var title := Label.new()
	title.position = origin + Vector2(24, 20)
	title.text = String(profile.name).to_upper()
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("f2d181"))
	canvas.add_child(title)

	var subtitle := Label.new()
	subtitle.position = origin + Vector2(25, 53)
	subtitle.text = String(profile.tagline)
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color("a8bbce"))
	canvas.add_child(subtitle)


func _add_rect(parent: Node, rect: Rect2, color: Color, z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0),
		rect.end,
		rect.position + Vector2(0, rect.size.y),
	])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)


func _ellipse_points(radius: Vector2, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point_index in segments:
		var angle := TAU * float(point_index) / float(segments)
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points
