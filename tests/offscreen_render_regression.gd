extends SceneTree
var failed := false
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func run() -> void:
	var scene = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene.model.position = Vector2(160,480)
	scene._update_view(1)
	check(not scene.rowan.visible,"offscreen Rowan is culled in gameplay")
	var mesh = scene.rowan.surface.mesh
	var clock: float = scene.rowan.clock
	for i in 10: scene._update_view(1.0/60)
	check(scene.rowan.surface.mesh == mesh,"offscreen idle animation does not upload new meshes")
	check(scene.rowan.clock > clock,"hidden animation time keeps advancing")
	scene.camera_x = 1100
	scene._update_view(0)
	check(scene.rowan.visible,"Rowan becomes visible when the camera reaches him")
	scene._update_view(1.0/60)
	check(scene.rowan.surface.mesh != mesh,"visible NPC resumes animation")
	scene.queue_free()
	await process_frame
	if not failed: print("PASS: offscreen NPC culling, no hidden mesh uploads and animation resumes on camera entry")
	quit(1 if failed else 0)
