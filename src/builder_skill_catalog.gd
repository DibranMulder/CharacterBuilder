extends RefCounted
## Builder presentation catalog from DESIGN-0018, 0020 and 0021.
## Unlocks are informative here; previewing never grants combat progression.

const HUMAN := [
	{"id":"human_crosscut", "name":"Crosscut", "source":"Human lineage", "unlock":"Overall 1 · Attack 1", "description":"Two short crossing strikes against one target. Works unarmed; equipped gear follows the hands.", "stats":"14 mana · 6s cooldown · 0.9P total"},
	{"id":"human_resolute_rush", "name":"Resolute Rush", "source":"Human lineage", "unlock":"Overall 15 · Stamina 5", "description":"Commit to a forward shoulder rush. An equipped shield stays visible; the innate skill does not require one.", "stats":"20 mana · 12s cooldown · 0.65P impact"},
	{"id":"human_rally", "name":"Rally", "source":"Human lineage", "unlock":"Overall 35 · Stamina 15", "description":"Raise gold pennants into a temporary ward. Pressure exhausts the protection; it grants no damage bonus.", "stats":"22 mana · 18s cooldown · 0.9P ward / 4s"},
	{"id":"human_second_wind", "name":"Second Wind", "source":"Human lineage", "unlock":"Overall 60 · Stamina 30", "description":"Gather a warm breath, then recover over three seconds within a gold laurel. The preparation leaves you vulnerable.", "stats":"28 mana · 26s cooldown · 1.1P healing / 3s"},
]
const SWORD := [
	{"id":"sword_basic_slash", "name":"Basic Slash", "source":"Sword proficiency", "unlock":"Sword 1", "description":"A clean foundational cut with a narrow ivory trail."},
	{"id":"sword_quick_cut", "name":"Quick Cut", "source":"Sword proficiency", "unlock":"Sword 5 · Attack 3", "description":"A fast, low-commitment rising cut with a short steel spark."},
	{"id":"sword_heavy_cut", "name":"Heavy Cut", "source":"Sword proficiency", "unlock":"Sword 15 · Strength 10", "description":"A deliberate overhead wind-up releases a weighted amber cut."},
	{"id":"sword_pommel_strike", "name":"Pommel Strike", "source":"Sword proficiency", "unlock":"Sword 30 · Attack 20", "description":"Reverse the grip and drive the pommel forward for a short interruption."},
	{"id":"sword_sweeping_edge", "name":"Sweeping Edge", "source":"Sword proficiency", "unlock":"Sword 50 · Attack 30 · Strength 25", "description":"A broad cutting sweep traces a single gold-edged ribbon through nearby targets."},
	{"id":"sword_guarded_riposte", "name":"Guarded Riposte", "source":"Sword proficiency", "unlock":"Sword 75 · Defense 40 · Shield equipped", "description":"Meet a blow with the shield, then return a sharp thrust. Preview includes a simulated block.", "shield":true},
	{"id":"sword_blade_rhythm", "name":"Blade Rhythm", "source":"Sword proficiency", "unlock":"Sword 99 · Attack 60 · Agility 40", "description":"Three measured beats: descending cut, rising cut, finishing thrust. A broken gold crown marks the finale."},
]

static func all() -> Array:
	return HUMAN + SWORD

static func find(id: String) -> Dictionary:
	for skill in all():
		if skill.id == id: return skill.duplicate(true)
	return {}

static func unavailable_reason(skill: Dictionary, avatar: Node) -> String:
	if skill.is_empty(): return "Unknown skill"
	if skill.id.begins_with("human_") and avatar.race_id != "human":
		return "Select Humans to preview this lineage skill."
	if skill.id.begins_with("sword_") and avatar.loadout.weapon != "sword":
		return "Equip a Sword to preview this technique."
	if skill.get("shield",false) and avatar.loadout.offhand not in ["shield","marsh_shield"]:
		return "Equip a Shield to preview Guarded Riposte."
	return ""
