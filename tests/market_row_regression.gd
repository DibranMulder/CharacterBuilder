extends SceneTree
const Square = preload("res://prototypes/human_hometown/human_hometown.tscn")
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func _run() -> void:
	var square = Square.instantiate()
	root.add_child(square)
	current_scene = square
	square.set_physics_process(false)
	square.model.inventory.grant({"coins":200})
	square.model.health = 76
	square.model.mana = 63
	var inventory = square.model.inventory
	var square_model = square.model
	square.model.position.x = 60
	square.model.grounded = false
	square._check_district_exit()
	check(not square.leaving,"airborne players cannot change districts")
	square.model.grounded = true
	square._toggle_pause()
	square._check_district_exit()
	check(not square.leaving,"menus prevent transfers")
	square._toggle_pause()
	square._check_district_exit()
	await process_frame
	await process_frame
	var market = current_scene
	market.set_physics_process(false)
	check(market.district_id == "market" and market.model.map_id == "wendmere_market","square west exit loads Market Row")
	check(market.model != square_model and market.model.inventory == inventory,"districts have separate state and shared possessions")
	check(market.model.health == 76 and market.model.mana < 65,"travel does not refill resources")
	check(market.model.position.x == market.model.world_width-180,"arrival is outside the return portal")
	check(market.merchants.size() == 3 and not market.rowan.visible,"three distinct shopkeepers replace Rowan in this map")
	var expected := ["sword","shield","staff"]
	for index in 3:
		market.model.position.x = market.Market.MERCHANTS[index].x-30
		market._update_view(0)
		check(market.model.merchant_name == market.Market.MERCHANTS[index].name,"nearest merchant is selected")
		market._talk_to_rowan()
		check(market.paused and market.dialogue.merchant.id == market.Market.MERCHANTS[index].id,"correct merchant dialogue")
		market._open_shop()
		check(market.shop.tiles[0].item.id == expected[index],"shop shows this merchant's stock")
		var revision: int = inventory.revision
		check(market.model.buy_from_rowan(0,revision).ok,"purchase succeeds")
		check(not market.model.buy_from_rowan(0,revision).ok,"duplicate click cannot charge twice")
		market._close_rowan()
	market.model.position.x = 530
	market._update_view(0)
	var old_quote: int = inventory.revision
	market.model.position.x = 1230
	market._update_view(0)
	check(not market.model.buy_from_rowan(0,old_quote).ok,"merchant switch invalidates stale offers")
	check(market.model.buy_from_rowan(2,inventory.revision).ok,"armorer sells real armor equipment")
	check(market.model.inventory.items.back().id == "plate","armor enters the pouch")
	check(market.model.change_equipment(inventory.items.size()-1),"purchased armor can be equipped")
	market._equipment_changed()
	check(market.avatar.loadout.armor == "plate","outfit updates after purchase")
	check(market.model.sell_to_rowan(0,"",inventory.revision).ok,"all merchants buy spare items")
	var coins: int = inventory.coins
	for i in 5: await process_frame
	var changes := [0]
	for node in market.get_children():
		if node is Button: node.visibility_changed.connect(func(): changes[0] += 1)
	market.rowan.visibility_changed.connect(func(): changes[0] += 1)
	for i in 30:
		market._update_view(0)
		await process_frame
	check(changes[0] == 0,"stable controls and hidden Rowan do not churn visibility")
	market.model.position.x = market.model.world_width-60
	market._check_district_exit()
	await process_frame
	await process_frame
	var returned = current_scene
	returned.set_physics_process(false)
	check(returned.model == square_model and returned.model.map_id == "wendmere_square","east exit returns to the same square")
	check(returned.model.position.x == 180 and returned.model.inventory.coins == coins,"return preserves money and prevents bouncing")
	check(returned.model.weapon == inventory.equipped.weapon and returned.avatar.loadout.armor == "plate","purchased equipment survives the return")
	returned.model.position.x = 60
	returned._check_district_exit()
	await process_frame
	await process_frame
	var revisited = current_scene
	revisited.set_physics_process(false)
	check(revisited.model.inventory.coins == coins and revisited.model.inventory == inventory,"revisits do not duplicate stock or coins")
	check(revisited.model.merchant_stock.size() > 0,"shop selection survives revisits")
	if not failed: print("PASS: connected market district, three shops, custom stock, purchases, stale quotes, equipment, persistence and stable controls")
	quit(1 if failed else 0)
