extends SceneTree
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func _run() -> void:
	var scene = load("res://prototypes/human_hometown/market_row.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene.model.position.x = 800
	scene._update_view(0)
	check(scene.merchant_markers.size() == 3,"all three actual services are marked")
	check(scene.merchant_markers[0].kind == "trade","working trader uses coin-pouch marker")
	check(scene.merchant_markers[0].visible and not scene.merchant_markers[0].ready_to_use,"distant services are discoverable but not actionable")
	scene.model.position.x = 500
	scene._update_view(0)
	check(scene.merchant_markers[0].ready_to_use and scene.talk_button.visible,"nearby usable service shows action")
	scene.model.grounded = false
	scene._update_view(0)
	check(not scene.merchant_markers[0].ready_to_use and not scene.talk_button.visible,"airborne hero gets no false action promise")
	scene.model.grounded = true
	scene._update_view(0)
	scene._talk_to_rowan()
	check(not scene.merchant_markers[0].visible and not scene.exit_markers[0].visible,"world signs hide during dialogue")
	scene._close_rowan()
	scene.model.position.x = 2250
	scene._update_view(0)
	check(scene.exit_markers[0].ready_to_use and "Village Square" in scene.exit_markers[0].cached_text,"exit names its real destination")
	for i in 5: await process_frame
	var redraws := [0]
	var changes := [0]
	for marker in scene.merchant_markers+scene.exit_markers:
		marker.draw.connect(func(): redraws[0] += 1)
		marker.visibility_changed.connect(func(): changes[0] += 1)
	for i in 30:
		scene._update_view(0)
		await process_frame
	check(redraws[0] == 0 and changes[0] == 0,"unchanged signs cause no redraw or visibility churn")
	scene.free()
	var town = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	root.add_child(town)
	town.set_physics_process(false)
	town._update_view(0)
	check(town.merchant_markers[0].kind == "quest_active","current quest giver has a bright quest marker")
	check(town.merchant_markers[1].kind == "talk","broker without working trade stays a conversation")
	town.quest_stage = 1
	town._update_view(0)
	check(town.merchant_markers[0].kind == "quest","later quest contact keeps a subdued quest marker")
	town.quest_stage = 5
	town._update_view(0)
	check(town.merchant_markers[0].kind == "talk","finished story does not promise another quest")
	town.free()
	if not failed: print("PASS: service discovery, legal action prompts, menu visibility, exit destination and retained marker rendering")
	quit(1 if failed else 0)
