# Operator roadmap — June 2026

Not a product map. A **decision ledger** so you can move without reopening closed chapters.

## What's parked (stop engineering)

| Product | State | Next job is not code |
|---------|-------|----------------------|
| **FORM** | Shipped beta (`18d62fd`). Pause posture documented. | Users, watch sync, observe breaks, Garmin path, price later |
| **FORM/Forge split** | Banked on `forge-standalone-split`. Not on `main`. | Ship when Forge App Store record exists |

## One open engineering closeout

**Forge migration bridge** — FORM exports Forge → standalone Forge imports.

- Built on branch, not shipped.
- Tim **cannot** migrate until **new FORM TestFlight** with export ships.
- Device verify: Tim + Rod real data, quit/reopen, program + logbook + photos.

After device pass: **stop FORM/Forge code.**

## Live fronts (priority order you named)

1. **West Palm athletes** — real races, real trust. FORM beta is live; watch them, don't build.
2. **Hideout** — cash, ops, app (ordering, loyalty). Separate lane from FORM.
3. **Reddit / distribution** — Forge explainable first (structure, transformation, build-in-public). FORM deeper, needs watch data story later.
4. **Forge monetization** — first revenue candidate when users exist. Programs + execution + history. Reddit before paywall.
5. **FORM monetization** — after smooth + Garmin/API + enough synced data. Not now.

## Repo posture

```
origin/main              → 18d62fd  FORM shipped pause
tag FORM_PAUSE_STATE_JUNE2026 → 18d62fd

forge-standalone-split   → split + migration bridge (local)

form-forge-export-hotfix   → (create when ready) cherry-pick export-only from bridge → FORM TestFlight for Tim
```

Do **not** merge split to `main` until you choose to ship FORM export + Forge together.

## Next 3 actions (when you return to FORM/Forge)

1. Device round-trip: export Tim-shaped data → import Forge → verify.
2. Ship FORM hotfix TestFlight (export only).
3. Ship Forge TestFlight → Tim imports → confirm → **close chapter**.

## Next 3 actions (everything else)

1. Reddit-readiness pass (Forge first — one clear post angle).
2. Hideout app lane (whatever is blocking daily ops).
3. West Palm week — athlete check-ins, not features.
