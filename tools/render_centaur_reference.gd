extends "res://tools/render_centaur_views.gd"


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas, Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE)), Color("101a2b"), -100)
	_add_rect(canvas, Rect2(25, 70, 450, 440), Color("192b43"), -90)
	var title := Label.new()
	title.position = Vector2(45, 90)
	title.text = "LIGHT-LINEAGES REFERENCE"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f2d181"))
	canvas.add_child(title)
	var crop := AtlasTexture.new()
	crop.atlas = load("res://light-lineages.png")
	crop.region = Rect2(665, 385, 315, 380)
	var reference := Sprite2D.new()
	reference.texture = crop
	reference.position = Vector2(250, 302)
	reference.scale = Vector2.ONE * .9
	canvas.add_child(reference)
	_add_view(canvas, Vector2(750, 500), "REBUILT / IN-GAME", false)
	for frame in 6:
		await process_frame
	var result := viewport.get_texture().get_image().save_png("res://artifacts/centaur_reference_comparison.png")
	if result != OK:
		push_error("Could not save reference comparison")
		quit(1)
		return
	print("PASS: rendered original concept beside the live centaur rig")
	quit()
