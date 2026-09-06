extends SceneTree

const Builder := preload("res://main.tscn")
const OUTPUT_PATH := "res://artifacts/builder_stairs_preview.png"
const VIEWPORT_SIZE := Vector2i(1152,648)


func _initialize() -> void:
	_render.call_deferred()


func _render() -> void:
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var builder := Builder.instantiate()
	viewport.add_child(builder)
	await process_frame
	builder.avatar.play_motion(&"stairs")
	builder.avatar._active_tween.custom_step(ModularCharacter.STAIR_FRAME_DURATION*4.0)
	builder.avatar._active_tween.pause()
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
	print("PASS: rendered builder stair preview to %s" % OUTPUT_PATH)
	quit()
