extends SceneTree
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Model = preload("res://prototypes/tidekin_sea/region_encounter.gd")
var failed := false
func _initialize() -> void:
	var model = Model.new()
	model.configure_region(Region.spec("tidekin_sea_path_026"))
	# Exercise the real encounter hit path, including authored skill damage.
	var enemy: Dictionary = model.enemies[0]
	enemy.level = 30
	var hp: float = enemy.hp
	for i in 20:
		model._damage_enemy(enemy,true)
		model._damage_enemy(enemy,true,80)
	check(enemy.hp == hp,"level 1 cannot damage a level 30 monster with weapons or skills")
	check(enemy.state != "recover","outmatched attacks cannot stun-lock stronger monsters")
	model._hit_lineage_skill(enemy,{"kind":"rootbolt","power":80})
	check(enemy.get("rooted",0.0) == 0,"outmatched skills cannot root stronger monsters")
	model.health = 100
	model._hurt(enemy,Region.creature(enemy.species).damage)
	check(model.health <= 50,"level 30 attacks are dangerous to a level 1 hero")
	for spec in Region.maps():
		if spec.species.is_empty(): continue
		var peer = Model.new()
		peer.configure_region(spec)
		peer.adventure_level = maxi(1,int(spec.level))
		peer.boss_active = true
		for target in peer.enemies:
			var before: float = target.hp
			peer._damage_enemy(target,false)
			check(target.hp < before,"appropriate-level weapons damage " + spec.id)
			if not target.boss:
				check((before-target.hp)/target.max_hp >= .15,"ordinary equal-level fights remain reasonably short")
			peer.health = 100
			peer._hurt(target,Region.creature(target.species).damage)
			check(peer.health >= 80,"equal-level attacks remain survivable")
	if not failed: print("PASS: level gaps protect high-level monsters; peer combat remains playable")
	quit(1 if failed else 0)
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: " + message)
