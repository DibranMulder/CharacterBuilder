extends RefCounted
const Skills = preload("res://prototypes/sparring_arena/lineage_skills.gd")
const Feel = preload("res://prototypes/training_clearing/encounter.gd")
var lineage := "human"
var loadout := {}
var position := Vector2(250,470)
var velocity := Vector2.ZERO
var facing := 1.0
var health := 100.0
var mana := 100.0
var stamina := 100.0
var xp := 0
var adventure_level := 1
var grounded := true
var guarding := false
var ward := 0.0
var ward_time := 0.0
var slow := 0.0
var rooted := 0.0
var flash := 0.0
var jump_cooldown := 0.0
var action: Dictionary = {}
var action_time := 0.0
var released := false
var serial := 0
var cooldowns := [0.0,0.0,0.0,0.0,0.0,0.0]
var skills: Array[Dictionary] = []
var rejection := ""
var dealt := 0.0
var received := 0.0

func configure(id: String, outfit: Dictionary, spawn: Vector2) -> void:
	lineage = id
	loadout = outfit.duplicate()
	if not CharacterCatalog.supports_item(id,&"accessory",loadout.accessory): loadout.accessory = "none"
	position = spawn
	skills = Skills.combat_kit(id)

func xp_required() -> int: return 100

func can_guard() -> bool:
	return CharacterCatalog.is_shield(loadout.get("offhand","none"))

func basic() -> Dictionary:
	var weapon: String = loadout.get("weapon","none")
	var feel: Dictionary = Feel.WEAPON_FEEL.get(weapon,Feel.WEAPON_FEEL.sword)
	return {"name":"Attack","kind":"bolt" if weapon in ["bow","crossbow","staff","branch_staff"] else "melee","power":float(feel.damage),"mana":8.0 if weapon in ["staff","branch_staff"] else 0.0,"reach":float(feel.reach),"windup":maxf(.32,feel.duration-feel.release),"recovery":float(feel.release),"slot":-1}

func request(slot: int) -> bool:
	rejection = ""
	if health <= 0 or not action.is_empty() or guarding: return false
	if slot < -1 or slot >= skills.size(): return false
	if slot == -1 and loadout.get("weapon","none") == "none":
		rejection = "No weapon equipped"
		return false
	if slot >= 0 and cooldowns[slot] > 0: return false
	var next: Dictionary = basic() if slot < 0 else skills[slot].duplicate()
	if mana < next.mana:
		rejection = "Not enough mana"
		return false
	if next.kind == "heal" and health >= 100:
		rejection = "HP already full"
		return false
	if next.kind in ["dash","retreat"] and rooted > 0:
		rejection = "Rooted"
		return false
	mana -= next.mana
	if slot >= 0: cooldowns[slot] = next.cooldown
	action = next
	action.slot = slot
	action.facing = facing
	action_time = 0
	released = false
	serial += 1
	return true

func jump() -> void:
	if grounded and health > 0 and rooted <= 0 and jump_cooldown <= 0 and action.is_empty():
		velocity.y = -560
		grounded = false
		jump_cooldown = 1.1

func advance(delta: float, direction: float, guard: bool) -> bool:
	for i in cooldowns.size(): cooldowns[i] = maxf(0,cooldowns[i]-delta)
	for field in ["slow","rooted","flash","ward_time","jump_cooldown"]:
		set(field,maxf(0,float(get(field))-delta))
	if ward_time <= 0: ward = 0
	guarding = guard and can_guard() and stamina > 0 and action.is_empty() and grounded
	stamina = clampf(stamina+(10 if not guarding else -5)*delta,0,100)
	mana = minf(100,mana+4*delta)
	if not action.is_empty(): direction = 0
	if absf(direction) > .1: facing = signf(direction)
	velocity.x = direction*205*(.55 if slow > 0 else 1.0)*(.35 if guarding else 1.0)
	if rooted > 0: velocity.x = 0
	velocity.y += 1200*delta
	position += velocity*delta
	position.x = clampf(position.x,65,1087)
	if position.y >= 470:
		position.y = 470
		velocity.y = 0
		grounded = true
	if action.is_empty(): return false
	action_time += delta
	if not released and action_time >= action.windup:
		released = true
		return true
	if action_time >= action.windup+action.recovery: action = {}
	return false

func attack_animation() -> StringName:
	match loadout.get("weapon","none"):
		"bow": return &"fire_bow"
		"crossbow": return &"fire_crossbow"
		"staff","branch_staff": return &"cast_spell"
		"spear": return &"jab"
	return &"forehand"
