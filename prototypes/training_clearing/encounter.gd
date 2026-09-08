extends RefCounted
## Local, throwaway gameplay model. Does sword/guard combat feel readable?
## No networking, persistence, inventory, or production progression.

const FLOOR_Y := 480.0
const WORLD_WIDTH := 2200.0
const PLATFORMS := [Rect2(710, 390, 170, 18), Rect2(950, 325, 150, 18)]
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
	return {"kind":"xp" if kind == "hp" else "notice", "text":"+%d %s" % [restored, kind.to_upper()], "position":position + Vector2(0,-150)}

func change_equipment(index: int, slot := "") -> bool:
	if health <= 0 or attack_time > 0 or not projectiles.is_empty():
		return false
	var changed: bool = inventory.equip(index) if slot.is_empty() else inventory.unequip(slot)
	if changed:
		configure_equipment(inventory.equipped)
		guarding = false
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
		var elite: bool = spec[1]
		enemies.append({"x": spec[0], "home": spec[0], "hp": 120.0 if elite else 50.0,
			"max_hp": 120.0 if elite else 50.0, "elite": elite, "state": "idle",
			"timer": 0.0, "facing": -1.0, "flash": 0.0})

func begin_attack(power := false) -> bool:
	last_rejection = ""
	if weapon == "none" or health <= 0 or attack_time > 0 or guarding:
		return false
	if power and skill_cooldown > 0:
		return false
	if mana < mana_cost(power):
		last_rejection = "NOT ENOUGH MANA"
		return false
	attack_kind = "power" if power else "sword"
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
	potion_cooldown = maxf(0, potion_cooldown - delta)
	skill_cooldown = maxf(0, skill_cooldown - delta)
	invulnerable = maxf(0, invulnerable - delta)
	if health <= 0:
		death_time -= delta
		if death_time <= 0:
			position = Vector2(160, FLOOR_Y)
			velocity = Vector2.ZERO
			health = 100
			mana = 100
			stamina = 100
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
	position.x = clampf(position.x + velocity.x * delta, 40, WORLD_WIDTH - 40)
	velocity.y += 1500 * delta
	position.y += velocity.y * delta
	grounded = false
	if velocity.y >= 0:
		var landing_y := FLOOR_Y
		for platform in PLATFORMS:
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
		if not attack_hit and attack_time <= weapon_feel().duration - weapon_feel().release:
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
				projectiles.append({"position": origin, "velocity": travel * 620, "direction": attack_facing, "life": 1.05, "power": attack_kind == "power"})
			for enemy in enemies if not is_ranged() else []:
				var dx: float = (enemy.x - position.x) * attack_facing
				var reach: int = weapon_feel().reach
				if enemy.hp > 0 and dx >= -10 and dx <= reach and absf(position.y - FLOOR_Y) < 90:
					_damage_enemy(enemy, attack_kind == "power")
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
				_damage_enemy(enemy, projectile.power)
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
				events.append({"kind":"level", "text":drop.label, "position":position + Vector2(0,-150)})
		loot = loot.filter(func(drop): return not drop.collected)

func _damage_enemy(enemy: Dictionary, power: bool) -> void:
	if enemy.hp <= 0:
		return
	var damage: int = mini(int(enemy.hp), roundi(weapon_feel().damage * (2.1 if power else 1.0)))
	enemy.hp = maxf(0, enemy.hp - damage)
	enemy.flash = .18
	events.append({"kind":"power" if power else "dealt", "text":str(damage), "position":Vector2(enemy.x, FLOOR_Y-105), "impact":Vector2(enemy.x,FLOOR_Y-40)})
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
	if enemy.hp <= 0 or health <= 0:
		return
	var dx: float = position.x - enemy.x
	if enemy.state == "idle":
		enemy.facing = 1.0 if dx >= 0 else -1.0
		if absf(dx) < 108 and absf(position.y - FLOOR_Y) < 95:
			enemy.state = "windup"
			enemy.timer = 1.05 if enemy.elite else .8
		elif absf(dx) < 340 and absf(position.x - enemy.home) < 350:
			enemy.x += signf(dx) * (65 if enemy.elite else 90) * delta
		else:
			enemy.x = move_toward(enemy.x, enemy.home, 70 * delta)
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
				stamina -= 18
				damage = roundf(damage * .2)
				blocks += 1
			elif guarding:
				guarding = false
				stamina = maxf(0, stamina - 18)
			damage = minf(health, damage)
			health = maxf(0, health - damage)
			invulnerable = .25
			events.append({"kind":"blocked" if blocked else "taken", "text":"BLOCK −%d" % damage if blocked else "−%d HP" % damage, "position":position+Vector2(0,-150), "impact":position+Vector2(0,-85)})
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
