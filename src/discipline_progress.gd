extends RefCounted
## Hero-owned progression. Gameplay reports outcomes; menus cannot award XP.
signal changed
const CATALOG := {
	"attack":["Attack","Martial","Land physical attacks."],
	"strength":["Strength","Martial","Deal physical damage."],
	"defense":["Defense","Martial","Block incoming attacks with a shield."],
	"agility":["Agility","Martial","Move while a living enemy is nearby."],
	"stamina":["Stamina","Martial","Survive HP damage in combat."],
	"focus":["Focus","Mystic","Land skills or restore missing HP with a skill."],
	"willpower":["Willpower","Mystic","Training awaits enemies with control attacks in the clearing."],
	"arcana":["Arcana","Mystic","Deal magical damage."],
	"survival":["Survival","World","Restore missing resources with potions."],
	"gathering":["Gathering","World","Harvesting activities are not implemented yet."],
	"crafting":["Crafting","World","Crafting activities are not implemented yet."],
	"exploration":["Exploration","World","Discover new sections of the clearing."],
}
var xp := {}
var discoveries := {}
var notices: Array[String] = []
var travel := 0.0

func _init() -> void:
	for id in CATALOG: xp[id] = 0

static func threshold(level: int) -> int:
	var n := clampi(level,1,99)-1
	return 75*n*n+25*n

func level(id: String) -> int:
	var result := 1
	while result < 99 and int(xp.get(id,0)) >= threshold(result+1): result += 1
	return result

func total_level() -> int:
	var total := 0
	for id in CATALOG: total += level(id)
	return total

func overall_level() -> int: return total_level()/12

func award(id: String, amount: int) -> void:
	if not xp.has(id) or amount <= 0 or level(id) == 99: return
	var before := level(id)
	xp[id] = mini(threshold(99),xp[id]+amount)
	if level(id) > before: notices.append("%s level %d"%[CATALOG[id][0],level(id)])
	changed.emit()

func allows(skill: Dictionary) -> bool:
	for id in skill.get("requirements",{}):
		if level(id) < skill.requirements[id]: return false
	return true

func requirement_text(skill: Dictionary) -> String:
	var parts: PackedStringArray = []
	for id in skill.get("requirements",{}):
		parts.append("%s %d / %d"%[CATALOG[id][0],level(id),skill.requirements[id]])
	return " · ".join(parts) if not parts.is_empty() else "Available from level 1"

func train_hit(damage: float, magical: bool, skill_hit: bool) -> void:
	if damage <= 0: return
	award("arcana" if magical else "attack",ceili(damage*2))
	if not magical: award("strength",ceili(damage))
	if skill_hit: award("focus",ceili(damage))

func explore(at: Vector2, in_combat: bool, moved: float) -> void:
	if in_combat:
		travel += minf(moved,15) # Exclude dash/teleport distance from movement XP.
		if travel >= 100:
			award("agility",int(travel/100)*10)
			travel = fmod(travel,100)
	var section := str(int(at.x/350))
	if not discoveries.has(section):
		discoveries[section] = true
		award("exploration",25)

func snapshot() -> Dictionary:
	return {"xp":xp.duplicate(),"discoveries":discoveries.duplicate()}

func restore(data: Dictionary) -> void:
	var saved: Variant = data.get("xp",{})
	if saved is Dictionary:
		for id in CATALOG:
			var value: Variant = saved.get(id,0)
			if value is int or value is float: xp[id] = clampi(int(value),0,threshold(99))
	if data.get("discoveries",{}) is Dictionary: discoveries = data.get("discoveries",{}).duplicate()
