extends RefCounted
## Fixed action keys with persistent, per-lineage action assignments.
const PATH := "user://action_bindings.cfg"
const KEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_H, KEY_P]
const LABELS := ["1", "2", "3", "4", "5", "6", "H", "P"]
const DEFAULTS := ["attack", "guard", "skill:0", "skill:1", "skill:2", "skill:3", "hp", "mana"]
var assignments: Array = DEFAULTS.duplicate()
var lineage := "human"
var path := PATH

func load_for(value: String) -> void:
	lineage = value
	assignments = DEFAULTS.duplicate()
	var config := ConfigFile.new()
	if config.load(path) != OK: return
	for i in KEYS.size():
		var action = config.get_value(lineage, LABELS[i], DEFAULTS[i])
		if action is String and valid_action(action): assignments[i] = action

func valid_action(action: String) -> bool:
	return action in ["", "attack", "guard", "hp", "mana", "skill:0", "skill:1", "skill:2", "skill:3", "skill:4", "skill:5"]

func assign(slot: int, action: String) -> Error:
	if slot < 0 or slot >= KEYS.size() or not valid_action(action): return ERR_INVALID_PARAMETER
	assignments[slot] = action
	return save()

func save() -> Error:
	var config := ConfigFile.new()
	config.load(path)
	for i in KEYS.size(): config.set_value(lineage, LABELS[i], assignments[i])
	return config.save(path)

func reset() -> Error:
	assignments = DEFAULTS.duplicate()
	return save()

func action_for(key: int) -> String:
	var slot := KEYS.find(key)
	return assignments[slot] if slot >= 0 else ""

func held(action: String) -> bool:
	for i in KEYS.size():
		if assignments[i] == action and Input.is_physical_key_pressed(KEYS[i]): return true
	return false

func label_for(action: String) -> String:
	var labels: Array[String] = []
	for i in KEYS.size():
		if assignments[i] == action: labels.append(LABELS[i])
	# Existing secondary shortcuts remain available.
	if action == "skill:4": labels.append("7")
	if action == "skill:5": labels.append("8")
	return "/".join(labels)
