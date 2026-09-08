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
	if weapon == "none" or health <= 0 or attack_time > 0 or guarding:
		return false
	if power and (skill_cooldown > 0 or stamina < 25):
		return false
	attack_kind = "power" if power else "sword"
	attack_time = .88
	attack_hit = false
	attack_facing = facing
	if power:
		stamina -= 25
		skill_cooldown = 4.0
	return true

func jump() -> bool:
	if not grounded or health <= 0 or guarding:
		return false
	velocity.y = -560
	grounded = false
	jumped = true
	return true

func step(delta: float, direction: float, guard_held: bool) -> void:
	events.clear()
	skill_cooldown = maxf(0, skill_cooldown - delta)
	invulnerable = maxf(0, invulnerable - delta)
	if health <= 0:
		death_time -= delta
		if death_time <= 0:
			position = Vector2(160, FLOOR_Y)
			velocity = Vector2.ZERO
			health = 100
			stamina = 100
			invulnerable = 2
			for enemy in enemies:
				if enemy.hp > 0:
					enemy.x = enemy.home
					enemy.hp = enemy.max_hp
					enemy.state = "idle"
					enemy.timer = 0.0
			events.append({"text": "Recovered in the same clearing", "position": position})
		return
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
		var release := .5 if weapon == "bow" else (.38 if weapon == "crossbow" else (.3 if weapon in ["staff", "branch_staff"] else .39))
		if not attack_hit and attack_time <= .88 - release:
			attack_hit = true
			if is_ranged():
				projectiles.append({"position": position + Vector2(attack_facing * 35, -45), "direction": attack_facing, "life": 1.0, "power": attack_kind == "power"})
			for enemy in enemies if not is_ranged() else []:
				var dx: float = (enemy.x - position.x) * attack_facing
				var reach := 180 if weapon == "spear" else 140
				if enemy.hp > 0 and dx >= -10 and dx <= reach and absf(position.y - FLOOR_Y) < 90:
					_damage_enemy(enemy, attack_kind == "power")
	for projectile in projectiles:
		var previous_x: float = projectile.position.x
		projectile.position.x += projectile.direction * 620 * delta
		projectile.life -= delta
		# Sort along travel direction so a shot stops at the first living target.
		var targets := enemies.duplicate()
		targets.sort_custom(func(a, b): return a.x < b.x if projectile.direction > 0 else a.x > b.x)
		for enemy in targets:
			if enemy.hp > 0 and enemy.x >= minf(previous_x, projectile.position.x) - 30 and enemy.x <= maxf(previous_x, projectile.position.x) + 30 and absf(projectile.position.y - (FLOOR_Y - 40)) < 45:
				_damage_enemy(enemy, projectile.power)
				projectile.life = 0
				break
	projectiles = projectiles.filter(func(shot): return shot.life > 0)
	for enemy in enemies:
		_update_enemy(enemy, delta)

func _damage_enemy(enemy: Dictionary, power: bool) -> void:
	var damage := 42 if power else 20
	enemy.hp = maxf(0, enemy.hp - damage)
	enemy.flash = .18
	events.append({"text": str(damage), "position": Vector2(enemy.x, FLOOR_Y - 100)})
	if power:
		enemy.state = "recover"
		enemy.timer = .85
	if enemy.hp <= 0:
		kills += 1
		elite_defeated = elite_defeated or enemy.elite

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
				damage *= .2
				blocks += 1
			elif guarding:
				guarding = false
				stamina = maxf(0, stamina - 18)
			health = maxf(0, health - damage)
			invulnerable = .25
			events.append({"text": "BLOCK" if blocked else "−%d" % damage, "position": position + Vector2(0, -150)})
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
