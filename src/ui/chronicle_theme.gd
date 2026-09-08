extends RefCounted
## Public UI seam: attach create() to any Control; choose semantic variations.
const Frame = preload("res://src/ui/chronicle_frame.gd")
const NAVY := Color("101b2c")
const BLUE := Color("183454")
const TEAL := Color("2d756e")
const CYAN := Color("72d6e5")
const GOLD := Color("f2c45f")
const PARCHMENT := Color("f3e5be")
const IVORY := Color("fff5d6")
const BRASS := Color("c79b48")
const EMBER := Color("b85645")
static var _shared: Theme

static func create() -> Theme:
	if _shared != null:
		return _shared
	var theme := Theme.new()
	var body := SystemFont.new()
	body.font_names = PackedStringArray(["Alegreya Sans","Helvetica","sans-serif"])
	var display := SystemFont.new()
	display.font_names = PackedStringArray(["Alegreya SC","Georgia","serif"])
	theme.default_font = body
	theme.default_font_size = 15
	theme.set_color("font_color","Label",IVORY)
	theme.set_type_variation("ChronicleHeading","Label")
	theme.set_font("font","ChronicleHeading",display)
	theme.set_color("font_color","ChronicleHeading",GOLD)
	theme.set_font_size("font_size","ChronicleHeading",24)
	for type in ["Button","PrimaryButton","QuietButton","DangerButton","ToggleButton"]:
		if type != "Button":
			theme.set_type_variation(type,"Button")
		var base: Color = {"PrimaryButton":Color("967023"),"DangerButton":Color("793825"),"QuietButton":NAVY}.get(type,BLUE)
		for state in ["normal","hover","pressed","hover_pressed","disabled","focus"]:
			var frame = Frame.new()
			frame.fill = base
			frame.border = BRASS
			if type == "QuietButton" and state == "normal": frame.border = Color("87744f")
			frame.pressed = state in ["pressed","hover_pressed"]
			if state == "hover": frame.fill = base.lightened(.12)
			if frame.pressed: frame.fill = TEAL if type == "ToggleButton" else base.darkened(.25)
			if state == "disabled":
				frame.fill = Color("354249")
				frame.border = Color("756b51")
				frame.disabled = true
			frame.focus_only = state == "focus"
			frame.content_margin_left = 12
			frame.content_margin_right = 12
			frame.content_margin_top = 6
			frame.content_margin_bottom = 6
			theme.set_stylebox(state,type,frame)
		for color in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_hover_pressed_color"]:
			theme.set_color(color,type,IVORY)
		theme.set_color("font_disabled_color",type,Color("93958c"))
		theme.set_color("font_outline_color",type,NAVY)
		theme.set_constant("outline_size",type,1)
		theme.set_font("font",type,display)
		theme.set_font_size("font_size",type,15)
	for type in ["InkPanel","ParchmentPanel"]:
		theme.set_type_variation(type,"Panel")
		var frame = Frame.new()
		frame.parchment = type == "ParchmentPanel"
		frame.fill = PARCHMENT if frame.parchment else NAVY
		frame.border = BRASS
		theme.set_stylebox("panel",type,frame)
	_shared = theme
	return theme
