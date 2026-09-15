extends RefCounted
## A session-local route through separate maps. Gameplay owns rewards and combat.
const Encounter = preload("res://prototypes/training_clearing/encounter.gd")
const MAPS := [
	{"id":"trail","name":"Willow Trail","width":1250.0,"rowan":false,"enemies":[],
		"platforms":[Rect2(465,390,190,18),Rect2(760,325,160,18)],
		"sky":Color("a7c4b0"),"trees":Color("648c77"),"ground":Color("61714b")},
	{"id":"yard","name":"Warden's Yard","width":1500.0,"rowan":false,"enemies":[[740.0,false],[1090.0,false]],
		"platforms":[Rect2(450,390,140,18)],
		"sky":Color("bfc4ad"),"trees":Color("879581"),"ground":Color("77715d")},
	{"id":"camp","name":"Rowan's Camp","width":1200.0,"rowan":true,"enemies":[],
		"platforms":[],"sky":Color("d7c99e"),"trees":Color("9a9e79"),"ground":Color("8a7452")},
	{"id":"grove","name":"Briar Hollow","width":1450.0,"rowan":false,"enemies":[[1000.0,true]],
		"platforms":[Rect2(490,375,170,18)],
		"sky":Color("667f84"),"trees":Color("425e65"),"ground":Color("4c5856")},
]
var active := false # Hint visibility; the route and action tracking survive hiding hints.
var started := false
var index := 0
var finished := false
var actions := {}
var visits := {}
var model

func start(initial):
	if started:
		active = true
		return model
	started = true
	active = true
	# Keep the outfit and local possessions when entering from free practice.
	model = initial
	if model.weapon == "none" and not model.inventory.items.any(func(item): return item.slot == "weapon"):
		model.inventory.grant({"items":[{"slot":"weapon","id":"sword"}]})
	return _enter(0)

func record(action: String) -> void:
	if not started: return
	actions[action] = true
	actions["%s/%s" % [MAPS[index].id,action]] = true

func observe(current) -> void:
	if not started: return
	if current.moved: record("move")
	if current.jumped: record("jump")
	if current.blocks > 0: record("guard")
	if current.grounded and current.position.y < current.FLOOR_Y-20: record("platform")
	if index == 3 and current.elite_defeated: finished = true

func map_ready() -> bool:
	match index:
		0: return actions.has("trail/move") and actions.has("trail/jump") and actions.has("trail/platform") and model.weapon != "none"
		1: return model.enemies.all(func(enemy): return enemy.hp <= 0) and model.loot.is_empty() and actions.has("attack") and actions.has("skill")
		2: return actions.has("talk") and actions.has("buy") and actions.has("sell") and actions.has("equip") and actions.has("disciplines") and model.weapon != "none"
		3: return finished
	return false

func can_travel(direction: int) -> bool:
	if not started or not direction in [-1,1]: return false
	if model.health <= 0 or not model.grounded or model.attack_time > 0 or not model.projectiles.is_empty(): return false
	if direction == -1: return index > 0 and model.position.x <= 85
	return index < MAPS.size()-1 and model.position.x >= model.world_width-85 and map_ready()

func travel(direction: int):
	if not can_travel(direction): return model
	return _enter(index+direction,direction < 0)

func _enter(destination: int, from_east := false):
	var previous = model
	index = destination
	if not visits.has(index):
		var next = Encounter.new()
		next.configure_map(MAPS[index])
		next.inventory = previous.inventory
		next.progression = previous.progression
		next.activity.connect(record)
		visits[index] = next
	model = visits[index]
	model.configure_equipment(model.inventory.equipped)
	model.health = previous.health
	model.mana = previous.mana
	model.stamina = previous.stamina
	model.xp = previous.xp
	model.adventure_level = previous.adventure_level
	model.skill_cooldown = previous.skill_cooldown
	model.potion_cooldown = previous.potion_cooldown
	model.lineage_cooldowns = previous.lineage_cooldowns.duplicate()
	model.mana_delay = previous.mana_delay
	model.position = Vector2(model.world_width-160 if from_east else 160,Encounter.FLOOR_Y)
	model.velocity = Vector2.ZERO
	model.grounded = true
	model.facing = -1 if from_east else 1
	model.guarding = false
	model.ward = 0
	model.ward_time = 0
	model.events.clear()
	model.attack_time = 0
	model.invulnerable = 1
	return model

# One short instruction tied to an actual place or action. No reading/Next steps.
func hint() -> Dictionary:
	if not started: return {}
	var at: Vector2 = model.position
	if model.health <= 0: return _hint("Back on your feet soon", "You recover in this map. Your loot stays with you.",at)
	if model.weapon == "none": return _hint("Equip a weapon", "I · Pouch → select a weapon → Equip",at)
	if model.health < 65 and model.inventory.potions.hp > 0 and not actions.has("health"):
		return _hint("Restore your health", "H · HP potion  |  Restores up to 40",at)
	if model.mana < 85 and model.inventory.potions.mana > 0 and not actions.has("mana"):
		return _hint("Refill your mana", "M · Mana potion  |  Restores up to 40",at)
	match index:
		0:
			if not actions.has("trail/move"): return _hint("Follow the trail →", "A / D or arrows · Move",Vector2(360,480))
			if not actions.has("trail/jump"): return _hint("Hop toward the ledge", "Space or JUMP · Steer in the air",Vector2(465,390))
			if not actions.has("trail/platform"): return _hint("Land on a ledge", "Jump through it, then land from above",Vector2(560,390))
		1:
			if not actions.has("attack") and model.enemies.all(func(enemy): return enemy.hp <= 0):
				return _hint("Try your weapon attack", "J / ATTACK · Swing or fire once",at)
			for enemy in model.enemies:
				if enemy.hp <= 0 or absf(enemy.x-at.x) > 220: continue
				if enemy.state == "windup":
					return _hint("Gold means an attack is coming", "Face it + hold Shift / GUARD" if model.can_guard else "Step back or jump behind it",Vector2(enemy.x,440))
				if not actions.has("attack"): return _hint("Strike, then recover", "J / ATTACK · Face your target",Vector2(enemy.x,440))
			if not actions.has("skill"): return _hint("Try your first lineage skill", "3 · First skill tile  |  Costs mana",at)
			if not model.loot.is_empty(): return _hint("Pick up the bag", "Walk close · Coins, potions and gear",model.loot[0].position)
			for enemy in model.enemies:
				if enemy.hp > 0: return _hint("Clear the practice yard", "J · Attack   3 · Skill   H · Heal",Vector2(enemy.x,440))
		2:
			if not actions.has("talk"): return _hint("Meet Rowan", "E / Rowan · Talk near the stall",model.rowan.position)
			if not actions.has("buy"): return _hint("Buy a potion", "E · Rowan → Trade → potion → Buy one",model.rowan.position)
			if not actions.has("sell"): return _hint("Sell one spare item", "E · Rowan → Trade → your item → Sell one",model.rowan.position)
			if not actions.has("equip"): return _hint("Try your new gear", "I · Pouch → select gear → Equip",at)
			if not actions.has("disciplines"): return _hint("See what you have learned", "L · Skills → Disciplines & Levels",at)
		3:
			if finished: return _hint("The hollow is safe", "Tutorial complete · West portal + ↑ to return",Vector2(1000,480))
			return _hint("Defeat the Elder Briar", "Watch its warning · Defend, strike, heal",Vector2(1000,440))
	return _hint("Next map →", "Stand in the portal light · ↑ to travel",Vector2(model.world_width-65,480))

func _hint(title: String, text: String, at: Vector2) -> Dictionary:
	return {"title":title,"text":text,"at":at}
