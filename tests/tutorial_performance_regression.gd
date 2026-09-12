extends SceneTree
const Clearing = preload("res://prototypes/training_clearing/training_clearing.tscn")
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var scene = Clearing.instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene._start_tutorial()
	for i in 20: scene.tutorial_panel.refresh()
	var started := Time.get_ticks_usec()
	for i in 1000: scene.tutorial_panel.refresh()
	var cost := (Time.get_ticks_usec()-started)/1000.0
	print("Tutorial steady-state refresh: %.1f microseconds/frame (informational timing)" % cost)
	for i in 5: await process_frame
	var visibility_changes := [0]
	for node in scene.get_children():
		if node is Button: node.visibility_changed.connect(func(): visibility_changes[0] += 1)
	var layouts := [0]
	var redraws := [0]
	for node in scene.tutorial_panel.find_children("*","CanvasItem",true,false):
		node.draw.connect(func(): redraws[0] += 1)
	scene.tutorial_panel.resized.connect(func(): layouts[0] += 1)
	for i in 60:
		scene._update_view(0)
		await process_frame
	print("Unchanged overlay: %d layout resizes across 60 frames (budget: 1)" % layouts[0])
	print("Unchanged action-control visibility changes: %d (budget: 0)" % visibility_changes[0])
	print("Unchanged overlay subtree redraws: %d (budget: 2)" % redraws[0])
	scene.free()
	if redraws[0] > 2 or layouts[0] > 1 or visibility_changes[0] > 0:
		printerr("FAIL: unchanged tutorial UI rebuilds rendering every frame")
		quit(1)
	else:
		print("PASS: tutorial steady-state refresh budget")
		quit()
