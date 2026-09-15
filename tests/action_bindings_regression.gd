extends SceneTree
var failed := false
const Bindings = preload("res://src/action_bindings.gd")
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: " + message)
func key(scene: Node, code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	scene._unhandled_key_input(event)
func _run() -> void:
	var bindings = Bindings.new()
	bindings.path = "/tmp/character-bindings-regression.cfg"
	bindings.load_for("human")
	bindings.reset()
	check(bindings.assign(0,"hp") == OK,"save assignment")
	bindings.assign(6,"skill:0")
	var restored = Bindings.new()
	restored.path = bindings.path
	restored.load_for("human")
	check(restored.action_for(KEY_1) == "hp" and restored.action_for(KEY_H) == "skill:0","reload keys")
	restored.load_for("tidekin")
	check(restored.action_for(KEY_1) == "attack","lineage layouts are independent")
	check(bindings.assign(0,"skill:99") == ERR_INVALID_PARAMETER and bindings.action_for(KEY_1) == "hp","invalid action rejected")
	for scene_path in ["res://prototypes/training_clearing/training_clearing.tscn", "res://prototypes/human_hometown/human_hometown.tscn", "res://prototypes/tidekin_sea/tidekin_sea.tscn"]:
		var scene = load(scene_path).instantiate()
		root.add_child(scene)
		scene.set_physics_process(false)
		scene.bindings = bindings
		scene.paused = false
		scene.model.health = 40
		scene.model.mana = 40
		var hp: int = scene.model.inventory.potions.hp
		key(scene,KEY_1)
		check(scene.model.inventory.potions.hp == hp-1 and scene.model.attack_time == 0,"number key uses potion instead of attack: " + scene_path)
		key(scene,KEY_1)
		check(scene.model.inventory.potions.hp == hp-1,"cooldown prevents duplicate consumption")
		scene.model.potion_cooldown = 0
		bindings.assign(1,"mana")
		var mana: int = scene.model.inventory.potions.mana
		key(scene,KEY_2)
		check(scene.model.inventory.potions.mana == mana-1,"key 2 can use a potion")
		key(scene,KEY_B)
		check(scene.paused and is_instance_valid(scene.bindings_panel),"bindings menu pauses")
		key(scene,KEY_M)
		check(not is_instance_valid(scene.map_panel),"bindings menu isolates map input")
		key(scene,KEY_1)
		check(scene.model.inventory.potions.hp == hp-1,"bindings menu blocks gameplay")
		var selector: OptionButton = scene.bindings_panel.selectors[0]
		selector.item_selected.emit(scene.bindings_panel.actions.find("skill:0"))
		check(bindings.action_for(KEY_1) == "skill:0","dropdown applies assignment")
		key(scene,KEY_ESCAPE)
		check(not scene.paused and not is_instance_valid(scene.bindings_panel),"close restores play")
		scene._update_view(0)
		check("1" in scene.skill_buttons[0].hotkey,"skill badge reflects binding")
		scene._toggle_pause()
		key(scene,KEY_B)
		key(scene,KEY_ESCAPE)
		check(scene.paused,"close preserves prior pause")
		scene.paused = false
		scene.model.attack_time = 0
		scene.model.guarding = false
		scene.model.lineage_cooldowns[0] = 0
		scene.model.mana = 100
		key(scene,KEY_1)
		check(scene.model.attack_kind == "lineage" and scene.model.attack_time > 0,"remapped skill activates")
		bindings.assign(0,"hp")
		scene.queue_free()
		await process_frame
	DirAccess.remove_absolute(bindings.path)
	if not failed: print("PASS: persistent bindings, dropdown changes, potions, skills and modal input across gameplay scenes")
	quit(1 if failed else 0)
