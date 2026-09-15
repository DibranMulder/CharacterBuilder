extends SceneTree
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func _run() -> void:
	var town = preload("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	town.district_id = "barracks"
	root.add_child(town)
	town.set_physics_process(false)
	for axis in [-1,1]:
		town.model.position = Vector2(994,410)
		town.model.climb_axis = axis
		town.model.step(1.0/60,0,false)
		town._update_view(1.0/60)
		check(town.model.climbing,"simulation engages ladder")
		check(town.avatar.current_motion == &"climb","moving on ladder plays climb animation")
	town.model.position = Vector2(800,480)
	town.model.climb_axis = 0
	town.model.step(1.0/60,1,false)
	town._update_view(1.0/60)
	check(town.avatar.current_motion == &"run","leaving ladder restores running animation")
	if not failed: print("PASS: ladder ascent/descent animate and leaving restores running")
	town.free()
	quit(1 if failed else 0)
