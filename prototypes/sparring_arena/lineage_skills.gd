extends RefCounted
## Local combat experiments, not class permissions or production talent budgets.
## Builder gesture indices are presentation only, independent of combat effects.
const GESTURES := {
	"bogkin":[0,1,2,2], "human":[0,1,1,1],
	"centaur":[0,1,2,2], "fae":[0,1,2,2],
	"frost_troll":[0,2,1,1], "goblin":[0,2,1,0],
	"duneborn":[0,1,2,2], "frostling":[0,1,1,2],
}
const TRAINING := {"melee":"attack","dash":"strength","pulse":"strength","bolt":"arcana","slowbolt":"arcana","rootbolt":"arcana","drain":"arcana","retreat":"agility","heal":"focus","ward":"defense"}

static func common_skills() -> Array[Dictionary]:
	return [
		{"name":"Power Strike","kind":"melee","presentation":"forehand","power":38.0,"mana":25.0,"cooldown":5.0,"reach":145.0,"windup":.55,"recovery":.38,"description":"A committed frontal strike, available to every lineage.","requirements":{"attack":2,"strength":2}},
		{"name":"Arcane Bolt","kind":"bolt","presentation":"cast","power":25.0,"mana":18.0,"cooldown":4.0,"reach":580.0,"windup":.5,"recovery":.38,"description":"A focused magical projectile, available to every lineage.","requirements":{"arcana":2,"focus":2}},
	]

static func combat_kit(lineage: String) -> Array[Dictionary]:
	return kit(lineage)+common_skills()
## name, effect, power, mana, cooldown, reach, windup
const KITS := {
	"bogkin":[["Tongue Snap","melee",20,12,3,190,.32],["Lily Leap","dash",16,20,6,230,.38],["Bog Spit","slowbolt",14,18,7,560,.45],["Springwater","heal",26,28,14,0,.65]],
	"human":[["Crosscut","melee",28,18,4,145,.45],["Shield Rush","dash",18,22,7,210,.40],["Rally","ward",22,20,10,0,.40],["Second Wind","heal",28,30,15,0,.70]],
	"centaur":[["Gallop Strike","dash",24,24,7,270,.48],["Rearing Stomp","pulse",22,20,6,170,.55],["Briar Bind","rootbolt",12,22,9,530,.55],["Grove Renewal","heal",25,28,14,0,.65]],
	"fae":[["Gale Needle","bolt",20,14,3,620,.38],["Slipstream","retreat",0,18,6,170,.25],["Cyclone","pulse",23,24,8,200,.55],["Zephyr Veil","ward",24,22,11,0,.45]],
	"frost_troll":[["Boulder Fist","melee",32,20,5,155,.65],["Faultline","pulse",26,26,8,210,.70],["Stonehide","ward",32,24,12,0,.50],["Mountain Charge","dash",22,25,8,240,.55]],
	"goblin":[["Scrap Shot","bolt",18,12,3,580,.35],["Snare Canister","rootbolt",10,22,8,510,.50],["Smoke Hop","retreat",0,18,6,190,.25],["Siphon Dart","drain",20,24,9,520,.50]],
	"duneborn":[["Searing Thrust","melee",27,18,4,175,.45],["Dune Step","dash",18,20,6,240,.35],["Sandglass","slowbolt",18,22,8,560,.55],["Mirage Guard","ward",26,22,11,0,.40]],
	"frostling":[["Ice Shard","bolt",22,15,3.5,600,.45],["Rime Prison","rootbolt",14,24,9,530,.60],["Aurora Mend","heal",26,28,14,0,.70],["Winter Halo","pulse",24,24,8,190,.55]]
}
const HELP := {"melee":"Frontal strike; jump or guard the windup.","dash":"Rush forward and strike; stops at arena bounds.","pulse":"Close burst in both directions; knocks back.","bolt":"Aimed projectile; dodge or guard.","slowbolt":"Projectile slows movement by 45% for 2 seconds.","rootbolt":"Projectile roots for 0.8 seconds; guard prevents the root.","heal":"Restore HP after a vulnerable windup.","ward":"Absorb damage for 5 seconds; does not stack.","retreat":"Quick backward escape; grants no invulnerability.","drain":"Projectile restores half the HP damage dealt."}

static func kit(lineage: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in KITS.get(lineage,KITS.human):
		result.append({"name":row[0],"kind":row[1],"power":float(row[2]),"mana":float(row[3]),"cooldown":float(row[4]),"reach":float(row[5]),"windup":float(row[6]),"recovery":.38,"description":HELP[row[1]]})
		result[-1]["gesture"] = GESTURES.get(lineage,GESTURES.human)[result.size()-1]
		result[-1]["lineage"] = lineage
		var required: int = [1,3,5,8][result.size()-1]
		result[-1]["requirements"] = {TRAINING[row[1]]:required}
	return result
