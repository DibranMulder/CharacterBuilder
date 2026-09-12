extends RefCounted
signal activity(action: String)
## Local, throwaway gameplay model. Does sword/guard combat feel readable?
## Local inventory/trading and optional hero Discipline progression; no networking.

const FLOOR_Y := 480.0
const MonsterImpact = preload("res://src/monster_impact.gd")
var attack_presentation: Dictionary = {}
const WORLD_WIDTH := 2200.0
const ROWAN_POSITION := Vector2(330,480)
var rowan = preload("res://prototypes/training_clearing/rowan_behavior.gd").new()
const Trader = preload("res://prototypes/training_clearing/trader.gd")
var merchant_id := "rowan"
var merchant_name := "Rowan"
var merchant_group := "Forest Wardens"
var merchant_stock: Array = Trader.STOCK
const PLATFORMS := [Rect2(710, 390, 170, 18), Rect2(950, 325, 150, 18)]
var world_width := WORLD_WIDTH
var platforms: Array = PLATFORMS.duplicate()
var map_id := ""
var rowan_enabled := true
var recovery_anchor := Vector2(160,FLOOR_Y)

func configure_map(spec: Dictionary) -> void:
	map_id = spec.id
	world_width = spec.width
	platforms = spec.platforms.duplicate()
	rowan_enabled = spec.rowan
	rowan.home = Vector2(spec.get("merchant_x",ROWAN_POSITION.x),FLOOR_Y)
	rowan.position = rowan.home
	enemies.clear()
	for enemy in spec.enemies: _spawn_enemy(enemy[0],enemy[1])

var position := Vector2(160, FLOOR_Y)
var velocity := Vector2.ZERO
var facing := 1.0
var grounded := true
var health := 100.0
var mana := 100.0
var mana_delay := 0.0
var xp := 0
var adventure_level := 1
var last_rejection := ""
var stamina := 100.0
var guarding := false
var attack_time := 0.0
var skill_cooldown := 0.0
var invulnerable := 0.0
var death_time := 0.0
var attack_kind := ""
var attack_hit := false
var attack_facing := 1.0
var kills := 0
var blocks := 0
var jumped := false
var moved := false
var elite_defeated := false
var enemies: Array[Dictionary] = []
var events: Array[Dictionary] = []
var weapon := "sword"
var can_guard := true
var projectiles: Array[Dictionary] = []
var inventory = preload("res://prototypes/training_clearing/inventory.gd").new()
var loot: Array[Dictionary] = []
var potion_cooldown := 0.0
var progression
var lineage_cooldowns := [0.0,0.0,0.0,0.0,0.0,0.0]
var active_skill: Dictionary = {}
var ward := 0.0
var ward_time := 0.0

func select_merchant(spec: Dictionary) -> void:
	if merchant_id == spec.id: return
	merchant_id = spec.id
	merchant_name = spec.name
	merchant_group = "Wendmere Artisans"
	merchant_stock = spec.stock
	rowan.home = Vector2(spec.x,FLOOR_Y)
	rowan.position = rowan.home
	# Invalidate an old shop quote when the active merchant changes.
	inventory.revision += 1

func carry_player_from(other) -> void:
	inventory = other.inventory
	progression = other.progression
	configure_equipment(inventory.equipped)
	health = other.health
	mana = other.mana
	stamina = other.stamina
	xp = other.xp
	adventure_level = other.adventure_level
	potion_cooldown = other.potion_cooldown
	lineage_cooldowns = other.lineage_cooldowns.duplicate()
	skill_cooldown = other.skill_cooldown
	mana_delay = other.mana_delay

func lineage_kit() -> Array[Dictionary]:
	return preload("res://prototypes/sparring_arena/lineage_skills.gd").combat_kit(inventory.lineage)

func begin_lineage_skill(slot: int) -> bool:
	last_rejection = ""
	if slot < 0 or slot >= lineage_cooldowns.size() or health <= 0 or attack_time > 0 or guarding or lineage_cooldowns[slot] > 0:
		return false
	var skill := lineage_kit()[slot]
	if progression != null and not progression.allows(skill):
		last_rejection = progression.requirement_text(skill)
		return false
	if mana < skill.mana:
		last_rejection = "NOT ENOUGH MANA"
		return false
	active_skill = skill.duplicate()
	attack_presentation = _impact_profile(true,skill)
	active_skill["impact_profile"] = attack_presentation.duplicate()
	attack_kind = "lineage"
	attack_time = skill.windup + skill.recovery
	attack_hit = false
	attack_facing = facing
	mana -= skill.mana
	mana_delay = 1.2
	lineage_cooldowns[slot] = skill.cooldown
	activity.emit("skill")
	return true

func _release_lineage_skill(muzzle := Vector2.INF) -> void:
	var skill := active_skill
	match skill.kind:
		"heal":
			var amount := minf(skill.power,100-health)
			health += amount
			if progression != null: progression.award("focus",ceili(amount))
			events.append({"kind":"heal","text":"+%d HP"%amount,"position":position+Vector2(0,-150),"impact":position+Vector2(0,-85)})
		"ward":
			ward = skill.power
			ward_time = 5
			events.append({"kind":"ward","text":"WARD %d"%ward,"position":position+Vector2(0,-150),"impact":position+Vector2(0,-85)})
		"retreat": position.x = clampf(position.x-attack_facing*skill.reach,40,world_width-40)
		"bolt", "slowbolt", "rootbolt", "drain":
			var origin: Vector2 = muzzle if muzzle.is_finite() else position+Vector2(attack_facing*35,-60)
			var travel := Vector2(attack_facing,0)
			var closest: float = skill.reach
			for enemy in enemies:
				var distance: float = (enemy.x-origin.x)*attack_facing
				if enemy.hp > 0 and distance > 0 and distance < closest:
					closest = distance
					travel = (Vector2(enemy.x,FLOOR_Y-40)-origin).normalized()
			projectiles.append({"position":origin,"velocity":travel*470,"direction":attack_facing,"life":skill.reach/470.0,"power":true,"skill":skill.duplicate()})
		_:
			var start := position
			if skill.kind == "dash": position.x = clampf(position.x+attack_facing*minf(180,skill.reach),40,world_width-40)
			for enemy in enemies:
				var dx: float = (enemy.x-start.x)*attack_facing
				if enemy.hp > 0 and absf(start.y-FLOOR_Y) < 90 and ((absf(dx) <= skill.reach) if skill.kind == "pulse" else (dx >= -10 and dx <= skill.reach)):
					_hit_lineage_skill(enemy,skill)

func _hit_lineage_skill(enemy: Dictionary, skill: Dictionary) -> void:
	var previous: float = enemy.hp
	_damage_enemy(enemy,true,skill.power,skill.get("impact_profile",_impact_profile(true,skill)))
	if progression != null:
		progression.train_hit(previous-enemy.hp,skill.kind in ["bolt","slowbolt","rootbolt","drain"],true)
	if skill.kind == "drain":
		var amount := minf(100-health,(previous-enemy.hp)*.5)
		health += amount
		if amount > 0: events.append({"kind":"heal","text":"+%d HP"%amount,"position":position+Vector2(0,-150),"impact":position+Vector2(0,-85)})
	if skill.kind == "rootbolt": enemy.rooted = .8
	if skill.kind == "slowbolt": enemy.slowed = 2.0
	if skill.kind == "pulse": enemy.x = clampf(enemy.x+signf(enemy.x-position.x)*50,40,world_width-40)

func can_talk_to_rowan() -> bool:
	if not rowan_enabled or health <= 0 or not grounded or position.distance_to(rowan.position) > 115 or attack_time > 0 or not projectiles.is_empty():
		return false
	for enemy in enemies:
		if enemy.hp > 0 and absf(enemy.x-position.x) < 220:
			return false
	return true

func buy_from_rowan(offer_index: int, revision: int) -> Dictionary:
	if not can_talk_to_rowan():
		return {"ok":false,"message":"Return to %s when it is safe to trade." % merchant_name}
	var result := Trader.buy(inventory,offer_index,revision,merchant_stock)
	if result.ok: activity.emit("buy")
	return result

func sell_to_rowan(index: int, potion: String, revision: int) -> Dictionary:
	if not can_talk_to_rowan():
		return {"ok":false,"message":"Return to %s when it is safe to trade." % merchant_name}
	var result := Trader.sell(inventory,index,potion,revision)
	if result.ok: activity.emit("sell")
	return result

func use_potion(kind: String) -> Dictionary:
	if health <= 0 or potion_cooldown > 0 or not kind in ["hp", "mana"]:
		return {}
	var restored: float = inventory.consume(kind, health if kind == "hp" else mana, 100)
	if restored <= 0:
		return {}
	if kind == "hp":
		health += restored
	else:
		mana += restored
	potion_cooldown = 1.0
	activity.emit("health" if kind == "hp" else "mana")
	if progression != null: progression.award("survival",ceili(restored))
	return {"kind":"heal" if kind == "hp" else "notice", "text":"+%d %s" % [restored, kind.to_upper()], "position":position + Vector2(0,-150), "impact":position+Vector2(0,-85)}

func change_equipment(index: int, slot := "") -> bool:
	if health <= 0 or attack_time > 0 or not projectiles.is_empty():
		return false
	var changed: bool = inventory.equip(index) if slot.is_empty() else inventory.unequip(slot)
	if changed:
		configure_equipment(inventory.equipped)
		guarding = false
		if slot.is_empty(): activity.emit("equip")
	return changed
const WEAPON_FEEL := {
	"sword": {"damage":20, "duration":.88, "release":.39, "reach":140},
	"axe": {"damage":28, "duration":1.05, "release":.43, "reach":130},
	"spear": {"damage":18, "duration":.72, "release":.25, "reach":180},
	"bow": {"damage":18, "duration":.88, "release":.50, "reach":650},
	"crossbow": {"damage":26, "duration":.94, "release":.38, "reach":650},
	"staff": {"damage":22, "duration":.78, "release":.30, "reach":650},
	"branch_staff": {"damage":22, "duration":.78, "release":.30, "reach":650},
}

func weapon_feel() -> Dictionary:
	return WEAPON_FEEL.get(weapon, WEAPON_FEEL.sword)

func mana_cost(power := false) -> float:
	return 25.0 if power else (8.0 if weapon in ["staff", "branch_staff"] else 0.0)

func xp_required() -> int:
	return adventure_level * 100

func award_xp(amount: int) -> void:
	if adventure_level >= 120:
		return
	xp += amount
	events.append({"kind":"xp", "text":"+%d XP" % amount, "position": position + Vector2(0,-190)})
	while adventure_level < 120 and xp >= xp_required():
		xp -= xp_required()
		adventure_level += 1
		events.append({"kind":"level", "text":"LEVEL %d" % adventure_level, "position": position + Vector2(0,-220)})
	if adventure_level == 120:
		xp = 0

func configure_equipment(loadout: Dictionary) -> void:
	weapon = loadout.weapon
	can_guard = CharacterCatalog.is_shield(loadout.offhand)

func attack_animation() -> StringName:
	match weapon:
		"bow": return &"fire_bow"
		"crossbow": return &"fire_crossbow"
		"staff", "branch_staff": return &"cast_spell"
		"spear": return &"jab"
	return &"forehand"

func is_ranged() -> bool:
	return weapon in ["bow", "crossbow", "staff", "branch_staff"]

func _init() -> void:
	for spec in [[650.0, false], [1250.0, false], [1900.0, true]]:
		_spawn_enemy(spec[0],spec[1])

func _spawn_enemy(x: float, elite: bool) -> void:
	enemies.append({"x":x,"home":x,"hp":120.0 if elite else 50.0,
		"max_hp":120.0 if elite else 50.0,"elite":elite,"state":"idle",
		"timer":0.0,"facing":-1.0,"flash":0.0})

func begin_attack(power := false) -> bool:
	last_rejection = ""
	if power and progression != null:
		return begin_lineage_skill(4)
	if weapon == "none" or health <= 0 or attack_time > 0 or guarding:
		return false
	if power and skill_cooldown > 0:
		return false
	if mana < mana_cost(power):
		last_rejection = "NOT ENOUGH MANA"
		return false
	activity.emit("attack")
	attack_kind = "power" if power else "sword"
	attack_presentation = _impact_profile(power)
	attack_time = weapon_feel().duration
	attack_hit = false
	attack_facing = facing
	mana -= mana_cost(power)
	if mana_cost(power) > 0:
		mana_delay = 1.2
	if power:
		skill_cooldown = 4.0
	return true

func jump() -> bool:
	if not grounded or health <= 0 or guarding:
		return false
	velocity.y = -560
	grounded = false
	jumped = true
	return true

func step(delta: float, direction: float, guard_held: bool, muzzle := Vector2.INF) -> void:
	events.clear()
	var peaceful := health > 0 and attack_time <= 0 and projectiles.is_empty()
	for enemy in enemies:
		if enemy.hp > 0 and absf(enemy.x-position.x) < 220:
			peaceful = false
	rowan.step(delta,position,peaceful)
	potion_cooldown = maxf(0, potion_cooldown - delta)
	skill_cooldown = maxf(0, skill_cooldown - delta)
	for i in lineage_cooldowns.size(): lineage_cooldowns[i] = maxf(0,lineage_cooldowns[i]-delta)
	ward_time = maxf(0,ward_time-delta)
	if ward_time <= 0: ward = 0
	invulnerable = maxf(0, invulnerable - delta)
	if health <= 0:
		death_time -= delta
		if death_time <= 0:
			position = recovery_anchor
			velocity = Vector2.ZERO
			health = 100
			mana = 100
			stamina = 100
			ward = 0
			active_skill.clear()
			invulnerable = 2
			for enemy in enemies:
				if enemy.hp > 0:
					enemy.x = enemy.home
					enemy.hp = enemy.max_hp
					enemy.state = "idle"
					enemy.timer = 0.0
			events.append({"text": "Recovered", "position": position})
		return
	mana_delay = maxf(0, mana_delay - delta)
	if mana_delay <= 0:
		mana = minf(100, mana + 5 * delta)
	guarding = can_guard and guard_held and grounded and attack_time <= 0 and stamina > 1
	if absf(direction) > .1 and attack_time <= 0:
		facing = signf(direction)
	var speed := 105.0 if guarding else (90.0 if attack_time > 0 else 245.0)
	velocity.x = move_toward(velocity.x, direction * speed, 1600 * delta)
	var previous_y := position.y
	var old_x := position.x
	position.x = clampf(position.x + velocity.x * delta, 40, world_width - 40)
	if progression != null: progression.explore(position,not peaceful,absf(position.x-old_x),map_id)
	velocity.y += 1500 * delta
	position.y += velocity.y * delta
	grounded = false
	if velocity.y >= 0:
		var landing_y := FLOOR_Y
		for platform in platforms:
			if position.x >= platform.position.x and position.x <= platform.end.x and previous_y <= platform.position.y + .1:
				landing_y = minf(landing_y, platform.position.y)
		if position.y >= landing_y:
			position.y = landing_y
			velocity.y = 0
			grounded = true
	moved = moved or position.x > 310
	stamina = clampf(stamina + (-8.0 if guarding else 19.0) * delta, 0, 100)
	if attack_time > 0:
		attack_time = maxf(0, attack_time - delta)
		if attack_kind == "lineage":
			if not attack_hit and attack_time <= active_skill.recovery:
				attack_hit = true
				_release_lineage_skill(muzzle)
		elif not attack_hit and attack_time <= weapon_feel().duration - weapon_feel().release:
			attack_hit = true
			if is_ranged():
				var origin: Vector2 = muzzle if muzzle.is_finite() else position + Vector2(attack_facing * 35, -45)
				var travel := Vector2(attack_facing, 0)
				var closest := 650.0
				for enemy in enemies:
					var distance: float = (enemy.x - origin.x) * attack_facing
					if enemy.hp > 0 and distance > 0 and distance < closest:
						closest = distance
						travel = (Vector2(enemy.x, FLOOR_Y - 40) - origin).normalized()
				projectiles.append({"position": origin, "velocity": travel * 620, "direction": attack_facing, "life": 1.05, "power": attack_kind == "power", "impact_profile":attack_presentation.duplicate()})
			for enemy in enemies if not is_ranged() else []:
				var dx: float = (enemy.x - position.x) * attack_facing
				var reach: int = weapon_feel().reach
				if enemy.hp > 0 and dx >= -10 and dx <= reach and absf(position.y - FLOOR_Y) < 90:
					_damage_enemy(enemy, attack_kind == "power",-1,attack_presentation)
	for projectile in projectiles:
		var previous: Vector2 = projectile.position
		projectile.position += projectile.velocity * delta
		projectile.life -= delta
		# Sort along travel direction so a shot stops at the first living target.
		var targets := enemies.duplicate()
		targets.sort_custom(func(a, b): return a.x < b.x if projectile.direction > 0 else a.x > b.x)
		for enemy in targets:
			var center := Vector2(enemy.x, FLOOR_Y - 40)
			if enemy.hp > 0 and Geometry2D.get_closest_point_to_segment(center, previous, projectile.position).distance_to(center) < 32:
				if projectile.has("skill"): _hit_lineage_skill(enemy,projectile.skill)
				else: _damage_enemy(enemy, projectile.power,-1,projectile.get("impact_profile",{}))
				projectile.life = 0
				break
	projectiles = projectiles.filter(func(shot): return shot.life > 0)
	for enemy in enemies:
		_update_enemy(enemy, delta)
	if health > 0:
		for drop in loot:
			if not drop.collected and position.distance_to(drop.position) < 75:
				drop.collected = true
				inventory.grant(drop.reward)
				activity.emit("loot")
				events.append({"kind":"level", "text":drop.label, "position":position + Vector2(0,-150)})
		loot = loot.filter(func(drop): return not drop.collected)

func _impact_profile(power: bool, skill: Dictionary = {}) -> Dictionary:
	# Weapon proficiency is not implemented here yet. Use the relevant trained
	# discipline for presentation growth; never derive damage from the VFX tier.
	var discipline := "arcana" if skill.get("kind","") in ["bolt","slowbolt","rootbolt","drain"] or weapon in ["staff","branch_staff"] else "attack"
	var level: int = progression.level(discipline) if progression != null else adventure_level
	var result := MonsterImpact.profile(weapon,power,level,skill)
	result.direction = facing
	return result

func _damage_enemy(enemy: Dictionary, power: bool, explicit_damage := -1.0, presentation: Dictionary = {}) -> void:
	if enemy.hp <= 0:
		return
	var damage: int = mini(int(enemy.hp), roundi(explicit_damage if explicit_damage >= 0 else weapon_feel().damage * (2.1 if power else 1.0)))
	enemy.hp = maxf(0, enemy.hp - damage)
	if progression != null and explicit_damage < 0:
		progression.train_hit(damage,weapon in ["staff","branch_staff"],power)
	enemy.flash = .18
	var visual := presentation.duplicate() if not presentation.is_empty() else _impact_profile(power)
	visual.merge({"kind":"power" if power else "dealt", "text":str(damage), "position":Vector2(enemy.x, FLOOR_Y-105), "impact":Vector2(enemy.x,FLOOR_Y-40),"foot":Vector2(enemy.x,FLOOR_Y)},true)
	enemy.hit_direction = visual.direction
	enemy.hit_tier = visual.tier
	events.append(visual)
	if power:
		enemy.state = "recover"
		enemy.timer = .85
	if enemy.hp <= 0:
		kills += 1
		elite_defeated = elite_defeated or enemy.elite
		award_xp(100 if enemy.elite else 40)
		var reward := {"coins":30 if enemy.elite else 8, "hp":1, "mana":1, "items":[]}
		if enemy.elite:
			reward.items.append({"slot":"weapon", "id":"axe"})
		elif kills == 2:
			reward.items.append({"slot":"weapon", "id":"crossbow"})
		loot.append({"position":Vector2(enemy.x, FLOOR_Y), "collected":false, "reward":reward,
			"label":"+%d COINS · POTIONS%s" % [reward.coins, " · GEAR" if not reward.items.is_empty() else ""]})

func _update_enemy(enemy: Dictionary, delta: float) -> void:
	enemy.flash = maxf(0, enemy.flash - delta)
	enemy.rooted = maxf(0,enemy.get("rooted",0.0)-delta)
	enemy.slowed = maxf(0,enemy.get("slowed",0.0)-delta)
	if enemy.hp <= 0 or health <= 0:
		return
	var dx: float = position.x - enemy.x
	var movement := 0.0 if enemy.rooted > 0 else (.55 if enemy.slowed > 0 else 1.0)
	if enemy.state == "idle":
		enemy.facing = 1.0 if dx >= 0 else -1.0
		if absf(dx) < 108 and absf(position.y - FLOOR_Y) < 95:
			enemy.state = "windup"
			enemy.timer = 1.05 if enemy.elite else .8
		elif absf(dx) < 340 and absf(position.x - enemy.home) < 350:
			enemy.x += signf(dx) * (65 if enemy.elite else 90) * delta * movement
		else:
			enemy.x = move_toward(enemy.x, enemy.home, 70 * delta * movement)
		return
	enemy.timer -= delta
	if enemy.timer > 0:
		return
	if enemy.state == "windup":
		enemy.state = "strike"
		enemy.timer = .16
		# Direction locks at the warning: dodging behind or jumping can evade.
		if dx * enemy.facing >= -10 and dx * enemy.facing < 145 and absf(position.y - FLOOR_Y) < 85 and invulnerable <= 0:
			var damage := 28.0 if enemy.elite else 15.0
			var blocked: bool = guarding and -dx * facing > 0 and stamina >= 18
			if blocked:
				if progression != null: progression.award("defense",ceili(damage))
				stamina -= 18
				damage = roundf(damage * .2)
				blocks += 1
			elif guarding:
				guarding = false
				stamina = maxf(0, stamina - 18)
			var absorbed := minf(ward,damage)
			ward -= absorbed
			if progression != null and absorbed > 0: progression.award("focus",ceili(absorbed))
			damage = minf(health, damage-absorbed)
			health = maxf(0, health - damage)
			if progression != null: progression.award("stamina",ceili(damage))
			invulnerable = .25
			if absorbed > 0:
				events.append({"kind":"ward","text":"ABSORB %d"%absorbed,"position":position+Vector2(0,-150),"impact":position+Vector2(0,-85)})
			if blocked or damage > 0:
				events.append({"kind":"blocked" if blocked else "taken", "text":"BLOCK −%d" % damage if blocked else "−%d HP" % damage,"direction":signf(position.x-enemy.x), "position":position+Vector2(0,-150), "impact":position+Vector2(0,-85)})
			if health <= 0:
				projectiles.clear()
				death_time = 2
				attack_time = 0
				guarding = false
	elif enemy.state == "strike":
		enemy.state = "recover"
		enemy.timer = 1.1 if enemy.elite else .85
	else:
		enemy.state = "idle"

func complete() -> bool:
	return moved and jumped and (blocks > 0 or not can_guard) and kills >= 2
