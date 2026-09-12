# Wendmere Crossroads — Village Square and Market Row

The first two playable Human hometown maps from DESIGN-0014. Open **Human hometown**
in the builder, or launch directly:

```sh
godot --path . prototypes/human_hometown/human_hometown.tscn
```

A 2,400-unit side-scrolling, peaceful street connects the west gate, Hearth Inn
frontage, square oak and well, Rowan's market stall, workshops and eastern
training road. Blue banners, warm plaster, oak, pottery, terraced fields and the
hill keep follow the Human art direction. Dedicated painted veteran sentries guard the road: a broad halberd sentry and
a heavier shield captain, with closed helmets, plate armor and blue/ivory livery.
These use their own sprites, not the player character rig.
The town is open to any builder lineage with the selected outfit.

Use A/D or arrows to walk, Space to jump, I for the pouch and L for skills.
Keyboard and touch controls are both available. Short location hints identify
nearby landmarks. Walk near Rowan's blue canopy and use E or the Rowan button
for the existing local dialogue and buy/sell shop. Menus pause the world.

Speech-bubble signs identify working services from a distance. A gold sign,
ground bracket and E button indicate a currently usable merchant; signs stay
muted while out of range or airborne. Arrow signs name connected maps and show
the walking direction. Decorative storefronts and sentries have no service sign.
Signs hide in menus and retain their drawing while unchanged. Run
`godot --headless --path . --script res://tests/world_interaction_regression.gd`
to check interaction readiness, visibility, destination names and redraw stability.

Walk through Village Square’s **west arch** to reach **Market Row**. The market’s
**east arch** returns to the square. Each district has its own map state and
Recovery Anchor; equipment, currency and hero resources travel with you.

Market Row has three shopkeepers: **Brann** sells weapons, **Tessa** sells shields
and clothing/armor, and **Orin** sells staves, utility offhands and mana potions.
Approach one and press E or the named on-screen button, then Trade. Each shop
has a separate stock list, accepts spare items, and keeps purchases in your
pouch until you equip them. Switching merchants invalidates old quotes. Prices
are local prototype values. Armor is visual equipment without added combat stats.

Walk through Village Square’s **east arch** to enter Willow Trail and the four-map training
route. Its **west arch** returns to Wendmere. Transfers preserve equipment,
coins, potions, progression, resources and cooldowns. Returning and reentering
reuse the tutorial's map states and objectives, without respawning defeated
enemies or refilling resources. Transfers require grounded, living characters
with no unfinished attack or projectile. Arrival is outside the opposite trigger.

Recovery stays at the Village Square anchor. Restart resets the town walk,
not purchases or gear. Builder starts a new local visit; town and training
states are session-local, while the existing discipline profile remains saved.
No account, online economy or durable world-map save is introduced.

**Village Square** and **Market Row** are playable. The inn is a painted landmark;
its interior and services, Apothecary Lane,
Trainers' Yard, Stronghold Approach, the King's Keep and the Princess's Tower
are not additional playable town districts yet. The training road connects to
the existing prototype route, not a finished Trainers' Yard town district.

`town.gd` defines dimensions and landmarks. `town_visual.gd` retains one painted
Sprite2D; camera motion updates its transform without reconstructing scenery.
The town scene reuses clearing movement, inventory, portrait, dialogue and shop
modules. Merchant patrols have a configurable home position. Sentries use static
painted sprite cutouts with no animation rig, and controls retain the tutorial performance fix.

Artwork and the exact generation prompt are in
[`assets/maps/wendmere/README.md`](../../assets/maps/wendmere/README.md).
The source panorama is checked into the workspace; it is never loaded from a
personal generated-images directory at runtime.

```sh
godot --headless --path . --script res://tests/human_hometown_regression.gd
godot --headless --path . --script res://tests/market_row_regression.gd
godot --path . --script res://prototypes/human_hometown/capture.gd
godot --path . --script res://prototypes/human_hometown/capture_market.gd
```

Captures: `artifacts/wendmere_west.png`, `wendmere_square.png`,
`wendmere_market.png`, `wendmere_east.png` and `wendmere_shop.png`.

Direct Market Row launch: `godot --path . prototypes/human_hometown/market_row.tscn`.
Market captures are `artifacts/market_smith.png`, `market_armor.png`,
`market_arcane.png`, `market_gate.png`, `market_dialogue.png` and `market_shop.png`.
The market panorama prompt is in `assets/maps/wendmere/market-art.md`; the guard
atlas and both generation/edit prompts are in `assets/npcs/wendmere/README.md`.
