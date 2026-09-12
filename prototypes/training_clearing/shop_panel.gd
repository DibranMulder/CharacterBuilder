extends "res://prototypes/training_clearing/inventory_panel.gd"
## Same parchment grid and painted tiles as the pouch; explicit transactions.
const Trader = preload("res://prototypes/training_clearing/trader.gd")
var purse: Label
var selected_source := ""
var selected_offer := -1
var quote_revision := -1
var selected_item := {}

func _ready() -> void:
	size = Vector2(1152,648)
	z_index = 310
	theme = Chronicle.create()
	var keyed := ShaderMaterial.new()
	keyed.shader = preload("res://prototypes/training_clearing/pouch_art.gdshader")
	material = keyed
	serif = theme.get_font("font","ChronicleHeading")
	var background := StyleBoxFlat.new()
	background.bg_color = Chronicle.NAVY
	add_theme_stylebox_override("panel",background)
	_label(model.merchant_name.to_upper()+"’S SHOP",Vector2(353,18),26,true,Chronicle.GOLD)
	_label(model.merchant_group.to_upper(),Vector2(30,25),15,true,Chronicle.BRASS)
	_button("Back · Esc",Vector2(990,18),Vector2(136,36),func(): closed.emit())
	_label(model.merchant_name.to_upper()+"’S STOCK",Vector2(100,101),23,true,INK)
	_label("YOUR POUCH",Vector2(535,101),23,true,INK)
	heading = _label("",Vector2(441,137),13,false,INK)
	purse = _label("",Vector2(863,137),17,true,Chronicle.GOLD)
	item_title = _label("Trading post",Vector2(860,101),22,true,Chronicle.GOLD)
	item_title.size.x = 260
	item_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail = _label("",Vector2(862,276),15,false,Chronicle.PARCHMENT)
	detail.size = Vector2(249,67)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats = _label("",Vector2(862,365),15,false,Chronicle.PARCHMENT)
	message = _label("",Vector2(32,615),14,false,Chronicle.PARCHMENT)
	action = _button("",Vector2(863,539),Vector2(250,44),_activate)
	action.theme_type_variation = "PrimaryButton"
	_button("‹",Vector2(441,552),Vector2(44,36),func(): page=maxi(0,page-1); refresh())
	_button("›",Vector2(767,552),Vector2(44,36),func(): page+=1; refresh())
	refresh()

func refresh() -> void:
	for tile in tiles:
		remove_child(tile)
		tile.queue_free()
	tiles.clear()
	for cell in 24:
		var tile = Tile.new()
		tile.position = Vector2(32+(cell%6)*59,173+(cell/6)*84)
		tile.size = Vector2(56,77)
		tile.drag_enabled = false
		if cell < model.merchant_stock.size():
			var offer: Dictionary = model.merchant_stock[cell]
			tile.item = {"slot":offer.slot,"id":offer.id}
			tile.price = offer.price
			tile.set_meta("offer",cell)
		_add_tile(tile)
	var entries: Array[Dictionary] = []
	for index in model.inventory.items.size():
		entries.append({"item":model.inventory.items[index],"index":index,"count":0})
	for kind in ["hp","mana"]:
		if model.inventory.potions[kind] > 0:
			entries.append({"item":{"slot":"potion","id":kind},"index":-1,"count":model.inventory.potions[kind]})
	page = clampi(page,0,maxi(0,(entries.size()-1)/24))
	for cell in 24:
		var tile = Tile.new()
		tile.position = Vector2(441+(cell%6)*62,173+(cell/6)*84)
		tile.size = Vector2(59,77)
		tile.drag_enabled = false
		var index := page*24+cell
		if index < entries.size():
			tile.item = entries[index].item.duplicate()
			tile.bag_index = entries[index].index
			tile.count = entries[index].count
		_add_tile(tile)
	heading.text = "%d items · Page %d" % [entries.size(),page+1]
	purse.text = "%d coins" % model.inventory.coins
	selected_source = ""
	selected_offer = -1
	selected_item = {}
	item_title.text = "Trading post"
	detail.text = ""
	stats.text = ""
	action.visible = false
	queue_redraw()

func select_tile(tile: Control) -> void:
	if tile.item.id == "none": return
	selected_item = tile.item.duplicate()
	selected_source = "stock" if tile.has_meta("offer") else "pouch"
	selected_offer = tile.get_meta("offer",-1)
	selected_index = tile.bag_index
	selected_potion = tile.item.id if tile.item.slot == "potion" else ""
	quote_revision = model.inventory.revision
	for other in tiles:
		other.selected = other == tile
		other.queue_redraw()
	item_title.text = Trader.name_of(selected_item)
	var price: int = Trader.STOCK[selected_offer].price if selected_source == "stock" else Trader.sell_price(selected_item)
	detail.text = "%s price   %d coins\nBalance after   %d coins" % ["Buy" if selected_source == "stock" else "Sell",price,model.inventory.coins+(-price if selected_source == "stock" else price)]
	stats.text = ""
	if selected_item.slot == "weapon":
		var before: Dictionary = model.WEAPON_FEEL.get(model.weapon,{"damage":0,"duration":0})
		var after: Dictionary = model.WEAPON_FEEL[selected_item.id]
		stats.text = "EQUIPPED → ITEM\n\nDamage   %d → %d\n\nCycle   %.2fs → %.2fs" % [before.damage,after.damage,before.duration,after.duration]
	elif selected_item.slot == "potion":
		stats.text = "Restores up to 40 %s\n\nIn pouch   ×%d" % ["HP" if selected_item.id == "hp" else "mana",model.inventory.potions[selected_item.id]]
	elif selected_item.slot == "offhand":
		stats.text = "Shield guard" if CharacterCatalog.is_shield(selected_item.id) else "Off-hand equipment"
	else:
		stats.text = "Cosmetic equipment"
	action.visible = true
	action.text = "%s one · %d coins" % ["Buy" if selected_source == "stock" else "Sell",price]
	action.disabled = price <= 0 or (selected_source == "stock" and model.inventory.coins < price)
	if action.disabled and selected_source == "stock": detail.text = "Buy price   %d coins\nNot enough coins" % price
	message.text = ""
	queue_redraw()

func _activate() -> void:
	if selected_source.is_empty(): return
	var result: Dictionary = model.buy_from_rowan(selected_offer,quote_revision) if selected_source == "stock" else model.sell_to_rowan(selected_index,selected_potion,quote_revision)
	refresh()
	message.text = result.message

func can_drop_on(_tile: Control, _data: Variant) -> bool:
	return false

func _draw() -> void:
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(10,8,1132,61))
	_parchment(Rect2(16,86,390,518))
	_parchment(Rect2(416,86,414,518))
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(840,86,294,518))
	for y in [264,347,518]: draw_line(Vector2(861,y),Vector2(1113,y),Color("6e603e"),1)
	if not selected_item.is_empty():
		var texture := Tile.art_for(selected_item)
		if texture != null:
			var region: Rect2 = Tile.regions[texture.resource_path]
			var factor := minf(135/region.size.x,80/region.size.y)
			var dimensions := region.size*factor
			draw_texture_rect_region(texture,Rect2(Vector2(986,212)-dimensions*.5,dimensions),region)
