# Helpy Migration Plan Gap Map

Status: DRAFT FOR REVIEW

## Source Documents

- Helpy_Architecture_Registry_v1.md
- Helpy_Screen_Contract_Gap_Map.md
- Helpy_API_Contract_Gap_Map.md
- Helpy_DB_Contract_Gap_Map.md

## Migration Planning Principle

No migration is allowed until the migration target, compatibility strategy, apply/register/done flow, audit, smoke and rollback safety are documented.

Migrations must be deterministic, minimal and chain-scoped.

---

## Phase 1. No-Migration Compatibility Layer

Can be done without schema changes:

- Treat jobs.price as Platform Entry Price.
- Treat jobs.selected_offer_price temporarily as Final Agreed Price compatibility alias.
- Keep jobs.deposit_percent = financial snapshot.
- Keep jobs.deposit_amount = calculated deposit snapshot.
- Keep existing chat_messages as human communication layer.
- Keep job_events as platform timeline.
- Keep platform_financial_settings as source for payment method availability.

Goal:
- Align naming and API response semantics first.
- Avoid DB changes before API contract is finalized.

---

## Phase 2. Backward-Compatible Schema Additions

Potential migration target after approval:

Offers:
- initial_offer_price;
- revised_offer_price;
- price_revision_reason;
- price_revision_requested_at;
- price_revision_confirmed_at;
- final_application_sent_at;
- final_agreed_price.

Jobs:
- final_agreed_price;
- commission_base_amount.

Chat:
- decide before migration:
  - keep job_id-only authorization by offers;
  - add offer_id to chat_messages;
  - or introduce chat_threads.

Payments:
- keep card/Stripe structures for future.
- add only missing cash/PromptPay state if API contract requires it.

---

## Phase 3. Runtime Switch

After backward-compatible fields exist:

- API writes new fields.
- API still reads old fields as fallback.
- Mobile consumes new semantic fields.
- Admin consumes timeline + price lifecycle.
- Existing jobs remain readable.

No destructive cleanup in this phase.

---

## Phase 4. Deprecation / Cleanup

Only after production data proves new fields are stable:

- deprecate selected_offer_price as primary financial source.
- keep compatibility aliases in API.
- document migration coverage.
- add indexes only for proven query paths.

No field removal unless:
- usage audit is clean;
- live DB audit is clean;
- rollback path exists.

---

## Phase 5. Optional Future Removal

Potential future removals only after explicit approval:

- old naming aliases;
- card/mock test-only paths if replaced;
- legacy payment assumptions.

Forbidden as quick patches:
- deleting Stripe/card tables;
- rewriting job history;
- renaming jobs.price directly;
- merging chat_messages and job_events;
- denormalizing admin timeline before query evidence.

---

## Required Migration Execution Contract

Every schema migration must include:

1. APPLY
2. REGISTER
3. DONE marker
4. schema audit
5. FK/integrity audit
6. application smoke
7. rollback note

---

## Open Decisions Before SQL

1. Pre-selection chat storage model:
   - job_id-only with offer authorization;
   - offer_id in chat_messages;
   - chat_threads.

2. Offer lifecycle storage:
   - extend offers.status;
   - add separate offer lifecycle fields;
   - both.

3. Final price source:
   - jobs.final_agreed_price;
   - offers.final_agreed_price + job snapshot;
   - both.

4. Thailand payment runtime:
   - PromptPay QR data model;
   - cash commission collection records;
   - bank transfer proof state.

---

## Implementation Rule

This document is not a migration.

No SQL should be written until open decisions are resolved and approved.

Next approved output must be a concrete migration plan with exact chain ownership and rollback-safe steps.
