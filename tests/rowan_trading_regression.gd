extends SceneTree
const Encounter = preload("res://prototypes/training_clearing/encounter.gd")
const Trader = preload("res://prototypes/training_clearing/trader.gd")
const Clearing = preload("res://prototypes/training_clearing/training_clearing.tscn")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var model = Encounter.new()
	model.inventory.configure("human",CharacterCatalog.reference_loadout("human"))
	model.inventory.grant({"coins":40,"items":[{"slot":"weapon","id":"axe"},{"slot":"weapon","id":"sword"}]})
	assert(not model.can_talk_to_rowan())
	assert(not model.buy_from_rowan(0,model.inventory.revision).ok)
	model.position.x = 250
	assert(model.can_talk_to_rowan())
	var quoted: int = model.inventory.revision
	assert(model.buy_from_rowan(0,quoted).ok)
	assert(model.inventory.coins == 34 and model.inventory.potions.hp == 4)
	assert(not model.buy_from_rowan(0,quoted).ok)
	assert(model.inventory.coins == 34 and model.inventory.potions.hp == 4)
	quoted = model.inventory.revision
	assert(model.sell_to_rowan(0,"",quoted).ok)
	assert(model.inventory.coins == 46 and model.inventory.items[0].id == "sword")
	assert(not model.sell_to_rowan(0,"",quoted).ok, "stale click cannot sell the item now at the same index")
	assert(model.inventory.items.size() == 1)
	assert(not model.sell_to_rowan(-1,"",model.inventory.revision).ok)
	assert(model.inventory.equipped.weapon == "sword")
	assert(not model.buy_from_rowan(999,model.inventory.revision).ok)
	model.inventory.coins = 0
	quoted = model.inventory.revision
	assert(not model.buy_from_rowan(0,quoted).ok and model.inventory.revision == quoted)
	model.inventory.potions.hp = 0
	assert(not model.sell_to_rowan(-1,"hp",quoted).ok)
	model.health = 0
	assert(not model.sell_to_rowan(0,"",quoted).ok)
	model.health = 100
	model.enemies[0].x = model.position.x+100
	assert(not model.can_talk_to_rowan())
	for offer in Trader.STOCK:
		assert(Trader.sell_price(offer) < offer.price)
	var scene = Clearing.instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene.model.position.x = 250
	scene.model.inventory.grant({"coins":40,"items":[{"slot":"weapon","id":"crossbow"}]})
	scene._talk_to_rowan()
	assert(scene.paused and is_instance_valid(scene.dialogue))
	assert(scene.model.rowan.conversing and not scene.model.rowan.walking)
	assert(scene.rowan.stride == 0 and not scene.rowan_balloon.visible)
	var npc_position: Vector2 = scene.model.rowan.position
	scene._physics_process(.5)
	assert(scene.model.rowan.position == npc_position)
	scene._toggle_inventory()
	assert(not is_instance_valid(scene.inventory_panel))
	scene._open_shop()
	assert(is_instance_valid(scene.shop) and not scene.dialogue.visible)
	scene.shop.select_tile(scene.shop.tiles[0])
	assert(not scene.shop.action.disabled)
	scene.shop._activate()
	assert(scene.model.inventory.coins == 34 and scene.model.inventory.potions.hp == 4)
	scene.shop._activate()
	assert(scene.model.inventory.coins == 34)
	scene.shop.select_tile(scene.shop.tiles[24])
	scene.shop._activate()
	assert(scene.model.inventory.coins == 48 and scene.model.inventory.items.is_empty())
	scene._back_to_rowan()
	assert(scene.dialogue.visible and scene.paused)
	scene._close_rowan()
	assert(not scene.paused and not is_instance_valid(scene.dialogue))
	assert(not scene.model.rowan.conversing)
	assert(scene.model.inventory.coins == 48)
	scene._talk_to_rowan()
	scene._open_shop()
	scene._restart()
	assert(not is_instance_valid(scene.shop) and not is_instance_valid(scene.dialogue))
	assert(scene.model.inventory.coins == 0)
	scene.free()
	print("PASS: Rowan proximity/safety, atomic buy/sell, stale-click rejection, prices and dialogue/shop flow")
	quit()
