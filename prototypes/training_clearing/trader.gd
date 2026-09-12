extends RefCounted
## Local atomic trading rules; the UI never supplies prices or awards items.
const STOCK := [
	{"slot":"potion","id":"hp","price":6},
	{"slot":"potion","id":"mana","price":6},
	{"slot":"weapon","id":"sword","price":24},
	{"slot":"weapon","id":"axe","price":30},
	{"slot":"weapon","id":"spear","price":26},
	{"slot":"weapon","id":"bow","price":28},
	{"slot":"weapon","id":"crossbow","price":36},
	{"slot":"weapon","id":"staff","price":32},
	{"slot":"weapon","id":"branch_staff","price":32},
	{"slot":"offhand","id":"shield","price":18},
]

static func name_of(item: Dictionary) -> String:
	if item.slot == "potion":
		return "Health potion" if item.id == "hp" else "Mana potion"
	return String(item.id).capitalize()

static func sell_price(item: Dictionary) -> int:
	for offer in STOCK:
		if offer.slot == item.slot and offer.id == item.id:
			return maxi(1,int(offer.price*.4))
	if item.slot in CharacterCatalog.EQUIPMENT and item.id in CharacterCatalog.EQUIPMENT[item.slot] and item.id != "none":
		return 5
	return 0

static func buy(inventory, offer_index: int, revision: int, stock: Array = STOCK) -> Dictionary:
	if revision != inventory.revision:
		return {"ok":false,"message":"Your pouch changed. Select the item again."}
	if offer_index < 0 or offer_index >= stock.size():
		return {"ok":false,"message":"That item is not in stock."}
	var offer: Dictionary = stock[offer_index]
	if inventory.coins < offer.price:
		return {"ok":false,"message":"Not enough coins."}
	inventory.coins -= offer.price
	if offer.slot == "potion":
		inventory.potions[offer.id] += 1
	else:
		inventory.items.append({"slot":offer.slot,"id":offer.id})
	inventory.revision += 1
	return {"ok":true,"message":"Bought %s · −%d coins" % [name_of(offer),offer.price]}

static func sell(inventory, index: int, potion: String, revision: int) -> Dictionary:
	if revision != inventory.revision:
		return {"ok":false,"message":"Your pouch changed. Select the item again."}
	var item: Dictionary
	if not potion.is_empty():
		if not potion in inventory.potions or inventory.potions[potion] <= 0:
			return {"ok":false,"message":"No potion to sell."}
		item = {"slot":"potion","id":potion}
	else:
		if index < 0 or index >= inventory.items.size():
			return {"ok":false,"message":"That item is no longer in your pouch."}
		item = inventory.items[index]
	var price := sell_price(item)
	if price <= 0:
		return {"ok":false,"message":"This merchant cannot buy this item."}
	if potion.is_empty():
		inventory.items.remove_at(index)
	else:
		inventory.potions[potion] -= 1
	inventory.coins += price
	inventory.revision += 1
	return {"ok":true,"message":"Sold %s · +%d coins" % [name_of(item),price]}
