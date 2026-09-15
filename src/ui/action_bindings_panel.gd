extends Panel
signal closed
signal changed
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var bindings
var kit: Array = []
var progression
var selectors: Array[OptionButton] = []
var actions: Array[String] = ["", "attack", "guard", "hp", "mana"]
var status: Label

func _ready() -> void:
	theme = Chronicle.create()
	add_theme_stylebox_override("panel",theme.get_stylebox("panel","InkPanel"))
	position = Vector2(236,88)
	size = Vector2(680,520)
	z_index = 450
	mouse_filter = Control.MOUSE_FILTER_STOP
	var title := Label.new()
	title.text = "ACTION BINDINGS"
	title.position = Vector2(24,16)
	title.add_theme_font_size_override("font_size",24)
	add_child(title)
	var help := Label.new()
	help.text = "Choose an action for each key. Changes save automatically."
	help.position = Vector2(24,52)
	add_child(help)
	var names: Array[String] = ["Unassigned", "Basic attack", "Guard (hold)", "Health potion", "Mana potion"]
	for i in kit.size():
		actions.append("skill:%d" % i)
		names.append(kit[i].name + (" (locked)" if progression != null and not progression.allows(kit[i]) else ""))
	for i in bindings.KEYS.size():
		var label := Label.new()
		label.position = Vector2(30,94+i*41)
		label.text = "Key " + bindings.LABELS[i]
		add_child(label)
		var selector := OptionButton.new()
		selector.position = Vector2(130,88+i*41)
		selector.size = Vector2(518,36)
		for value in names: selector.add_item(value)
		selector.select(actions.find(bindings.assignments[i]))
		selector.item_selected.connect(func(index):
			_report(bindings.assign(i,actions[index]))
		)
		add_child(selector)
		selectors.append(selector)
	status = Label.new()
	status.position = Vector2(24,423)
	status.text = "Locked skills still require training. J: attack · Shift: guard · 7/8: shared skills"
	status.add_theme_font_size_override("font_size",13)
	add_child(status)
	var reset := Button.new()
	reset.text = "Reset defaults"
	reset.position = Vector2(24,466)
	reset.size = Vector2(180,36)
	reset.pressed.connect(func():
		_report(bindings.reset())
		for i in selectors.size(): selectors[i].select(actions.find(bindings.assignments[i]))
	)
	add_child(reset)
	var close := Button.new()
	close.text = "Done · Esc"
	close.position = Vector2(468,466)
	close.size = Vector2(180,36)
	close.pressed.connect(func(): closed.emit())
	add_child(close)

func _report(error: Error) -> void:
	status.text = "Saved" if error == OK else "Applied for this session; could not save bindings."
	changed.emit()
