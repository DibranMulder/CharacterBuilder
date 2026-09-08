extends SceneTree

const Builder := preload("res://main.tscn")
const LINEAGE_NAMES := {
	"bogkin": "Tidekin", "human": "Humans", "centaur": "Grove Centaurs",
	"fae": "Aeralith", "frost_troll": "Crag Trolls", "goblin": "Deep Goblins",
	"duneborn": "Sunscour", "frostling": "Rimeborn",
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var builder := Builder.instantiate()
	root.add_child(builder)
	await process_frame
	await process_frame
	if builder.avatar.race_id != "human" or builder.race_ids[builder.race_selector.selected] != "human":
		_fail("builder must open with Human selected in both the avatar and race control")
		return
	var builder_panel: PanelContainer = builder.get_node("BuilderPanel")
	var gesture_box: HBoxContainer = builder.gesture_box
	var content_bottom := gesture_box.global_position.y+gesture_box.size.y
	var safe_panel_bottom := builder_panel.global_position.y+builder_panel.size.y-8.0
	if content_bottom > safe_panel_bottom:
		_fail("race gesture controls extend below the builder panel")
		return
	if builder.gear_selectors.size() != CharacterCatalog.SLOT_ORDER.size():
		_fail("builder UI does not expose every modular equipment slot")
		return
	for slot in CharacterCatalog.SLOT_ORDER:
		var selector: OptionButton = builder.gear_selectors[slot]
		if selector.item_count != CharacterCatalog.items_for(slot).size():
			_fail("builder UI does not enumerate every %s item" % slot)
			return
	var offhand_selector: OptionButton = builder.gear_selectors[&"offhand"]
	var offhand_labels: Array[String] = []
	for item_index in offhand_selector.item_count:
		offhand_labels.append(offhand_selector.get_item_text(item_index))
	for shield_label in ["Shield","Marsh Shield","Dune Shield"]:
		if shield_label not in offhand_labels:
			_fail("builder offhand selector is missing %s" % shield_label)
			return
	if builder.avatar.loadout != CharacterCatalog.reference_loadout(builder.avatar.race_id):
		_fail("builder does not open with the selected lineage's reference kit")
		return
	for race_index in builder.race_ids.size():
		builder._select_race(race_index)
		var lineage_id: String = builder.race_ids[race_index]
		var expected_name: String = LINEAGE_NAMES[lineage_id]
		if CharacterCatalog.race(lineage_id).name != expected_name or builder.race_selector.get_item_text(race_index) != expected_name or builder.title_label.text != expected_name:
			_fail("lineage catalog, selector and title must use %s" % expected_name)
			return
		if builder.avatar.loadout != CharacterCatalog.reference_loadout(builder.race_ids[race_index]):
			_fail("selecting %s did not apply its complete reference kit" % builder.race_ids[race_index])
			return
	var motion_labels: Array[String] = []
	for child in builder.get_node("MotionPanel").find_children("*","Button",true,false):
		motion_labels.append(child.text)
	for required_label in ["Idle","Stand","Run","Stairs","Ladder","Jump","Left","Right"]:
		if required_label not in motion_labels:
			_fail("builder motion panel is missing %s" % required_label)
			return
	builder.avatar.play_motion(&"stairs")
	if not builder.staircase.visible or builder.ladder.visible:
		_fail("stairs motion must show only the staircase preview")
		return
	builder.avatar.play_motion(&"climb")
	if not builder.ladder.visible or builder.staircase.visible:
		_fail("ladder climb must show only the ladder preview")
		return
	builder.avatar.stop_motion()
	if builder.ladder.visible or builder.staircase.visible:
		_fail("idle must clear both climbing previews")
		return
	print("PASS: all builder controls fit and stair/ladder previews switch exclusively")
	quit()


func _fail(message: String) -> void:
	printerr("FAIL: ",message)
	quit(1)
