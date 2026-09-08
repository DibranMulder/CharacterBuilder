extends SceneTree
const Chronicle = preload("res://src/ui/chronicle_theme.gd")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var theme := Chronicle.create()
	assert(theme == Chronicle.create(), "screens reuse the same theme")
	for variation in ["Button","PrimaryButton","QuietButton","DangerButton","ToggleButton"]:
		for state in ["normal","hover","pressed","hover_pressed","disabled","focus"]:
			assert(theme.has_stylebox(state,variation))
		assert(theme.get_stylebox("focus",variation).focus_only)
		assert(theme.get_stylebox("disabled",variation).disabled)
	assert(theme.get_stylebox("pressed","ToggleButton").fill == Chronicle.TEAL)
	var parent := Control.new()
	parent.theme = theme
	root.add_child(parent)
	var button := Button.new()
	button.theme_type_variation = "PrimaryButton"
	parent.add_child(button)
	assert(button.get_theme_stylebox("normal") == theme.get_stylebox("normal","PrimaryButton"))
	var panel := Panel.new()
	panel.theme_type_variation = "ParchmentPanel"
	parent.add_child(panel)
	assert(panel.get_theme_stylebox("panel").parchment)
	parent.free()
	print("PASS: shared UI inheritance, semantic button variants, disabled/focus states and panels")
	quit()
