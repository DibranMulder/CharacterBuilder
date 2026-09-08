extends SceneTree
const Clearing = preload("res://prototypes/training_clearing/training_clearing.tscn")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var scene = Clearing.instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	assert(scene.notice.text.is_empty())
	assert(not scene.builder_button.visible and not scene.restart_button.visible)
	assert(scene.hud.text == "0 coins")
	for node in scene.get_children():
		if node is Label:
			assert(not "Practice:" in node.text and not "Your exact" in node.text and not "DEFEATED" in node.text)
	scene._toggle_pause()
	scene._update_view(0)
	assert(scene.notice.text == "Paused")
	assert(scene.builder_button.visible and scene.restart_button.visible)
	scene._toggle_pause()
	scene.model.health = 0
	scene.model.death_time = 1
	scene._update_view(0)
	assert("Recovering" in scene.notice.text)
	scene._toggle_inventory()
	assert(scene.inventory_panel.message.text.is_empty())
	assert(scene.inventory_panel.detail.text.is_empty())
	assert(not scene.inventory_panel.action.visible)
	scene.inventory_panel.select_tile(scene.inventory_panel.tiles[0])
	assert("Restores" in scene.inventory_panel.detail.text, "actual item information remains")
	scene.free()
	print("PASS: clean HUD, contextual pause controls, recovery status and hint-free pouch")
	quit()
