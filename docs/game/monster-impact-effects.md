# Target-centered skill spectacle

The latest direction is to make mastery visible on the monster and surrounding
ground, while preserving the attacker's movement. This updates DESIGN-0021's
earlier restraint on decorative earth eruptions and extra projectile shapes:
Pursuing Hew now has a target-ground eruption proof, and the Crossbow has a
Siege Volley proof with falling bolts. These do not revise damage contracts.

## Implemented presentation

- `src/monster_impact.gd` renders bounded, deterministic aftermath in world space.
  The clearing emits it only from successful HP damage events. It cannot call
  combat code or award XP. It snapshots effect, tier and facing at activation,
  including for in-flight shots.
- Earth: contact dust at tier 0; three rising stone slabs at tier 1; five slabs
  with glowing seams and more debris at tier 2. Taller slabs frame the monster
  so its face stays visible; the center slab stays low.
- Crossbow/Bow: compact chips at tier 0, five falling bolts at tier 1, eleven at
  tier 2. The resolved hit has an immediate contact mark; falling bolts are its
  decorative aftermath, not extra projectiles with damage or collision.
- Sword/Human: ivory/gold cuts on the target; Crosscut uses two crossing marks,
  while the high-tier blade treatment adds a third mark and an open impact ring.
- Frost: ice facets and fragments. Grove/Tidekin: leafy coils. Aeralith: wind
  ribbons. Other magic: violet coils. These bursts never imply persistent roots
  or grant statuses; they expire within 1.35 seconds.
- Monster recoil is a drawing offset, never movement of its collision shape.
  Damage numbers render above the effects. At most 24 effect instances remain
  active; old decorative effects are discarded first. Restart clears them.

## Try it

Open **Monster effects** from the builder. Select a technique and level 1, 30,
or 75+; play with Space, stop, mirror, or switch to reduced effects. Each
technique uses an existing attack animation across all tiers. Preview names
describe the effect proofs, not new unlocked combat actions. No XP is earned,
and sandbox equipment does not replace the user's builder selection.

The clearing currently has Discipline progression but not weapon proficiency.
It derives tiers from Attack for physical hits and Arcana for magical hits.
Regular attacks cap at tier 1; skill hits may reach tier 2. Axe/Crossbow's full
weapon ladders and their damage events still require separate implementation.
The preview bypasses progression to make all three tiers directly comparable.

## Validation

`tests/monster_impact_regression.gd` exercises tier caps, expiry, instance budget,
no effects on misses/blocks/heals, no damage/XP/status mutation, ranged source
capture, both preview facings, cancellation, live clearing events, pause and
restart. Existing combat-feel, training-weapon, feedback and builder tests
cover compatibility. `tools/capture_monster_effects.gd` captures six proofs,
the three axe tiers, mirrored bolts and reduced effects for visual inspection.

This is a procedural production prototype, not the final painted VFX asset
pack or a measured performance claim. Screen shake and global lighting are
not part of this layer.
