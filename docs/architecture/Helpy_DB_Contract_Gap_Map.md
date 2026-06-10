# Helpy DB Contract Gap Map

Status: APPROVED GAP MAP ✅

## Source Documents

- Helpy_Architecture_Registry_v1.md
- Helpy_Screen_Contract_Gap_Map.md
- Helpy_API_Contract_Gap_Map.md

## Current Proven Migration Chain

- 0000_migration_registry.sql
- 0001_initial_schema.sql
- 0002_live_contract_alignment.sql
- 0003_financial_policy_foundation.sql
- 0004_job_events_timeline.sql

---

## Current Proven DB Foundation

### Finance

0003 already provides:
- platform_financial_settings;
- default_deposit_percent = 30;
- promptpay_enabled;
- cash_enabled;
- bank_transfer_enabled;
- wallet_enabled;
- card_enabled = 0;
- default_promptpay_commission_payer = client;
- default_cash_commission_payer = master;
- master_cash_commission_percent = 30;
- jobs.payment_method;
- jobs.commission_payer;
- jobs.deposit_percent;
- jobs.deposit_amount.

### Timeline

0004 already provides:
- job_events;
- append-only lifecycle event structure;
- price_adjustment_requested;
- price_adjustment_approved;
- master_selected;
- deposit_paid;
- work_started;
- evidence_uploaded;
- completion_confirmed_by_client;
- dispute events;
- admin_intervention.

---

## Core DB Gap

Current schema still stores price, offer, chat and payment facts in compatibility fields from the older flow.

Registry Reference:
- Order Entry Price / Final Price Contract
- Offer Lifecycle Architecture Decision
- Final Price Architecture Decision
- Chat Threads Architecture Decision
- Thailand Payment Runtime Architecture Decision
- Admin Order Timeline / Evidence Screen

DB Gap Map must describe storage gaps and schema consequences only.

It must not redefine the canonical business flow.

---

## Gap 1. Job Price Naming / Snapshot

Current:
- jobs.price

Gap:
- `jobs.price` currently acts like a generic order price.
- Registry now defines this as Platform Entry Price.
- API/UI need a clear semantic contract.

Registry Reference:
- Order Entry Price / Final Price Contract

DB Consequence:
- Preserve existing data.
- Treat jobs.price as Platform Entry Price compatibility field.
- Future rename or alias to entry_price requires controlled migration.
- Do not remove jobs.price blindly.

---

## Gap 2. Offer Price Lifecycle

Current:
- offers.price
- offers.message
- offers.comment
- offers.status

Gap:
- No initial_offer_price field.
- No revised_offer_price field.
- No final_agreed_price field.
- No price_revision_reason field.
- No price_revision_requested_at field.
- No final_application_sent_at field.
- No enforcement data for one-time price revision.

Registry Reference:
- Offer Lifecycle Architecture Decision
- Structured Job Scope / Price Justification Contract

DB Consequence:
- Preserve initial offer price separately.
- Store one-time revised price separately.
- Store price_revision_reason separately from general comment.
- Store final_application_sent_at.
- Store final_agreed_price for selection and payment.

---

## Gap 3. Offer Status Domain

Current:
- active;
- selected;
- rejected;
- cancelled.

Gap:
- No status for negotiation/final application.

Registry Reference:
- Offer Lifecycle Architecture Decision

DB Consequence:
- offers.status stores current operational state.
- Offer lifecycle fields store price facts, reason and timestamps.
- job_events stores immutable business history.
- Master selection must be enforceable only after final_application_sent exists.

---

## Gap 4. Final Agreed Price / Commission Base

Current:
- jobs.selected_offer_price;
- jobs.deposit_amount;
- jobs.deposit_percent;
- jobs.commission_payer;
- jobs.payment_method.

Gap:
- selected_offer_price is currently the selected offer price, but Registry needs Final Agreed Price as financial/legal source.
- No explicit commission_base_amount field.
- Deposit is calculated before the full new lifecycle is represented.

Registry Reference:
- Final Price Architecture Decision
- Order Entry Price / Final Price Contract

DB Consequence:
- offers.final_agreed_price preserves negotiation outcome.
- jobs must store immutable financial snapshot.
- selected_offer_price may remain as compatibility alias during migration.
- Financial snapshots must not be rewritten after fixation.

---

## Gap 5. Pre-selection Chat Relation

Current:
- chat_messages is keyed by job_id.
- Chat access is currently selected-master based.

Gap:
- No DB-level link between chat_messages and offer_id.
- Pre-selection chat requires access by active/negotiating offer participant.
- One job may have multiple offers and therefore multiple pre-selection conversations.

Registry Reference:
- Chat Threads Architecture Decision
- Communication Layer / Business Timeline Contract

DB Consequence:
- Canonical target is chat_threads for job/offer scoped conversations.
- Pre-selection chat must be separable from work chat.
- DB design must prevent mixing negotiations, work coordination and dispute/admin context.

---

## Gap 6. Price Negotiation Evidence

Current:
- job_events supports price_adjustment_requested and price_adjustment_approved.
- Runtime does not yet store price negotiation state in offers.

Gap:
- Events exist, but DB offer fields do not store the actual current business price state.
- Chat text alone must not be source of truth.

Registry Reference:
- Communication Layer / Business Timeline Contract
- Offer Lifecycle Architecture Decision

DB Consequence:
- Store price lifecycle fields in offers/jobs.
- Store immutable timeline events in job_events.
- Keep chat only as human context, not source of business state.

---

## Gap 7. Thailand Finance Runtime Compatibility

Current:
- 0003 foundation exists.
- payment_methods/card/Stripe tables and code still exist.
- card_enabled = 0 in financial settings.

Gap:
- DB allows card but settings disable it.
- Runtime still has legacy card/mock/Stripe paths.
- PromptPay QR and cash collection state are not fully modelled in payments.

Registry Reference:
- Thailand Payment Runtime Architecture Decision

DB Consequence:
- PromptPay QR must be modelled as client-to-platform deposit.
- Cash must be modelled as master-to-platform commission obligation, not client deposit.
- Bank Transfer may use simple pending → paid admin/verified state.
- Wallet/TrueMoney remains configurable through platform_financial_settings.
- Keep card columns/tables as future expansion while card_enabled is false.
- Do not delete Stripe/card structures blindly.

---

## Gap 8. Admin Timeline Read Model

Current:
- job_events exists.
- Admin endpoints exist for dashboard/payments/disputes/jobs.
- No proven DB read model for complete order timeline.

Gap:
- Admin needs unified order evidence view:
  - job;
  - offers;
  - price lifecycle;
  - chat;
  - payments;
  - photos;
  - completion;
  - review;
  - dispute.

Registry Reference:
- Admin Order Timeline / Evidence Screen
- Timeline API Contract
- Communication Layer / Business Timeline Contract

DB Consequence:
- Prefer query/read-model endpoint first.
- Avoid premature denormalized timeline table until query needs are proven.
- Add indexes only after query contract is approved.

---

## Implementation Rule

No migration should be written from this draft directly.

DB contract must be reviewed and approved first.

Then migration plan must specify:
- exact target chain;
- APPLY;
- REGISTER;
- DONE;
- audit;
- smoke.

No schema changes without rollback-safe migration plan.
