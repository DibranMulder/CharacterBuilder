extends Button
## Shared illustrated ability tile: hotbar, overview and details use one renderer.
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var skill := {}
var hotkey := ""
var cooldown := 0.0
var cooldown_max := 1.0
var mana_available := true
var icon_edge := 48.0
var selected := false
var locked := false
var icon_atlas: Texture2D
const REGIONS := [Rect2(62,36,289,275),Rect2(437,36,290,275),Rect2(807,36,292,275),Rect2(1184,36,290,275),Rect2(62,366,289,267),Rect2(437,366,290,267),Rect2(807,366,292,267),Rect2(1184,366,290,267),Rect2(62,680,289,271),Rect2(437,680,290,271),Rect2(807,680,292,271),Rect2(1184,680,290,271)]
const ICONS := {"melee":0,"bolt":1,"rootbolt":2,"heal":3,"ward":4,"dash":5,"retreat":6,"slowbolt":7,"drain":8,"water":9,"pulse":10}

func _ready() -> void:
	theme = Chronicle.create()
	for state in ["normal","hover","pressed","disabled","focus"]:
		add_theme_stylebox_override(state,StyleBoxEmpty.new())
	focus_mode = Control.FOCUS_NONE
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	pressed.connect(queue_redraw)
	# Kept optional so tools can import the scene before generated art is imported.
	if ResourceLoader.exists("res://assets/ui/skill_icons.png"):
		icon_atlas = load("res://assets/ui/skill_icons.png")

func configure(value: Dictionary, key := "") -> void:
	skill = value
	hotkey = key
	tooltip_text = "%s\n%s\n%d mana · %.1fs cooldown · %.2fs windup"%[skill.name,skill.description,skill.mana,skill.cooldown,skill.windup]
	queue_redraw()

func _caption(value: String, point: Vector2, font_size: int, color: Color) -> void:
	var font: Font = Chronicle.create().default_font
	var x := font.get_string_size(value,0,-1,font_size).x
	draw_string_outline(font,point-Vector2(x*.5,0),value,0,-1,font_size,3,Chronicle.NAVY)
	draw_string(font,point-Vector2(x*.5,0),value,0,-1,font_size,color)

func _draw() -> void:
	var square := Rect2(0,0,icon_edge,icon_edge)
	draw_style_box(Chronicle.create().get_stylebox("panel","InkPanel"),square)
	if icon_atlas and not skill.is_empty():
		var index: int = ICONS.get(skill.kind,11)
		var region: Rect2 = REGIONS[index]
		draw_texture_rect_region(icon_atlas,square.grow(-4),region,Color(1,1,1,.4 if disabled else 1))
	if locked:
		draw_rect(square.grow(-4),Color(.02,.05,.08,.65))
		var center := square.get_center()
		draw_arc(center-Vector2(0,3),6,PI,TAU,12,Chronicle.GOLD,2,true)
		draw_rect(Rect2(center+Vector2(-7,-3),Vector2(14,12)),Chronicle.GOLD)
		draw_circle(center+Vector2(0,1),2,Chronicle.NAVY)
	elif cooldown > 0:
		var shade := square.grow(-4)
		shade.size.y *= clampf(cooldown/maxf(.1,cooldown_max),0,1)
		draw_rect(shade,Color(.02,.05,.08,.8))
		_caption("%.1f"%cooldown,Vector2(icon_edge*.5,icon_edge*.6),17,Chronicle.IVORY)
	elif not mana_available:
		draw_rect(square.grow(-4),Color(.08,.12,.24,.4))
	if selected or is_hovered():
		draw_style_box(Chronicle.create().get_stylebox("focus","Button"),square)
	if not hotkey.is_empty():
		var badge_width := maxf(20,Chronicle.create().default_font.get_string_size(hotkey,0,-1,12).x+10)
		var badge := Rect2((icon_edge-badge_width)*.5,icon_edge+3,badge_width,18)
		var key_frame := StyleBoxFlat.new()
		key_frame.bg_color = Chronicle.NAVY
		key_frame.border_color = Chronicle.BRASS
		key_frame.set_border_width_all(1)
		key_frame.set_corner_radius_all(2)
		draw_style_box(key_frame,badge)
		_caption(hotkey,Vector2(icon_edge*.5,icon_edge+16),12,Chronicle.GOLD)
	if not skill.is_empty():
		_caption(str(int(skill.mana)),Vector2(icon_edge-12,icon_edge-7),10,Chronicle.CYAN if mana_available else Color("ff987f"))
