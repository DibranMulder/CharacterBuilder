extends SceneTree
const Encounter = preload("res://prototypes/training_clearing/encounter.gd")

func _initialize() -> void:
	var model = Encounter.new()
	assert(model.begin_attack(true))
	assert(model.mana == 75 and model.stamina == 100)
	assert(not model.begin_attack(true) and model.mana == 75)
	model.step(.5, 0, false)
	assert(model.mana == 75, "regen must wait after spending")
	model.attack_time = 0
	model.skill_cooldown = 0
	model.mana = 24
	assert(not model.begin_attack(true))
	assert(model.last_rejection == "NOT ENOUGH MANA")
	assert(model.skill_cooldown == 0 and model.mana == 24)
	model.weapon = "staff"
	assert(model.begin_attack() and model.mana == 16)
	model.attack_time = 0
	model.weapon = "bow"
	assert(model.begin_attack() and model.mana == 16)
	model.mana = 99
	model.mana_delay = 0
	model.step(.5, 0, false)
	assert(model.mana == 100)
	model = Encounter.new()
	model.enemies[0].hp = 1
	model._damage_enemy(model.enemies[0], false)
	assert(model.xp == 40 and model.kills == 1)
	assert(model.events[0].kind == "dealt" and model.events[0].text == "1")
	model._damage_enemy(model.enemies[0], true)
	assert(model.xp == 40 and model.kills == 1, "dead targets cannot reward twice")
	model.award_xp(100)
	assert(model.adventure_level == 2 and model.xp == 40 and model.xp_required() == 200)
	for blocked in [false, true]:
		model = Encounter.new()
		model.position.x = 550
		model.guarding = blocked
		model.enemies[0].state = "windup"
		model.enemies[0].timer = 0
		model._update_enemy(model.enemies[0], .01)
		assert(model.health == (97 if blocked else 85))
		assert(model.events[0].kind == ("blocked" if blocked else "taken"))
	model.health = 0
	model.death_time = .01
	model.mana = 0
	model.step(.02, 0, false)
	assert(model.health == 100 and model.mana == 100)
	assert(model.position == Vector2(160,480))
	print("PASS: mana costs, rejection, regeneration, XP, damage categories and local respawn")
	quit()
