extends SceneTree
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Model = preload("res://prototypes/tidekin_sea/region_encounter.gd")
var failed := false
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func run() -> void:
	var model = Model.new()
	model.configure_region(Region.spec("tidekin_sea_path_001"))
	var enemy: Dictionary = model.enemies[0]
	model.enemies.resize(1)
	model.position = Vector2(enemy.x,480)
	model.invulnerable = 0
	var hp: float = model.health
	model.step(1.0/60,0,false)
	check(model.health < hp,"walking into a hostile creature deals contact damage")
	hp = model.health
	model.step(1.0/60,0,false)
	check(model.health == hp,"contact respects damage immunity instead of hurting every frame")
	model.position.y = 300
	model.invulnerable = 0
	model.step(1.0/60,0,false)
	check(model.health == hp,"jumping clear of the creature avoids contact damage")
	model.position = Vector2(180,480)
	var start: float = enemy.x
	for i in 60: model.step(1.0/60,0,false)
	check(absf(enemy.x-start)>1,"unengaged creatures patrol instead of standing still")
	check(absf(enemy.x-enemy.home)<=100,"patrol stays near its spawn")
	for spec in Region.maps():
		var other = Model.new()
		other.configure_region(spec)
		for creature in other.enemies:
			if not creature.provoked or creature.boss:
				other.position = Vector2(creature.x,480)
				other.invulnerable = 0
				var before: float = other.health
				other._update_enemy(creature,1.0/60)
				check(other.health == before,"neutral creatures and dormant bosses do not deal contact damage")
	model.position = Vector2(enemy.x-25,480)
	model.velocity = Vector2.ZERO
	model.invulnerable = 0
	model.facing = 1
	model.health = 100
	model.step(1.0/60,0,true)
	check(model.blocks > 0 and model.health > 95,"facing guard reduces contact damage")
	enemy.rooted = 2
	model.position = Vector2(180,480)
	start = enemy.x
	model.step(.1,0,false)
	check(enemy.x == start,"roots prevent idle patrol movement")
	print("FAIL: Tidekin creature behavior" if failed else "PASS: hostile contact, immunity, jumping and bounded patrol")
	quit(1 if failed else 0)
