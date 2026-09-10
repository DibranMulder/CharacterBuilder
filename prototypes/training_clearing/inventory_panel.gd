extends Panel
signal equipment_changed
signal closed
signal skills_requested
signal disciplines_requested
const Tile = preload("res://prototypes/training_clearing/pouch_slot.gd")
const Preview = preload("res://prototypes/training_clearing/vanguard_visual.gd")
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var model
var preview: Node2D
var heading: Label
var detail: Label
var message: Label
var item_title: Label
var stats: Label
var action: Button
var tiles: Array[Control] = []
var selected_index := -1
var selected_slot := ""
var selected_potion := ""
var filter := "All"
var page := 0
var filter_buttons: Dictionary = {}
var serif := SystemFont.new()
const GOLD := Color("c79b48")
const INK := Color("302a21")

func _ready() -> void:
	position = Vector2.ZERO
	size = Vector2(1152,648)
	z_index = 300
	theme = Chronicle.create()
	var keyed := ShaderMaterial.new()
	keyed.shader = preload("res://prototypes/training_clearing/pouch_art.gdshader")
	material = keyed
	serif = theme.get_font("font","ChronicleHeading")
	var background := StyleBoxFlat.new()
	background.bg_color = Color("101b2c")
	add_theme_stylebox_override("panel", background)
	preload("res://src/ui/chronicle_menu_header.gd").install(self,"pouch","I",func(): closed.emit(),func(): pass,func(): skills_requested.emit(),true,func(): disciplines_requested.emit())
	_label("ITEM POUCH",Vector2(120,98),23,true,INK)
	_label("GEAR OVERVIEW",Vector2(501,98),23,true,INK)
	heading = _label("",Vector2(35,132),12,false,INK)
	item_title = _label("Your equipment",Vector2(861,103),23,true,Color("f2c45f"))
	item_title.size.x = 255
	item_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail = _label("",Vector2(862,247),14,false,Color("f3e5be"))
	detail.size = Vector2(249,64)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats = _label("",Vector2(862,335),16,false,Color("f3e5be"))
	message = _label("",Vector2(33,613),13,false,Color("f3e5be"))
	action = _button("Select an item",Vector2(863,540),Vector2(250,36),_activate)
	action.theme_type_variation = "PrimaryButton"
	for i in 3:
		var category: String = ["All","Gear","Potions"][i]
		var tab := _button(category,Vector2(32+i*91,535),Vector2(85,32),func(): filter=category; page=0; refresh())
		tab.theme_type_variation = "ToggleButton"
		tab.toggle_mode = true
		filter_buttons[category] = tab
	_button("Sort",Vector2(310,535),Vector2(75,32),_sort)
	_button("‹",Vector2(32,573),Vector2(34,25),func(): page=maxi(0,page-1); refresh())
	_button("›",Vector2(351,573),Vector2(34,25),func(): page+=1; refresh())
	preview = Preview.new()
	preview.z_index = 100
	add_child(preview)
	preview.position = Vector2(619,485)
	preview.scale = Vector2.ONE * (.7 if model.inventory.lineage == "centaur" else 1.15)
	if model.inventory.lineage == "frost_troll":
		preview.scale = Vector2.ONE * .9
	preview.process_mode = Node.PROCESS_MODE_DISABLED
	refresh()

func _label(value: String, at: Vector2, font_size: int, fancy := false, color := Color("fff5d6")) -> Label:
	var label := Label.new()
	add_child(label)
	label.position = at
	label.text = value
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	if fancy:
		label.add_theme_font_override("font",serif)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(title: String, at: Vector2, dimensions: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	add_child(button)
	button.position = at
	button.size = dimensions
	button.text = title
	button.pressed.connect(callback)
	return button

func refresh() -> void:
	for category in filter_buttons:
		filter_buttons[category].set_pressed_no_signal(category == filter)
	for tile in tiles:
		remove_child(tile)
		tile.queue_free()
	tiles.clear()
	var entries: Array[Dictionary] = []
	if filter != "Potions":
		for index in model.inventory.items.size():
			entries.append({"item":model.inventory.items[index],"index":index,"count":0})
	if filter != "Gear":
		for kind in ["hp","mana"]:
			if model.inventory.potions[kind] > 0:
				entries.append({"item":{"id":kind,"slot":"potion"},"index":-1,"count":model.inventory.potions[kind]})
	page = clampi(page,0,maxi(0,(entries.size()-1)/24))
	heading.text = "%d items  ·  %d coins  ·  %s  ·  Page %d" % [entries.size(),model.inventory.coins,filter,page+1]
	for cell in 24:
		var tile = Tile.new()
		tile.position = Vector2(32+(cell%6)*59,163+(cell/6)*86)
		tile.size = Vector2(56,77)
		var index := page*24+cell
		if index < entries.size():
			tile.item = entries[index].item.duplicate()
			tile.bag_index = entries[index].index
			tile.count = entries[index].count
		_add_tile(tile)
	var positions := {"head":Vector2(586,137),"armor":Vector2(431,254),"weapon":Vector2(431,376),
		"accessory":Vector2(742,137),"back":Vector2(742,254),"offhand":Vector2(742,376),"pants":Vector2(536,497),"boots":Vector2(645,497)}
	for slot in CharacterCatalog.SLOT_ORDER:
		var tile = Tile.new()
		tile.position = positions[String(slot)]
		tile.size = Vector2(77,91)
		tile.equipment_slot = slot
		tile.item = {"slot":String(slot),"id":model.inventory.equipped.get(slot,"none")}
		tile.locked = model.inventory.lineage == "centaur" and slot in [&"pants",&"boots"]
		_add_tile(tile)
	preview.configure(model.inventory.lineage,model.inventory.equipped.duplicate())
	preview.stop_motion()
	selected_index = -1
	selected_slot = ""
	selected_potion = ""
	item_title.text = "Your equipment"
	detail.text = ""
	stats.text = "HEALTH     %d / 100\n\nMANA         %d / 100\n\nCOINS         %d" % [model.health,model.mana,model.inventory.coins]
	action.text = "Select an item"
	action.disabled = true
	action.visible = false
	message.text = ""
	queue_redraw()

func _add_tile(tile: Control) -> void:
	tile.owner_panel = self
	tile.z_index = 200
	add_child(tile)
	tiles.append(tile)

func select_tile(tile: Control) -> void:
	selected_index = tile.bag_index
	selected_slot = tile.equipment_slot
	selected_potion = tile.item.id if tile.item.slot == "potion" else ""
	for other in tiles:
		other.selected = other == tile
		other.queue_redraw()
	item_title.text = ("Health potion" if selected_potion == "hp" else "Mana potion") if not selected_potion.is_empty() else String(tile.item.id).capitalize()
	var current: String = model.inventory.equipped.get(tile.item.slot,"none")
	detail.text = "Currently: %s\nSelected: %s" % [current.capitalize(),String(tile.item.id).capitalize()]
	stats.text = "Cosmetic equipment"
	if tile.item.slot == "weapon":
		var before: Dictionary = model.WEAPON_FEEL.get(current,{"damage":0,"duration":0})
		var after: Dictionary = model.WEAPON_FEEL.get(tile.item.id,{"damage":0,"duration":0})
		stats.text = "                     NOW     AFTER\n\nDAMAGE       %d    →    %d\n\nCYCLE          %.2fs → %.2fs" % [before.damage,after.damage,before.duration,after.duration]
		detail.text += "\nDamage %d → %d (%+d)" % [before.damage,after.damage,after.damage-before.damage]
	elif tile.item.slot == "offhand":
		stats.text = "GUARD\n\n" + ("Blocks frontal attacks\n80% damage reduction" if CharacterCatalog.is_shield(tile.item.id) else "No shield guard")
	if not selected_potion.is_empty():
		detail.text = "Restores up to 40 %s.\nShared 1-second cooldown." % selected_potion.to_upper()
		stats.text = "IN POUCH   ×%d" % tile.count
	action.text = "Unequip" if not selected_slot.is_empty() else "Equip item"
	action.visible = tile.item.id != "none" and tile.item.slot != "potion"
	action.disabled = tile.item.id == "none" or tile.locked or tile.item.slot == "potion"
	if tile.locked:
		detail.text = "Grove Centaurs cannot\nequip pants or boots."
	queue_redraw()

func _activate() -> void:
	_changed(model.change_equipment(selected_index,selected_slot))

func _changed(success: bool) -> void:
	if success:
		equipment_changed.emit()
		refresh()
	else:
		message.text = "Cannot equip: finish the current attack first, or check this lineage's equipment restrictions."

func can_drop_on(tile: Control, data: Variant) -> bool:
	if not data is Dictionary or data.get("panel") != self or not data.has_all(["item","slot","index"]):
		return false
	if not String(data.slot).is_empty():
		if model.inventory.equipped.get(data.slot,"none") != data.item.id or data.item.id == "none":
			return false
	elif data.index < 0 or data.index >= model.inventory.items.size() or model.inventory.items[data.index] != data.item:
		return false
	if tile.equipment_slot.is_empty():
		return not String(data.slot).is_empty()
	return String(data.slot).is_empty() and data.item.slot == tile.equipment_slot and model.inventory.can_wear(data.item.slot,data.item.id)

func drop_on(tile: Control, data: Dictionary) -> void:
	if can_drop_on(tile,data):
		_changed(model.change_equipment(data.index,String(data.slot)))

func highlight_targets(data: Dictionary) -> void:
	for tile in tiles:
		tile.compatible = can_drop_on(tile,data)
		tile.queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		for tile in tiles:
			tile.compatible = false
			tile.queue_redraw()

func _sort() -> void:
	model.inventory.sort_items()
	refresh()

func _draw() -> void:
	for panel in [Rect2(20,87,386,510),Rect2(416,87,407,510)]:
		_parchment(panel)
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(835,87,297,510))
	for y in [318,508]:
		draw_line(Vector2(861,y),Vector2(1116,y),Color("695b40"),1)
	draw_arc(Vector2(623,360),150,-2.8,2.8,48,Color("b39a63"),1,true)
	var selected: Dictionary = {}
	if selected_index >= 0 and selected_index < model.inventory.items.size():
		selected = model.inventory.items[selected_index]
	elif not selected_slot.is_empty():
		selected = {"slot":selected_slot,"id":model.inventory.equipped.get(selected_slot,"none")}
	if not selected.is_empty():
		var texture := Tile.art_for(selected)
		if texture != null:
			var region: Rect2 = Tile.regions[texture.resource_path]
			var factor := minf(140 / region.size.x,92 / region.size.y)
			var dimensions := region.size * factor
			draw_texture_rect_region(texture,Rect2(Vector2(986,196)-dimensions*.5,dimensions),region)

func _parchment(rect: Rect2) -> void:
	draw_style_box(theme.get_stylebox("panel","ParchmentPanel"),rect)
