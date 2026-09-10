extends Control
## Painted item tile, shared by the pouch and equipment destinations.
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var chronicle_theme: Theme
var empty_frame: StyleBox
var owner_panel: Control
var item := {"id":"none", "slot":""}
var bag_index := -1
var equipment_slot := ""
var count := 0
var selected := false
var compatible := false
var locked := false
var hovered := false
var drag_enabled := true
var price := 0
static var textures := {}
static var regions := {}
const ART := {
	"sword":"sword", "axe":"axe", "spear":"spear", "bow":"bow", "crossbow":"crossbow_storybook_v2",
	"staff":"staff", "branch_staff":"branch_staff_storybook_v1", "shield":"shield_exterior",
	"marsh_shield":"marsh_shield_exterior", "dune_shield":"dune_shield_exterior", "lantern":"lantern", "spellbook":"spellbook",
	"hood":"hood", "helm":"helm", "crown":"crown", "balaclava":"balaclava",
	"cape":"cape", "long_cape":"long_cape_storybook_v3", "pack":"pack", "quiver":"quiver",
	"scarf":"scarf", "amulet":"amulet", "goggles":"goggles", "marsh_tunic":"marsh_tunic",
	"woodland_harness":"woodland_harness", "troll_jerkin":"troll_jerkin", "fur_coat":"fur_coat", "fae_tunic":"fae_tunic",
	"lamellar":"lamellar_armor", "plate":"plate_armor", "leather":"leather_armor", "cloth":"cloth_armor_storybook_v3",
}

static func art_for(data: Dictionary) -> Texture2D:
	var id: String = data.id
	var slot: String = data.slot
	var stem: String = ART.get(id, "")
	if slot == "pants":
		stem = ("cloth" if id in ["cloth","ranger","baggy"] else id) + "_pants_thigh"
	elif slot == "boots":
		stem = id + "_boot"
	if stem.is_empty() or id == "none":
		return null
	var path := "res://assets/equipment/" + stem + ("" if "storybook" in stem else "_storybook") + ".png"
	if not textures.has(path):
		textures[path] = load(path) if ResourceLoader.exists(path) else null
		if textures[path] != null:
			regions[path] = textures[path].get_image().get_used_rect()
	return textures[path]

func _ready() -> void:
	chronicle_theme = Chronicle.create()
	empty_frame = chronicle_theme.get_stylebox("panel","ParchmentPanel").duplicate()
	empty_frame.set("parchment",false)
	var keyed := ShaderMaterial.new()
	keyed.shader = preload("res://prototypes/training_clearing/pouch_art.gdshader")
	material = keyed
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(func(): hovered = true; queue_redraw())
	mouse_exited.connect(func(): hovered = false; queue_redraw())
	tooltip_text = (equipment_slot.capitalize() + ": " if not equipment_slot.is_empty() else "") + String(item.id).capitalize()

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER,KEY_SPACE]):
		owner_panel.select_tile(self)
		accept_event()

func _get_drag_data(_at: Vector2) -> Variant:
	if not drag_enabled or item.id == "none" or item.slot == "potion" or locked:
		return null
	owner_panel.select_tile(self)
	var data := {"panel":owner_panel, "index":bag_index, "slot":equipment_slot, "item":item.duplicate()}
	owner_panel.highlight_targets(data)
	var preview := Control.new()
	var tile = get_script().new()
	tile.item = item.duplicate()
	tile.size = size
	tile.position = -size * .5
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_child(tile)
	set_drag_preview(preview)
	return data

func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return owner_panel != null and owner_panel.can_drop_on(self, data)

func _drop_data(_at: Vector2, data: Variant) -> void:
	owner_panel.drop_on(self, data)

func _draw() -> void:
	var dark: bool = not equipment_slot.is_empty() or item.id != "none"
	var edge := Color("72d6e5") if compatible else (Color("f2c45f") if selected or hovered else Color("a98b53"))
	var rect := Rect2(Vector2.ONE * 2, size - Vector2.ONE * 4)
	draw_style_box(chronicle_theme.get_stylebox("panel","InkPanel") if dark else empty_frame,rect)
	if selected or hovered or compatible:
		draw_rect(rect.grow(-3),edge,false,2)
	var texture := art_for(item)
	var area := Rect2(9,7,size.x-18,size.y-24 if not equipment_slot.is_empty() else size.y-14)
	if texture != null:
		var region: Rect2 = regions[texture.resource_path]
		var factor := minf(area.size.x / region.size.x, area.size.y / region.size.y)
		var dimensions := region.size * factor
		draw_texture_rect_region(texture, Rect2(area.get_center()-dimensions*.5, dimensions), region, Color(1,1,1,.35 if locked else 1))
	elif item.id == "balaclava":
		var center := area.get_center()
		draw_circle(center-Vector2(0,5),17,Color("815640"))
		draw_rect(Rect2(center+Vector2(-17,-5),Vector2(34,24)),Color("815640"))
		draw_line(center+Vector2(-12,-6),center+Vector2(12,-6),Color("101b2c"),6,true)
		draw_arc(center-Vector2(0,5),17,PI,TAU,20,Color("c5a272"),2,true)
	elif item.slot == "potion":
		var center := area.get_center()
		draw_circle(center + Vector2(0,4), 15, Color("17262c"))
		draw_circle(center + Vector2(0,4), 12, Color("c66349") if item.id == "hp" else Color("4ba1c7"))
		draw_rect(Rect2(center + Vector2(-5,-17),Vector2(10,14)), Color("8cc8cd"))
		draw_rect(Rect2(center + Vector2(-7,-20),Vector2(14,6)), Color("b58a49"))
		draw_arc(center+Vector2(0,4),10,3.4,4.5,10,Color("fff5d6"),2,true)
	else:
		var center := area.get_center()
		for ray in 8:
			var axis := Vector2.from_angle(ray * TAU / 8)
			draw_line(center+axis*4,center+axis*12,Color("ad9568"),1,true)
	var font := ThemeDB.fallback_font
	if not equipment_slot.is_empty():
		var label: String = {"weapon":"MAIN HAND","offhand":"OFF HAND","armor":"CHEST","back":"BACK","accessory":"CHARM"}.get(equipment_slot,equipment_slot.to_upper())
		if locked:
			label = "LOCKED"
		var width := font.get_string_size(label,0,-1,10).x
		draw_string(font,Vector2((size.x-width)/2,size.y-8),label,0,-1,10,Color("fff5d6"))
	if count > 0:
		draw_circle(size-Vector2(12,13),11,Color("101b2c"))
		draw_string(font,size-Vector2(17,8),str(count),0,-1,13,Color("fff5d6"))
	if price > 0:
		draw_rect(Rect2(5,size.y-18,size.x-10,14),Color("101b2c"))
		draw_circle(Vector2(13,size.y-11),3,Color("f2c45f"))
		draw_string(font,Vector2(20,size.y-7),str(price),0,-1,11,Color("fff5d6"))
