extends SceneTree
## Render the shared theme's interaction states without entering gameplay.
const Chronicle = preload("res://src/ui/chronicle_theme.gd")

func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var board := Control.new()
	board.set_script(preload("res://src/ui/style_board.gd"))
	board.theme = Chronicle.create()
	viewport.add_child(board)
	for frame in 5:
		await process_frame
	var result := viewport.get_texture().get_image().save_png("res://artifacts/chronicle_ui.png")
	print("Shared UI state gallery rendered")
	quit(0 if result == OK else 1)
