extends SceneTree
const Impact = preload("res://src/monster_impact.gd")
const Encounter = preload("res://prototypes/training_clearing/encounter.gd")
const Progress = preload("res://src/discipline_progress.gd")

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var effects := Impact.new()
	root.add_child(effects)
	var model := Encounter.new()
	model.weapon="axe"
	model.progression=Progress.new()
	model.progression.xp.attack=Progress.threshold(75)
	var target: Dictionary = model.enemies[0]
	var hp: float = target.hp
	model._damage_enemy(target,false)
	assert(target.hp==hp-28,"Presentation must preserve damage")
	var hit: Dictionary = model.events[0]
	assert(hit.effect=="earth" and hit.tier==1,"Basics cap at impact tier")
	assert(Impact.profile("axe",true,75).tier==2)
	var snapshot := [target.duplicate(true),model.progression.snapshot(),model.xp,model.kills]
	for kind in ["slash","rain","earth","ice","vines","wind","arcane"]:
		for tier in 3:
			effects.push({"kind":"power","effect":kind,"tier":tier,"foot":Vector2(600,480),"direction":-1})
	assert(effects.effects.size()==21)
	effects.advance(.4)
	assert(snapshot==[target,model.progression.snapshot(),model.xp,model.kills],"VFX cannot create damage, XP, displacement or statuses")
	effects.advance(2)
	assert(effects.effects.is_empty(),"All aftermath expires")
	for i in 80: effects.push(hit)
	assert(effects.effects.size()==Impact.LIMIT,"Concurrent effects are bounded")
	effects.reset()
	effects.push({"kind":"blocked","effect":"earth"})
	effects.push({"kind":"heal","effect":"rain"})
	assert(effects.effects.is_empty(),"Only monster hits emit impacts")
	# Ranged presentation is captured at activation, including facing and level.
	model=Encounter.new()
	model.weapon="crossbow"
	model.adventure_level=75
	model.position=Vector2(400,480)
	model.enemies[0].x=800.0
	model.enemies[0].home=800.0
	assert(model.begin_attack(false))
	model.step(.39,0,false,Vector2(430,440))
	assert(model.projectiles.size()==1)
	assert(model.projectiles[0].impact_profile.effect=="rain")
	model.weapon="axe"
	model.facing=-1
	model.step(.22,0,false)
	var received := false
	for event in model.events:
		if event.get("kind","")=="dealt":
			received=true
			assert(event.effect=="rain" and event.direction==1,"A later weapon/facing cannot replace the shot's effect")
	assert(received)
	# A missed swing does not create target effects.
	model=Encounter.new()
	assert(model.begin_attack())
	model.step(.5,0,false)
	assert(model.events.is_empty())
	var preview = load("res://prototypes/monster_effects.tscn").instantiate()
	root.add_child(preview)
	for mirrored in [false,true]:
		preview.mirrored=mirrored
		for index in preview.CASES.size():
			preview._select(index)
			for tier in 3:
				preview.tier=tier
				preview.play()
				preview._process(preview.release+.01)
				assert(preview.impacts.effects.size()==1)
				preview._stop()
				assert(preview.impacts.effects.is_empty() and not preview.avatar._gesturing)
	preview.free()
	var clearing = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	root.add_child(clearing)
	clearing.set_physics_process(false)
	clearing.model.weapon="axe"
	clearing.model.position=Vector2(540,480)
	clearing.model.progression.xp.attack=Progress.threshold(75)
	assert(clearing.model.begin_attack())
	clearing._physics_process(.44)
	assert(clearing.monster_impacts.effects.size()==1,"Clearing must consume real hit events")
	assert(clearing.monster_impacts.effects[0].effect=="earth")
	clearing.paused=true
	clearing._physics_process(.2)
	assert(clearing.monster_impacts.effects[0].age==0,"Pause freezes target effects")
	clearing._restart()
	assert(clearing.monster_impacts.effects.is_empty(),"Restart clears presentation")
	clearing.free()
	effects.free()
	print("PASS: target VFX tiers, budgets, expiration, damage/XP invariance, captured ranged source, misses, six previews both directions and cancellation")
	quit()
