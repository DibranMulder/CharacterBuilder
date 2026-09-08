# Game-design coherence review

Reviewed all fifteen records in `docs/game` on 2026-09-08. This is an internal
consistency review, not verification of the historical implementation logs or
external technical references. The original findings are preserved below; the
following resolutions were subsequently accepted through user feedback.

## Decisions applied after user review — 2026-09-08

The six priority findings below are historical evidence, not unresolved rules.

| Finding | Current rule | Authoritative records |
| --- | --- | --- |
| Progression | Adventure Level 1–120; twelve Class Talent Points, no Overall-Level point budget | 0011 and 0013; 0007 superseded |
| Allegiance/access | Permanent Lineage-derived Light/Dark; Stronghold-connected Story Sites share the gate restriction | 0006, 0008, 0009, 0014 |
| Recovery | First creation picks the starting Map; death and relogin retain the current Map | 0010, 0014, 0015 |
| Economy | NPC default supplies; shared player market with fungible orders and exact-item listings | 0009, 0014 |
| Centaur equipment | Legs/Feet forbidden; supported-slot Class sets only | 0008, 0012 |
| Starter parity | Ordinary solo threats and comparable noncombat rewards in every Homeland's eight 1–40 bands; Elites optional | 0011, 0014 |

Economy details selected for coherence: NPCs do not stock Refined or special
equipment; explicitly tradable goods may be resold; completed player sales have
a 2% seller fee with no upfront listing fee. Exact prices, XP curves and drop
tables remain tuning/content work. These are specification decisions, not newly
implemented server features in this standalone character-builder repository.

Unrelated review questions, including missing source artwork and historical
implementation provenance, remain follow-up work.

## Original overall assessment

The creative direction is coherent: a storybook side-scrolling MMO, eight
distinct peoples independent of six Combat Classes, shared equipment, physical
Portal travel, protected Strongholds, and server-owned outcomes. The main
problems are unresolved rule transitions and older records not identifying which
newer decisions supersede them. These docs are useful design exploration, but
not yet one unambiguous implementation specification.

## Original priority findings (resolved in the specifications above)

1. **Progression has two incompatible Talent budgets.**
   [0007, Level formulas](game/0007-progression-talents-and-equipment.md#level-formulas)
   gives up to 98 Talent Points from an Overall Level capped at 99.
   [0011, Proposed level model](game/0011-creature-roster.md#proposed-level-model)
   introduces Adventure Level 1–120 but explicitly leaves its relationship to
   Overall Level unresolved. [0013](game/0013-class-talent-trees.md#tree-structure)
   then assumes twelve Class Talent Points from Adventure Level, while 0012
   gates gear on that level. Decide how Adventure XP is earned, which level
   controls power, and whether the old Talent currency is replaced or separate.
   Recommendation: explicitly supersede the prototype Talent formula if the
   twelve-point Class model is the intended production design.

2. **“Open to both” Story Sites are behind forbidden Strongholds.**
   [0014, Movement rules](game/0014-hometown-maps.md#movement--interaction-rules)
   says Story Sites are open to both Allegiances, but every town graph connects
   its Story Site through the restricted Stronghold. For example, a Dark Hero
   cannot reach the Princess's Tower without entering the Light-only Keep.
   Add an Outer Village entrance, or explicitly make those stories
   same-Allegiance content; do not weaken the Stronghold boundary accidentally.

3. **Login, first spawn, and respawn are conflated.**
   The same 0014 rules send every logging-in Hero home, make the Inn the respawn
   anchor, and send Guardian defeats to the Village Square. Its graph legend
   also calls the Square both spawn and respawn.
   [0015's dungeon](game/0015-world-map-layout.md#featured-dungeon--the-tower-of-babylon--the-fallen-observatory)
   adds another defeat destination. Logging out deep in a Dungeon would become
   free travel home, despite the physical-travel rule. Specify first creation,
   ordinary reconnect, invalid-location recovery, Guardian defeat, and Dungeon
   defeat separately. Recommendation: restore legal persisted locations on login.

4. **The economy's proposed starter pricing contradicts its stated goal.**
   [0014, Provision set](game/0014-hometown-maps.md) says NPC consumables are
   priced below the player Exchange “without undercutting player trade.” If
   identical goods are stocked without limits, NPCs do undercut that market.
   Also, its NPC table calls the Exchange server-wide while
   [0009](game/0009-exchange-and-strongholds.md#world-placement) and 0015 still
   leave shared versus regional books open. Decide stock limits, item scope,
   price policy, buyback rules, and market scope explicitly.

5. **Universal equipment access needs a centaur slot policy.**
   [0008](game/0008-playable-lineage-art-direction.md#lineage-variant-availability)
   promises identical equipment access; [0012](game/0012-combat-classes-and-equipment-tiers.md#standard-armor-set-contents)
   specifies six armor pieces including Legs and Feet. This character prototype
   disables pants and boots for its centaur topology (`supports_equipment_slot`
   in `src/modular_character.gd`). Decide whether equine wraps/barding provide
   equivalent slots and stats or whether the game has an explicit exception.
   This is a prototype-to-spec gap, not something a naming pass should resolve.

6. **Not every Homeland has a comparable starter encounter path.**
   [0011](game/0011-creature-roster.md#levels-140--homeland-creatures) aims to give
   every Lineage a local 1–40 path, but contains only one creature per Homeland
   per five-level band. Several early entries are benevolent non-farming
   creatures, while all eight Ice Lands entries are Elites. 0014 repeats that
   imbalance as intentional town pressure. Define a common solo starter floor:
   either additional ordinary threats or equally viable noncombat progression
   with explicit rewards. The current roster alone does not establish it.

## Clarify while consolidating the records

- **Status and provenance:** 0001 still defers races/classes/art direction even
  though 0008 confirms the roster and 0012 lists accepted Classes. Numerous
  “current build” statements refer to `client/`, `crates/game-domain`, Rust,
  and account/map prototypes absent from this standalone repo. The actual
  project is a character builder. Mark those statements as belonging to the
  source game project and add “superseded by” links; do not treat the historical
  validation logs as tests run here. Also distinguish 0001's Mobile-renderer
  production target from this prototype's `gl_compatibility` project setting.
- **Art and equipment handoff:** 0008 says not to imply Dual Wield, whereas
  0007, 0012 and 0013 approve it for Duelists. Its generic one-hand-plus-Shield
  wording also omits the Class permission restriction. Update the art brief to
  reflect Class-aware pairings. Aeralith wings and Sunscour anatomy remain open
  despite the character prototype having concrete implementations.
- **Guardian identity:** 0011 excludes Stronghold Guardians from its creature
  roster; 0014 reuses named roster creatures as Guardians, including a Corrupted
  Ventshade. Shared species/art can be coherent, but define separate Guardian
  roles, access behavior and reward tables so normal loot/farming rules do not
  leak into boundary enforcement. Explain any corrupted guardian's allegiance.
- **Exchange state:** 0009 puts `Claimed` alongside order-matching states.
  A partially filled order may have claimable proceeds while remaining open.
  Track order lifecycle separately from escrow/claim balances and define the
  execution price when buy and sell limits overlap.
- **Travel diagrams:** 0014 says every leaf has a return Portal but shows many
  one-way Story chains without return edges. Either declare diagram arrows
  narrative ordering with bidirectional playable links, or draw the returns.
  Also verify traversal routes remain usable by every body/Class, not only
  winged Heroes or Heroes with a movement Talent.
- **Editorial drift:** 0014's early 11–16-Zone budget and four-Village-Zone
  Human example conflict with its later 13–19-Zone town plans. Its summary sum
  of 127 is correct. 0012's 1,200-item arithmetic is also correct, but its
  “14 families” are weapon/grip lines plus Shield, not the ten Weapon Families
  in 0007; Spear's one-/two-handed coverage should be explicit. 0010 contains
  two different sets of three map variants—label them existing prototype versus
  proposed art treatments. 0011 currently drafts 64 creatures; 192 is the
  intended eventual roster, not completed content.
- **Missing references:** 0008's six local art links under `art-source/` do not
  exist here. Bring over the authoritative references or replace their paths
  with verified equivalents; the two root lineage paintings should not silently
  substitute for every cited source.

## Applied terminology alignment

The character builder and character-design prose now use Tidekin, Humans,
Grove Centaurs, Aeralith, Crag Trolls, Deep Goblins, Sunscour, and Rimeborn.
See the [compatibility mapping](characters/README.md). Stable rig IDs and asset
paths remain unchanged. 0006's “Sunscour Legion” is an older inconsistency;
0008 explicitly distinguishes the people from that military organization.

The original naming pass did not change game rules. Subsequent user feedback
authorized the six specification resolutions summarized at the top of this file.
