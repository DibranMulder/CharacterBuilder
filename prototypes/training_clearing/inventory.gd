extends RefCounted
## Local item transactions, independent of rendering and input.
var coins := 0
var potions := {"hp": 3, "mana": 3}
var items: Array[Dictionary] = []
var equipped := {}
var lineage := "human"

func configure(race_id: String, loadout: Dictionary) -> void:
	lineage = race_id
	equipped = loadout.duplicate()

func grant(reward: Dictionary) -> void:
	coins += int(reward.get("coins", 0))
	for kind in potions:
		potions[kind] += int(reward.get(kind, 0))
	for item in reward.get("items", []):
		items.append(item.duplicate())

func can_wear(slot: String, item: String) -> bool:
	return slot in CharacterCatalog.EQUIPMENT and item in CharacterCatalog.EQUIPMENT[slot] and not (lineage == "centaur" and slot in ["pants", "boots"] and item != "none")

func equip(index: int) -> bool:
	if index < 0 or index >= items.size():
		return false
	var item: Dictionary = items[index]
	if not can_wear(item.slot, item.id):
		return false
	var previous: String = equipped.get(item.slot, "none")
	items.remove_at(index)
	if previous != "none":
		items.append({"slot":item.slot, "id":previous})
	equipped[item.slot] = item.id
	return true

func unequip(slot: String) -> bool:
	if equipped.get(slot, "none") == "none":
		return false
	items.append({"slot":slot, "id":equipped[slot]})
	equipped[slot] = "none"
	return true

func consume(kind: String, current: float, maximum: float) -> float:
	if not kind in potions or potions[kind] <= 0 or current >= maximum or current < 0:
		return 0
	potions[kind] -= 1
	return minf(40, maximum - current)
