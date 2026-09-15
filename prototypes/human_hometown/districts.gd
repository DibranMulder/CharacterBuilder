extends RefCounted
## Authored Human map graph from DESIGN-0014. Portal positions are physical world positions.
const Town = preload("res://prototypes/human_hometown/town.gd")
const Market = preload("res://prototypes/human_hometown/market.gd")
const NAMES := {"square":"Village Square","market":"Market Row","apothecary":"Apothecary Lane","trainers":"Trainers' Yard","inn":"Hearth Inn","approach":"Stronghold Approach","gatehouse":"Gatehouse Court","barracks":"Warden Barracks","service":"Service District","hall":"Great Hall","king":"The King's Room","archive":"Treasury and Archive","tower":"Tower Base","stair":"Winding Stair","solar":"The Solar"}
const EDGES := [["square","market"],["square","apothecary"],["square","trainers"],["trainers","inn"],["square","approach"],["approach","gatehouse"],["gatehouse","barracks"],["gatehouse","service"],["barracks","hall"],["hall","king"],["hall","archive"],["hall","tower"],["tower","stair"],["stair","solar"]]
const VILLAGE := ["square","market","apothecary","trainers","inn","approach"]
const LIGHT := ["human","fae","centaur","bogkin"]
const QUEST := ["Speak to Lorekeeper Elowen in Village Square.","Ask Archivist Meriel about the seal in Treasury and Archive.","Collect the warden key from Captain Aldren in Warden Barracks.","Climb the Princess's Tower and speak to Heir-Warden Lyra.","Return to Lorekeeper Elowen with Lyra's message.","The sealed light is safe. Wendmere's roads remain open."]

static func spec(id: String) -> Dictionary:
	var result: Dictionary = (Market.SPEC if id == "market" else Town.SPEC).duplicate(true)
	result.id = "wendmere_"+id
	result.name = NAMES[id]
	result.sentries = [230.0,2200.0] if id in ["square","approach","gatehouse"] else []
	result.platforms = []
	result.climbs = []
	result.portals = portals(id)
	result.theme = "village" if id in VILLAGE else ("tower" if id in ["tower","stair","solar"] else "keep")
	if id not in ["square","market"]:
		result.art = "res://assets/maps/wendmere/"+id+".png"
		result.merchant_x = 700.0
	# Side roads sit on raised landings, leaving the main street free to explore.
	for portal in result.portals:
		if portal.y < 480:
			var count := int((480-portal.y)/70)
			for step in count:
				result.platforms.append(Rect2(portal.x-100*(count-step),410-step*70,120,18))
			result.platforms.append(Rect2(portal.x-25,portal.y,210,22))
	if id in ["approach","trainers","market","apothecary"]:
		result.platforms.append(Rect2(640,410,230,22))
		result.platforms.append(Rect2(890,340,220,22))
		result.platforms.append(Rect2(1130,270,270,22))
	if id == "stair":
		result.platforms.clear()
		for step in 10:
			result.platforms.append(Rect2(420+step*150,410-step*70,200,22))
		result.platforms.append(Rect2(1850,-220,500,24))
		result.climbs = [Rect2(2010,-220,48,700)]
	if id in ["barracks","archive","inn","solar"]:
		result.platforms.append(Rect2(900,340,650,24))
		result.climbs.append(Rect2(970,340,48,140))
	# Optional routes belong to the district architecture, with a floor-level return.
	# Every rise is 70 px, below the ordinary jump's ~100 px apex.
	var routes := {"market":["Awning walk",5],"apothecary":["Herb terraces",6],
		"trainers":["Footwork course",4],"approach":["Orchard walls",5],
		"service":["Workshop galleries",4],"tower":["Bell landings",8],
		"archive":["Upper stacks",6],"solar":["Observatory balcony",4]}
	result.lookout = {}
	if routes.has(id):
		var route: Array = routes[id]
		for step in int(route[1]):
			result.platforms.append(Rect2(420+step*150,410-step*70,220,22))
		var top: Rect2 = result.platforms.back()
		result.lookout = {"name":route[0],"position":Vector2(top.get_center().x,top.position.y)}
		# A rope down makes the long tower/stack route convenient to retrace.
		if int(route[1]) >= 6:
			result.climbs.append(Rect2(top.end.x-65,top.position.y,40,480-top.position.y))
	return result

static func portals(id: String) -> Array:
	var destinations: Array = []
	for edge in EDGES:
		if edge[0] == id: destinations.append(edge[1])
		elif edge[1] == id: destinations.append(edge[0])
	var result: Array = []
	for i in destinations.size():
		var destination: String = destinations[i]
		var x := 70.0 if i == 0 else 2330.0
		var y := 480.0
		if id == "square":
			x = [70.0,650.0,1250.0,1930.0][i]
			y = 480.0 if i == 0 else 270.0
		elif id == "market": x = 2330.0
		elif i > 1:
			x = 850.0 if i == 2 else 1650.0
			y = 270.0
		if id == "stair" and destination == "solar": y = -220.0
		result.append({"to":destination,"x":x,"y":y})
	return result

static func allowed(destination: String, lineage: String, quest_stage: int) -> String:
	if destination not in VILLAGE and lineage not in LIGHT:
		return "The Waystone Guardian warns: only Light-aligned heroes may enter the Keep."
	if destination in ["tower","stair","solar"] and quest_stage < 3:
		return "The tower is sealed. Follow Elowen's lead and obtain the warden key."
	return ""

static func npc(id: String, name_: String, role: String, x: float, greeting: String, weapon := "none", armor := "cloth") -> Dictionary:
	return {"id":id,"name":name_,"role":role,"x":x,"greeting":greeting,"gear":{"weapon":weapon,"armor":armor,"head":"none","offhand":"none"},"stock":[]}

static func residents(id: String) -> Array:
	match id:
		"market": return Market.MERCHANTS.duplicate(true)
		"square": return [npc("elowen","Elowen","Lorekeeper",1050,"The heir-warden sealed her tower to contain a light from the Archive.\nFind Archivist Meriel inside the Keep. She knows what happened.","staff"),npc("broker","Perrin","Exchange Broker",590,"I keep the ledgers of Wendmere's travelling merchants.\nThe Exchange awaits a connected market; no orders can be placed yet.")]
		"apothecary": return [npc("mira","Mira","Apothecary",700,"Mending Salve · Vigor Draught · Focusing Tonic · Antidote\nReliable remedies. Ask about the herb terraces.","branch_staff"),npc("grocer","Bramble","Provisioner",1660,"Waybread, torches and climbing rope for the road.\nThe old orchard terraces are a fine place to practise your footing.")]
		"trainers":
			var result: Array = []
			var roles := ["Vanguard","Ravager","Ranger","Duelist","Arcanist","Warden"]
			var weapons := ["sword","axe","bow","sword","staff","branch_staff"]
			var names := ["Hale","Runa","Ash","Nessa","Iven","Soleil"]
			for i in 6: result.append(npc("trainer_"+str(i),names[i],roles[i]+" Trainer",360+i*330,"Practise your footing on the yard's raised platforms.\nOpen Skills (L) to inspect your actions and training progress.",weapons[i]))
			return result
		"inn": return [npc("innkeeper","Maren","Innkeeper",720,"The Hearth is open to every traveller. Take a quiet moment.\nYour recovery point stays in the map you are exploring."),npc("quartermaster","Odo","Quartermaster",1650,"I keep the caravan manifests. Your pouch travels with you.\nDurable storage is not available yet.","sword","leather")]
		"approach": return [npc("orchard","Tamsin","Orchard Keeper",640,"These old farm terraces lead toward the King's Keep.\nJump the low walls, or follow the orchard road."),npc("guardian","Old Road Warden","Waystone Guardian",1990,"Wendmere welcomes everyone. The Keep is sworn to the Light.\nI will turn opposing allegiance away at the gate.","spear","plate")]
		"gatehouse": return [npc("gatecaptain","Beren","Gate Captain",710,"The barracks are along the road. The service court is above.\nCaptain Aldren keeps the tower keys.","spear","plate"),npc("courier","Wren","Royal Courier",1640,"I carried the last letter down from the tower.\nLyra said the seal was holding. I hope she is still safe.")]
		"barracks": return [npc("aldren","Aldren","Warden Captain",720,"Meriel sent you? Then take the warden key.\nThe tower door is above the Great Hall.","sword","plate"),npc("recruit","Finch","Warden Recruit",1630,"I train on the gallery each morning. The ladder gets you up.\nA Hillkeep Gargoyle has been sighted beyond our outer walls.","spear","leather")]
		"service": return [npc("cook","Ada","Keep Cook",740,"No warden goes hungry on my watch.\nWould that the heir-warden would come down for supper."),npc("smith","Torren","Keep Smith",1620,"The wardens need hinges as often as swords.\nI am repairing the Archive's old brass fittings.","axe","leather")]
		"hall": return [npc("herald","Cerys","Royal Herald",600,"The King's Room lies east. The Archive and tower are upstairs.\nElowen's investigation may open the sealed tower door.","sword"),npc("steward","Oswin","Keep Steward",1250,"These banners mark the roads that bind the Open Lands.\nEvery village has a place beneath them.")]
		"king": return [npc("king","The Oathbound King","Keeper of the Roads",1300,"A crown is a promise to keep the roads open.\nBring our heir-warden home safely.","sword","plate"),npc("counsellor","Edda","Royal Counsellor",650,"The king waits for word from the tower.\nThe Archive may hold the answer.","staff")]
		"archive": return [npc("meriel","Meriel","Archivist",750,"The light is a protective ward, not a weapon. Lyra is containing it.\nAsk Captain Aldren for the key, then carry these notes to her.","staff"),npc("treasurer","Corvin","Treasurer",1690,"These ledgers record every repaired mile of road.\nThe sealed shelves upstairs hold the oldest warden accounts.")]
		"tower": return [npc("keeper","Ansel","Tower Keeper",760,"The heir-warden waits in the Solar.\nTake the winding landings upward. The rope offers another route.","staff")]
		"stair": return [npc("lamplighter","Pip","Lamplighter",690,"I keep the lower lamps lit for Lyra.\nJump from landing to landing; climb the rope with Up and Down.")]
		"solar": return [npc("lyra","Lyra","Heir-Warden",1370,"Meriel's notes! Now I can steady the ward without holding it alone.\nTell Elowen the Archive is safe. Thank you for climbing all this way.","staff"),npc("attendant","Seren","Warden Attendant",680,"The windows look over every road to Wendmere.\nThe portal west returns to the stair; you are never trapped here.")]
	return []
