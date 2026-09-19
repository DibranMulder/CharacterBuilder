# Tidekin Sea — moodboard-led revision

Reference: [Tidekin culture moodboard](../moodboards/tidekin.png), especially the Tidewharf waterfront, equipment/material studies, palette, and drowned ruins along the bottom. This revision changes all **39 Tidekin detail SVGs** and both Tidekin overview SVGs.

## From the board to the maps

| Visible reference | Applied design |
| --- | --- |
| Busy timber waterfront built directly over sea water | Driven piles, thin plank decks, rope handrails, ferry berths, hoists, fishing nets and moored sailboats |
| Coral canvas, weathered wood, kelp-covered roofs | Stilt shops, thatched lodges, drying racks and hammock balconies |
| Pearl/coral masonry and falling water | Open shell-rib pavilions, reef-grown spillways, bronze tide locks and freshwater cisterns |
| Spiral shields, sea glass, shell, pearl and bronze | New furniture symbols, banners, lanterns, cargo seals, instruments, archive rolls and sluice controls |
| Amphibious residents | Tidekin eyes, faces and webbed feet on numbered resident markers |
| Drowned arches and dark underwater ruins | Sea-glass inspection galleries, kelp-encrusted relics, light shafts and tall shrine descents |

The Human castle/house renderer is no longer used by Tidekin detail maps or overview icons. The Human detail and overview SVGs were checked against their pre-revision hashes and preserved byte-for-byte, including the three portrait tower interiors.

## Scope and review

All 39 rendered sheets were inspected through the four Tidekin contact sheets, with full-size inspection of the arrival dock, Gatehall, mangroves, shrine and late-region waterworks. Both overview images were inspected. Review fixed reef supports that obscured lower decks and placed the maelstrom in the water below the mooring decks.

The catalogue keeps the entire 80-map inventory. Static validation checks source coverage, supported climbs and stair feet, jumpable furniture, local recovery, reciprocal exits, rendered Tidekin landmarks, resident lineage markers and all overview destinations. Chromium checks the delivered SVGs and catalogue filters. See [validation](validation.json) and [render results](render-review.json).

Canvas sizes follow the space: waterfront sheets 2800 × 1720; coastal/citadel sheets 2600 × 1780; all four Sunken Shrine sheets 1800 × 2480. Main routes remain walkable concepts for every lineage; water scenery does not add a swimming requirement. These are design artifacts; game collision, simulation and runtime rendering are unchanged.

## Every Tidekin map

| Map | Setting | Individually selected major features |
| --- | --- | --- |
| [Tidewharf Landing](tidekin_sea/tidekin_sea_land.svg) | wharf | Twin ferry berths and a rigged customs wharf. Features: ferry, customs, crane. |
| [Coral Market](tidekin_sea/tidekin_sea_cm.svg) | wharf | Coral canvas stalls over a working fish canal. Features: market, market, net. |
| [Tidal Lagoon](tidekin_sea/tidekin_sea_lag.svg) | lagoon | A ring of tide-monitoring decks around open lagoon water. Features: gauge, nursery, ferry. |
| [Kelp Apothecary](tidekin_sea/tidekin_sea_ka.svg) | garden | Hanging kelp gardens, drying racks and a sea-glass mixing hut. Features: kelp, apothecary, kelp. |
| [Divers' Yard](tidekin_sea/tidekin_sea_dy.svg) | lagoon | Six pontoon stations beneath a diving boom. Features: diving, training, gong. |
| [Foamrest Inn](tidekin_sea/tidekin_sea_inn.svg) | wharf | A thatched stilt lodge with over-water hammock balconies. Features: lodge, hammock, kitchen. |
| [Tidal Gate Causeway](tidekin_sea/tidekin_sea_caus.svg) | citadel | A broad tidal lock and shell-carved admission quay. Features: sluice, shellgate, crane. |
| [Gatehall of Shells](tidekin_sea/tidekin_sea_gs.svg) | citadel | Open shell-rib gate pavilions above canal locks. Features: shellgate, guard, sluice. |
| [Reefguard Barracks](tidekin_sea/tidekin_sea_rb.svg) | citadel | Reefguard boathouse, bunk rafts and practice decks. Features: barracks, training, hammock. |
| [Cistern Works](tidekin_sea/tidekin_sea_cw.svg) | works | Raised freshwater cisterns spilling into bronze sluices. Features: cistern, sluice, cistern. |
| [Pearl Hall](tidekin_sea/tidekin_sea_ph.svg) | citadel | A fan-shell assembly pavilion overlooking falling seawater. Features: pearlhall, council, cascade. |
| [The Tide Chamber](tidekin_sea/tidekin_sea_tc.svg) | citadel | An open sea-facing council deck and tidal listening wheel. Features: council, tidewheel, gong. |
| [Deepvault](tidekin_sea/tidekin_sea_dv.svg) | submerged | Dry archive caissons with sea-glass observation walls. Features: archive, glass, archive. |
| [Shrine Causeway](tidekin_sea/tidekin_sea_sc.svg) | shrine | A kelp-draped descent from the sea wall to drowned arches. Features: ruin, crane, shellgate. |
| [Flooded Nave](tidekin_sea/tidekin_sea_fn.svg) | shrine | Broken shell vaults and three sluice channels under water. Features: nave, sluice, ruin. |
| [Coral Reliquary](tidekin_sea/tidekin_sea_cr.svg) | shrine | Shell, wave and pearl stations inside a coral-encrusted ruin. Features: reliquary, archive, coral. |
| [The Pearl Sanctum](tidekin_sea/tidekin_sea_ps.svg) | shrine | An ancient pearl regulator in a submerged shell rotunda. Features: regulator, cascade, reliquary. |
| [Siltbank Shallows](tidekin_sea/tidekin_sea_path_001.svg) | shoals | Fishing piers across three freshwater sandbars. Features: sandbar, ferry, net. |
| [Ripplefin Pools](tidekin_sea/tidekin_sea_site_001.svg) | lagoon | Woven nursery pens and shallow rescue pools. Features: nursery, nursery, net. |
| [Shellbell Strand](tidekin_sea/tidekin_sea_path_006.svg) | shore | Shell bells, beached hulls and shore-fishing rigs. Features: gong, beached, net. |
| [Nursery Reef](tidekin_sea/tidekin_sea_site_006.svg) | reef | A protected shell-bell nursery on living reef shelves. Features: nursery, gong, coral. |
| [Coral Shelf Road](tidekin_sea/tidekin_sea_path_011.svg) | reef | Living coral overhangs and a rope-lashed survey station. Features: coral, survey, coral. |
| [Nipper Cliffs](tidekin_sea/tidekin_sea_site_011.svg) | reef | Three reef courts with rescue cradles and rigging. Features: coral, rescue, crane. |
| [Terrace Tideway](tidekin_sea/tidekin_sea_path_016.svg) | garden | Kelp terraces fed by stepped freshwater spillways. Features: kelp, cascade, sluice. |
| [Crowncrab Basin](tidekin_sea/tidekin_sea_site_016.svg) | lagoon | A crowncrab nesting lagoon seen from a ring of hides. Features: nest, survey, coral. |
| [Mangrove Channels](tidekin_sea/tidekin_sea_path_021.svg) | mangrove | Woven root bridges and fishing huts among mangroves. Features: mangrove, rootcamp, net. |
| [Snapper Rootbeds](tidekin_sea/tidekin_sea_site_021.svg) | mangrove | Root buttresses, rigging spools and snapper observation decks. Features: mangrove, rescue, winch. |
| [Lanternwater Halls](tidekin_sea/tidekin_sea_path_026.svg) | submerged | Roofless tide halls with sea-glass lantern galleries. Features: ruin, glass, lanterns. |
| [Floodhall Passage](tidekin_sea/tidekin_sea_site_026.svg) | submerged | A dry observation gallery beside submerged glyph arches. Features: nave, lanterns, glass. |
| [Reefsong Current](tidekin_sea/tidekin_sea_path_031.svg) | reef | Current-spanning dock bridges and three musical beacons. Features: bridge, gong, beacon. |
| [Whalelet Sanctuary](tidekin_sea/tidekin_sea_site_031.svg) | lagoon | An open-water whale-song amphitheater on moored decks. Features: song, council, gong. |
| [Outer Sluiceway](tidekin_sea/tidekin_sea_path_036.svg) | works | Bronze floodgates and exposed waterworks on driven piles. Features: sluice, cistern, crane. |
| [Gate Eel Narrows](tidekin_sea/tidekin_sea_site_036.svg) | works | Segmented eel contacts between open tidal gates. Features: contacts, sluice, beacon. |
| [Stormtide Terraces](tidekin_sea/tidekin_sea_return_061.svg) | storm | Shell storm screens and a weather-rigged breakwater. Features: breakwater, rescue, beacon. |
| [Blackwater Reef](tidekin_sea/tidekin_sea_return_066.svg) | blackwater | Dark coral teeth around pearl-lit refuge pontoons. Features: reefspires, rescue, lanterns. |
| [Pressurehall Passage](tidekin_sea/tidekin_sea_return_071.svg) | works | Shell pressure bellows and relief decks above the sea. Features: bellows, sluice, bellows. |
| [Maelstrom Causeway](tidekin_sea/tidekin_sea_return_076.svg) | vortex | Mooring rings and storm-tethered decks around a maelstrom. Features: vortex, crane, beacon. |
| [First Pearl Shoals](tidekin_sea/tidekin_sea_return_101.svg) | ancient | Fossil shell plates and pearl-glass survey shrines. Features: prism, reliquary, coral. |
| [Worldtide Confluence](tidekin_sea/tidekin_sea_return_116.svg) | vortex | Three tidal channels converging beneath an ancient shell gate. Features: confluence, regulator, contacts. |
