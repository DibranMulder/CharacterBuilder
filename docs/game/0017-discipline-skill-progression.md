---
id: DESIGN-0017
title: Local Discipline progression and skill unlocks
status: prototype
updated: 2026-09-09
---

# Disciplines and skill unlocks

The clearing now implements the twelve 1–99 Disciplines and cumulative XP
formula from DESIGN-0007: `75 × (L−1)² + 25 × (L−1)`. Total Level is the sum;
Overall Level is its floored average. Neither replaces Adventure Level or
awards Class Talent Points. DESIGN-0011/0013's twelve-point budget is unchanged.

## Training

Awards come from resolved outcomes, never from pressing an attack button:

| Outcome | Prototype award |
| --- | --- |
| Physical HP damage dealt | Attack: 2 XP/HP; Strength: 1 XP/HP |
| Magical HP damage dealt | Arcana: 2 XP/HP |
| Successful skill damage | Focus: 1 XP/HP, in addition to the above |
| Skill healing or ward absorption | Focus: 1 XP/HP actually restored/absorbed |
| Shield block | Defense: 1 XP per point of incoming damage before reduction |
| HP damage survived | Stamina: 1 XP/HP |
| Movement near living enemies | Agility: 10 XP per 100 units; burst distance excluded |
| Potion restoration | Survival: 1 XP per point actually restored |
| First visit to a clearing section | Exploration: 25 XP, once per profile |

Whiffs, dead targets and overhealing do not award combat XP. Gathering,
Crafting and Willpower are visible but await harvesting, crafting and hostile
control activities. No passive stat scaling is applied yet: HP and mana remain
100 so this pass can test unlock pacing independently of combat balance.

## Skills

Every lineage retains its four exclusive abilities and builder gestures, on
keys **3–6**. The first is available at level 1. The next three require levels
3, 5 and 8 in the discipline associated with the action: Attack for melee,
Strength for rushes/bursts, Arcana for projectiles, Agility for retreats, Focus
for healing and Defense for wards. These are initial tuning values, not final
production progression. Exact definitions live in `lineage_skills.gd`.

Two shared prototype actions are available to all lineages:

- **Power Strike [7 / K]**: Attack 2 and Strength 2.
- **Arcane Bolt [8]**: Arcana 2 and Focus 2.

Unlocks are automatic, without Talent Points. Locked hotbar tiles show a lock
and requirements; gameplay rejects locked shortcuts before spending mana or
starting cooldowns. The old K power-attack route uses the same unlock check.
The Disciplines tab shows all twelve levels, within-level XP bars, total and
overall level, training descriptions, and clickable skill requirements/details.
The Combat Skills tab remains the lineage catalog; browsing another lineage
never equips its abilities. Both pages use the shared Chronicle menu.

### Visual presentation

The Discipline page follows `designs/disciplines-talent-tree.png`: an ink-blue
summary strip with a circular Overall badge and illustrated live stats, narrow
parchment discipline list, family-colored XP gauges, and a broad textured paper
board with circular skill medallions, brass name/requirement plaques, curved
mastery connections and an inset ink detail card. The reference's actual painted
discipline icons and blank paper are reused as runtime atlas regions; controls,
numbers, connections and labels remain live rather than being a screenshot.

The six nodes are grouped as lineage and shared skills. Teal means unlocked,
cyan means selected, and muted brass plus a padlock means locked. Connections
lead to a common mastery emblem, not prerequisite purchases. The reference's
historical Talent Point values and unimplemented armor/crit/speed stats are not
copied: Adventure Level and the implemented stats are displayed instead, with
Defense and Agility explicitly labelled as discipline levels. Round icons and
skill medallions are reusable Chronicle components.

The arena remains an **all-skills, no-XP sandbox** for matchup testing. Its
Discipline page shows saved clearing progress and explicitly labels this
exception. Opponent and player combat kits include the two shared actions;
the current bot heuristic continues to prioritize its four lineage skills.

## Local ownership and persistence

Until real Hero IDs and character selection exist, one prototype progress
profile is kept per builder lineage. Equipment changes do not reset it;
changing lineage selects a different profile. This is temporary identity, not
the production account-wide model. Snapshots autosave every ten seconds and on
leaving/restarting the clearing to `user://discipline_profiles_v1.json`, using
a temporary file followed by rename. Save errors are reported as warnings.
Script-driven tests and captures never read or overwrite player saves.

Only discipline XP and discovered clearing sections persist in this file.
Inventory and Adventure progression retain their existing prototype behavior.
Networking, anti-cheat authority, Class choices/Talents, activity systems,
equipment requirement enforcement and final XP/balance tuning remain separate.
