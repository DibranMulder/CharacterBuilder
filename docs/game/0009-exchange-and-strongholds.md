---
id: DESIGN-0009
title: Exchange and Lineage Strongholds
status: proposed
updated: 2026-09-08
---

# Exchange and Lineage Strongholds

## Purpose

This record captures two future social-world features: a centralized player
market inspired by the convenience of RuneScape's Grand Exchange, and one
protected home Stronghold for every playable Lineage. It specifies original
game rules and terminology rather than copying another game's name, interface,
locations, item catalog, or presentation.

Nothing in this record is implemented in the current local prototypes.

## Confirmed feature requirements

- Players can trade eligible items through a centralized Exchange.
- Every Lineage has a home Stronghold inside its Homeland.
- A Hero from the Opposing Allegiance cannot enter a Stronghold.
- Powerful Stronghold Guardians protect each restricted boundary.
- Outer Villages around the Strongholds remain enterable by both Allegiances.

## Accepted decisions — 2026-09-08

Lineage-derived Light/Dark Allegiance is permanent. Reputation, disguise,
defection, war and siege do not switch a Hero's side or bypass a home Stronghold
boundary. Same-Allegiance Heroes may enter; the connected hometown Story Sites
use the same restriction. Outer Villages remain shared guarded peace zones.

## Access interpretation

“Wrong side” means **Opposing Allegiance**, not a different Lineage. Under the
current working interpretation, a Human may enter a Tidekin Stronghold because
both are Light; a Deep Goblin may enter a Rimeborn Stronghold because both are
Dark. Whether a Stronghold contains an inner Lineage-only sanctuary remains an
open question.

| Visiting Hero | Outer Village | Stronghold interior |
| --- | --- | --- |
| Same Lineage | Allowed | Allowed |
| Allied Lineage, same Allegiance | Allowed | Allowed |
| Opposing Allegiance | Allowed | Denied |
| Mixed-Allegiance party | Allowed individually | Each Hero checked individually |

Outer Villages permit both Allegiances to use ordinary shops and Exchange
Brokers. They prohibit Open Conflict; hostile behavior is rejected by server
rules, not merely discouraged by visible guards.

## Authoritative Stronghold boundary

The server must own the access decision. Stronghold Guardians communicate and
support the rule, but they are not its only enforcement: defeating, distracting,
or pathing around a Guardian must not let an Opposing-Allegiance Hero cross the
boundary. Portals, flight, death respawns, party summons, disconnect recovery,
and future fast travel must apply the same access policy.

A denied approach should have readable escalation:

1. Boundary markers, architecture, banners, and sentries communicate ownership.
2. A Guardian warns the approaching Hero before combat when practical.
3. Continuing forward causes the boundary to reject entry and Guardians to
   engage or repel the Hero.
4. Defeat returns the Hero to a safe Recovery Anchor in the same approach Map,
   outside the restricted boundary. Respawn never transfers them to a different
   Map; DESIGN-0014 defines the shared recovery rules.

Stronghold Guardians should be dangerous enough that the boundary feels
credible. They should not become profitable farming targets: rewards, respawn
behavior, pursuit distance, assistance calls, and exploit monitoring must be
designed around their security role. They may include sentient guards, bonded
guardian creatures, constructs, or environmental defenses appropriate to the
Lineage; “Monster” is not the canonical term for all of them.

## Stronghold and village themes

These are environment prompts, not final place names.

| Lineage | Stronghold direction | Open Outer Village direction |
| --- | --- | --- |
| Tidekin | A defensible coral-and-shell citadel reached through tidal gates | Amphibious docks, raised walkways, markets, and air-filled guest quarters |
| Humans | A road-linked hill keep with layered walls, banners, and a central hall | Farms, inns, workshops, caravan yards, and a multicultural roadside market |
| Grove Centaurs | A living grove enclosed by ancient roots and guarded forest paths | Broad woodland clearings and root-road settlements sized for varied bodies |
| Aeralith | A high sky-spire reached by controlled lifts, bridges, and wind passages | Lower sky docks, sheltered terraces, courier houses, and lift stations |
| Crag Trolls | A monumental mountain hold carved behind storm-battered gates | Quarry terraces, rope-hoist yards, forge markets, and cliffside lodgings |
| Deep Goblins | A fortified Underdeep nexus controlling tunnels, rails, and ventilation | Fungal farms, machine bazaars, trade tunnels, and guarded surface elevators |
| Sunscour | A shaded desert bastion built around protected water and route control | Caravan courts, cistern plazas, glassworks, and heat-sheltered trading streets |
| Rimeborn | An insulated ice hold around geothermal warmth and aurora-lit halls | Windbreak camps, thermal pools, supply depots, and enclosed guest houses |

Each approach should transition clearly from shared village space to controlled
Stronghold space. The boundary must remain legible in a 2D side-scrolling view
without relying solely on an invisible wall or a wall of UI text.

## Accepted economy model

NPC shops supply a dependable baseline; the **Exchange** is the shared,
server-owned player market. Both Allegiances use one order book per persistent
world, through any Broker. No regional or Allegiance-specific price books are
introduced. A Broker is a market access point, not a travel service.

### NPC baseline

- Weaponsmiths, armorers and arcane vendors sell default Base equipment; starter
  towns stock Tiers 1–2, with higher-tier baseline stock in appropriate later hubs.
- Apothecaries and provisioners sell standard healing, stamina and focus
  supplies, food, and biome remedies at fixed catalog prices.
- NPC shops do not stock Refined upgrades, rare/special drops, or uniquely rolled
  equipment. These come from the acquisition systems and can enter player trade
  when tradable. Specific recipes and drop tables remain separate content work.
- Default stock is replenishable and affordable at its intended progression band.
  Prices are based on earning rates, never automatically set below the Exchange.
- NPC buyback is a low salvage floor, not a profit loop: a default item's
  buyback value is at most 25% of its undiscounted sale price and never exceeds
  its lowest obtainable NPC purchase price. Other salvage values are explicit.
  Non-sellable and bound items cannot bypass their restrictions through buyback.

### Player market and tradability

The Exchange accepts any item explicitly marked tradable: special drops,
Refined/crafted upgrades, materials, and surplus ordinary equipment or supplies.
Baseline resale is allowed but competes with the published NPC price; it is not
the Exchange's main source of value. NPC-only quest goods, bound items, currency,
services and Account entitlements are excluded. Eligibility is a server-owned
item property, not a decision inferred from rarity or the item's source.

Two sale modes share the same escrow and claim ledger:

1. **Fungible orders:** standardized identical items use Buy/Sell Orders with
   quantities and limit prices. Compatible prices match by best price, then
   creation time; execution uses the older resting order's price. Partial fills
   are allowed. Excess buyer escrow becomes claimable.
2. **Exact-item listings:** an upgraded or rolled item with unique state has
   a quantity-one fixed-price listing. The buyer sees the actual rolls, upgrade
   state, durability and binding restrictions and purchases that exact instance.
   The item is immutable in escrow; no broad Buy Order may substitute another
   roll or variant. Concurrent purchases have one winner.

An order or listing ends as Filled, Canceled or Expired; fungible orders can be
Partially Filled while still active. **Claim balances are separate from order
state**: proceeds from a partial fill may be claimed while the order stays open.
Claims consume only the requested available balance atomically and remain
retry-safe. Pouch capacity blocks delivery without losing the claim.

There is no upfront listing fee. A 2% seller fee on each completed trade is a
currency sink; buyers pay the agreed gross price. Use integer minor units and
cumulative per-order fee rounding so splitting fills cannot avoid fees.
Canceled or expired unfilled escrow is returned without a sale fee.
Order caps and expiry durations remain operational tuning; the same rules apply
to both Allegiances.

Direct trading, gifting, mail attachments, clan storage, and delivery contracts
remain separate features. The Exchange does not imply that they exist.

## Economy security and anti-cheat

The client may display and request trades but never decides ownership, balance,
price matching, or fulfillment.

- Currency and items enter escrow atomically when an order is accepted.
- Each order and claim operation uses an idempotency key.
- Matching, partial fills, cancellation, fees, and delivery are one durable
  transactional workflow with conserved item and currency totals.
- The server validates ownership, quantity, tradability, order limits, and
  available capacity before accepting an order.
- Every state transition produces an auditable ledger entry.
- Rate limits and bot evidence apply to search, order creation, cancellation,
  and rapid repricing.
- Suspicious circular trades, wash trading, price manipulation, duplication,
  compromised Accounts, and real-money-trading patterns are recorded for
  investigation without treating a client binary as trusted evidence.
- Backup restoration and reconciliation must prove that no item or currency is
  silently created or destroyed.

The Exchange cannot launch against client-side inventory or in-memory Account
state. It depends on authenticated Accounts and durable server-owned inventory,
currency, and Hero persistence.

## Boundary scenarios

- A Light Human may trade in a Crag Troll Outer Village but is stopped at the
  Crag Troll Stronghold gate.
- A Dark Deep Goblin may enter the Rimeborn Stronghold under the current
  same-Allegiance rule.
- A mixed party can explore an Outer Village together; only individually legal
  members may continue into the Stronghold.
- Defeating every visible Guardian does not disable the authoritative boundary.
- An Exchange cancellation racing with a partial fill settles exactly once and
  returns only the remaining escrow.
- A disconnected buyer may later claim completed purchases without the seller
  being online.

## Open decisions

- Is same Allegiance always sufficient for Stronghold entry, or is an inner
  sanctuary restricted to the home Lineage?
- Which currency and earning rates should set the baseline NPC price lists?
- Which acquisition entries create each special drop or upgrade?
- What order limits, expiry durations, price history, and anti-manipulation
  controls serve ordinary players while bounding market load?

## Delivery dependencies

1. Durable Account, Hero, inventory, equipment, and currency persistence.
2. Authenticated Session and server-owned item definitions.
3. Atomic inventory and currency ledger with idempotent operations.
4. Zone access policy enforced by the authoritative World Instance.
5. Exchange order matching, escrow, claiming, and audit history.
6. Stronghold and Outer Village content, Guardians, services, and navigation.
7. Economy simulation, exploit testing, load testing, and live-operations tools.

## Change log

- 2026-09-08: Reconciled the user-approved rules applicable to this record;
  see the decision summary in `../game-coherence-review.md`.

- 2026-08-22: Initial Exchange, Stronghold access, Guardian enforcement, Outer
  Village, economy security, and delivery dependencies recorded.
