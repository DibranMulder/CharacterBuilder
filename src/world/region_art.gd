extends RefCounted
## Terrain artwork and atlas palette. Navigation remains defined by catalog edges.
const PALETTES := {
	"open_lands":["284939","dbbd77"], "tidekin_sea":["183f49","91d4ca"],
	"elder_forests":["293d30","c9be80"], "sky_reaches":["303b63","e4d4a3"],
	"broken_mountains":["343d4b","d5ad76"], "underdeep":["303044","bbabdb"],
	"ember_desert":["503c30","efc17e"], "ice_lands":["273e55","c3e8ed"],
	"shattered_march":["433c47","d2b175"], "gloamfen":["263d3b","9fc4b4"],
	"ashen_scar":["493434","e9ad7c"], "verdant_maw":["293e2d","bdd27d"],
}
static var textures := {}
static var themes := {}
static func ink(id: String) -> Color: return Color(PALETTES.get(id,["183454","f2c45f"])[0])
static func accent(id: String) -> Color: return Color(PALETTES.get(id,["183454","f2c45f"])[1])
static func background(id: String) -> Texture2D:
	if not textures.has(id):
		textures[id] = load("res://assets/maps/regions/"+id+".png")
	return textures[id]
static func theme_for(id: String) -> Theme:
	var chronicle = preload("res://src/ui/chronicle_theme.gd")
	if id.is_empty(): return chronicle.create()
	if not themes.has(id):
		var result: Theme = chronicle.create().duplicate()
		for type in ["Button","PrimaryButton","QuietButton"]:
			for state in ["normal","hover","pressed","disabled"]:
				var frame = result.get_stylebox(state,type).duplicate()
				frame.textured = false
				frame.fill = ink(id).lightened(.15) if state == "hover" else ink(id)
				frame.border = accent(id).darkened(.15) if state == "disabled" else accent(id)
				result.set_stylebox(state,type,frame)
		for panel_type in ["InkPanel","ParchmentPanel"]:
			var frame = result.get_stylebox("panel",panel_type).duplicate()
			frame.textured = false
			result.set_stylebox("panel",panel_type,frame)
		result.set_color("font_color","ChronicleHeading",accent(id))
		themes[id] = result
	return themes[id]
