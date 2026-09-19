extends RefCounted
## Tidewharf's named residents and the shared hometown service roster.
const Market = preload("res://prototypes/human_hometown/market.gd")
const PEOPLE := {
	"land":[["tavi","Ferrymaster Tavi","Ferry guide","Coast Road leads to Open Lands; Coastal Rootway to Elder Forests. Tidal Currents lie beyond Outer Sluiceway. The outer-sea berths lead to veteran waters: read their level warnings.","none"]],
	"lag":[["sera","Tidemender Sera","Lorekeeper","Salt has reached our wells. Take three sample bottles to Siltbank Shallows and clear the runnels. Bring the samples to Engineer Mero in Cistern Works.","staff"],["lagoon_sentry","Lagoon Sentry","Sentry","Market and apothecary lie around the lagoon. The dry boardwalk leads to the Divers' Yard and the Tidal Gate Causeway.","spear"]],
	"cm":[["neri","Neri","Weaponsmith","Reliable arms for the shore roads. Choose a weapon that suits your training.","axe"],["brineweft","Brineweft","Armorer","Salt is hard on armor. A shield and a sound coat will serve you well.","sword"],["ossa","Ossa","Provisioner","Supplies for a day on the coast. Keep healing and focus potions close.","none"],["pel","Broker Pel","Exchange Broker","The Exchange is the shared player market. Player listings are not available in this local town yet.","none"],["lume","Lume","Wandwright","Driftwood staves, spellbooks and a little light for the journey.","staff"]],
	"ka":[["vela","Apothecary Vela","Apothecary","Take water samples from separate runnels; mixing them hides the source. These restorative supplies match the other hometowns.","branch_staff"]],
	"dy":[["tal","Tal","Vanguard Trainer","Hold a shield toward the danger and leave stamina for the next blow.","sword"],["rusk","Rusk","Ravager Trainer","A heavy strike needs a safe opening. Watch the creature recover before committing.","axe"],["fenn","Fenn","Ranger Trainer","Read the shoreline and keep room to move. Your bow cannot overcome every level gap.","bow"],["suri","Suri","Duelist Trainer","Step behind a committed attack, then strike from an opening.","sword"],["ilun","Ilun","Arcanist Trainer","Your staff carries spells, but your mana and timing determine how long you can fight.","staff"],["mara","Mara","Warden Trainer","Protect allies with a ward and choose when to restore them. All lineages can use the dry training deck.","branch_staff"]],
	"inn":[["pell","Innkeeper Pell","Innkeeper","Welcome to Foamrest. Your recovery anchor stays in the map you are exploring. Sit a while and review your journey.","none"],["toma","Quartermaster Toma","Quartermaster","Keep provisions in your pouch. The durable bank service is not available here yet.","none"]],
	"caus":[["nacre","Reefwarden Nacre","Stronghold Guardian","I am bonded to these tidal gates. Pearl Citadel admits Light allegiance. All travelers may return safely to the lagoon.","none"],["gate_sentry","Gate Sentry","Sentry","The center of the causeway stays dry at every tide. The public shore roads remain open to everyone.","spear"]],
	"gs":[["iri","Shell Captain Iri","Captain","Welcome to the Gatehall of Shells. Find the Reefguard in the barracks, Mero at the cistern, and Amaya in Pearl Hall.","spear"]],
	"rb":[["sen","Reefguard Sen","Reefguard","An eel marks a wet lane before its pulse. Jump to dry footing or move beyond the marked lane. Never stand still in the current.","spear"]],
	"cw":[["mero","Engineer Mero","Engineer","The intake is damaged. Show me the sample from Siltbank Shallows, then seek Archivist Coru's original conduit sequence.","none"]],
	"ph":[["amaya","Steward Amaya","Steward","Bring Mero's intake diagram and Coru's rubbing. Then I can authorize your descent into the Sunken Shrine.","none"]],
	"tc":[["speaker","The Tide Speaker","Tide Speaker","The regulator keeps our freshwater separate from the sea. Its restoration means clean wells for every household, not a victory over an enemy.","staff"]],
	"dv":[["coru","Archivist Coru","Archivist","The old conduit sequence is Shell, Wave, Pearl. Compare it with Mero's diagram before asking Amaya to open the shrine.","staff"]]
}
static func for_map(id: String, width: float) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var rows: Array = PEOPLE.get(id.trim_prefix("tidekin_sea_"),[])
	for i in rows.size():
		var row: Array = rows[i]
		var stock: Array = []
		if row[2] == "Weaponsmith": stock = Market.MERCHANTS[0].stock.duplicate(true)
		elif row[2] == "Armorer": stock = Market.MERCHANTS[1].stock.duplicate(true)
		elif row[2] == "Wandwright": stock = Market.MERCHANTS[2].stock.duplicate(true)
		elif row[2] in ["Apothecary","Provisioner"]: stock = [{"slot":"potion","id":"hp","price":6},{"slot":"potion","id":"mana","price":6}]
		var kind := portrait_for(row[0],row[2])
		result.append({"id":row[0],"name":row[1],"role":row[2],"greeting":row[3],"stock":stock,"portrait":kind,"x":lerpf(650,width-650,float(i+1)/(rows.size()+1)),"phase":float(i)*1.7,"facing":1.0,"moving":false})
		if row[0] == "tavi": result.back().x = 700.0
		result.back()["home"] = result.back().x
	return result

static func portrait_for(id: String, role: String) -> int:
	if id == "nacre": return 7
	if role in ["Captain","Reefguard","Sentry","Vanguard Trainer","Ravager Trainer","Duelist Trainer"]: return 3
	if role in ["Apothecary","Lorekeeper","Warden Trainer","Arcanist Trainer","Wandwright"]: return 2
	if role in ["Engineer","Weaponsmith","Armorer"]: return 4
	if role in ["Archivist","Steward","Tide Speaker"]: return 5
	if role == "Innkeeper": return 6
	if role in ["Exchange Broker","Provisioner","Quartermaster"]: return 1
	return 0

static func advance(people: Array[Dictionary], delta: float, clock: float, hero: Vector2, conversing: bool) -> void:
	for person in people:
		person.moving = false
		if conversing or absf(hero.x-person.x)<140:
			if absf(hero.x-person.x)>5: person.facing = signf(hero.x-person.x)
			continue
		if person.id == "nacre": continue
		# Short trips between work stations, with a pause at each end. Simulation
		# advances independently of culling; residents stay near their service.
		var cycle := fmod(clock+person.phase,20.0)
		var target: float = person.get("walk_right",person.home+65.0) if cycle<10 else person.get("walk_left",person.home-65.0)
		if cycle<4 or (cycle>=10 and cycle<14):
			var before: float = person.x
			person.x = move_toward(person.x,target,delta*32)
			person.moving = absf(person.x-before)>.001
			if person.moving: person.facing = signf(person.x-before)

static func place(people: Array[Dictionary], objects: Array, width: float) -> void:
	var blocked: Array[Vector2] = []
	for object in objects:
		if object.surface=="street": blocked.append(Vector2(object.rect[0]-45,object.rect[0]+object.rect[2]+45))
	blocked.sort_custom(func(a,b): return a.x<b.x)
	var gaps: Array[Vector2] = []
	var left := 160.0
	for interval in blocked:
		if interval.x-left>85: gaps.append(Vector2(left,interval.x))
		left = maxf(left,interval.y)
	if width-160-left>85: gaps.append(Vector2(left,width-160))
	for person in people:
		if person.id=="nacre" or gaps.is_empty(): continue
		var nearest := 0
		var distance := INF
		for i in gaps.size():
			var center: float = (gaps[i].x+gaps[i].y)*.5
			if absf(center-person.home)<distance:
				distance=absf(center-person.home)
				nearest=i
		var gap: Vector2 = gaps.pop_at(nearest)
		person.x = (gap.x+gap.y)*.5
		person.home = person.x
		person.walk_left = maxf(gap.x,person.home-65)
		person.walk_right = minf(gap.y,person.home+65)
