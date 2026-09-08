extends Control
## Visual reference for every state, using the exact styles shipped in game.
const Chronicle = preload("res://src/ui/chronicle_theme.gd")

func _draw() -> void:
	draw_rect(Rect2(0,0,1152,648),Chronicle.NAVY)
	var display := theme.get_font("font","ChronicleHeading")
	var body := theme.default_font
	draw_string(display,Vector2(30,48),"THE CHRONICLE UI · SHARED ELEMENTS",0,-1,28,Chronicle.GOLD)
	var states := ["normal","hover","pressed","focus","disabled"]
	for col in states.size():
		draw_string(body,Vector2(210+col*185,100),states[col].capitalize(),0,-1,15,Chronicle.PARCHMENT)
	for row in 5:
		var type: String = ["PrimaryButton","Button","QuietButton","DangerButton","ToggleButton"][row]
		var label: String = ["Accept Quest","Trade","Tell me about the ruins.","Decline","ON"][row]
		draw_string(display,Vector2(30,150+row*63),["Primary","Secondary","Quiet","Danger","Toggle"][row],0,-1,18,Chronicle.PARCHMENT)
		for col in states.size():
			var rect := Rect2(185+col*185,120+row*63,171,43)
			var state: String = states[col]
			draw_style_box(theme.get_stylebox("normal" if state == "focus" else state,type),rect)
			if state == "focus": draw_style_box(theme.get_stylebox("focus",type),rect)
			var font_size := 12 if row == 2 else 16
			var width := display.get_string_size(label,0,-1,font_size).x
			draw_string(display,rect.get_center()+Vector2(-width/2,5),label,0,-1,font_size,theme.get_color("font_disabled_color" if state == "disabled" else "font_color",type))
	draw_style_box(theme.get_stylebox("panel","ParchmentPanel"),Rect2(28,457,535,162))
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(584,457,535,162))
	draw_string(display,Vector2(68,495),"Parchment panel",0,-1,23,Color("302a21"))
	draw_string(body,Vector2(68,530),"Shared tokens · notched brass · botanical corners",0,-1,16,Color("302a21"))
	draw_string(display,Vector2(618,495),"Ink panel",0,-1,23,Chronicle.GOLD)
	draw_string(body,Vector2(618,530),"One theme for inventory, combat and future menus.",0,-1,16,Chronicle.IVORY)
	for i in 7:
		var color: Color = [Chronicle.NAVY,Chronicle.BLUE,Chronicle.TEAL,Chronicle.CYAN,Chronicle.GOLD,Chronicle.BRASS,Chronicle.EMBER][i]
		draw_circle(Vector2(83+i*63,574),14,color)
