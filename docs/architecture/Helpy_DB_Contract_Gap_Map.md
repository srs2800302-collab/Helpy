# Helpy DB Contract Gap Map

Status: DRAFT FOR REVIEW

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

The current schema supports the old flow:

jobs.price
→ offers.price
→ jobs.selected_offer_price
→ jobs.deposit_amount

The approved Registry requires the new price lifecycle:

platform entry price
→ initial master offer
→ optional one-time revised price
→ client confirmation
→ final master application
→ final agreed price
→ deposit/commission snapshot

---

## Gap 1. Job Price Naming / Snapshot

Current:
- jobs.price

Gap:
- `jobs.price` currently acts like a generic order price.
- Registry now defines this as Platform Entry Price.
- API/UI need a clear semantic contract.

Target:
- Preserve existing data.
- Treat jobs.price as Platform Entry Price for compatibility.
- Future schema may rename or alias it as entry_price only through controlled migration.
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
- No price_revision_confirmed_at field.
- No final_application_sent_at field.
- No enforcement data for one-time price revision.

Target:
- Preserve initial offer price.
- Store one-time revised price separately.
- Store reason separately from general comment.
- Store client confirmation timestamp/evidence.
- Store final application timestamp.
- Keep final agreed price available for selection and payment.

---

## Gap 3. Offer Status Domain

Current:
- active;
- selected;
- rejected;
- cancelled.

Gap:
- No status for negotiation/final application.

Target:
- Add or map offer lifecycle states:
  - initial_offer_sent;
  - price_revision_requested;
  - price_revision_approved;
  - final_application_sent;
  - selected;
  - rejected;
  - cancelled.

DB design must avoid ambiguous status meanings.

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

Target:
- Store immutable financial snapshot at selection:
  - final_agreed_price;
  - commission_base_amount;
  - deposit_percent;
  - deposit_amount;
  - payment_method;
  - commission_payer.
- Existing selected_offer_price may be preserved as compatibility alias only if documented.

---

## Gap 5. Pre-selection Chat Relation

Current:
- chat_messages is keyed by job_id.
- Chat access is currently selected-master based.

Gap:
- No DB-level link between chat_messages and offer_id.
- Pre-selection chat requires access by active/negotiating offer participant.
- One job may have multiple offers and therefore multiple pre-selection conversations.

Target Design Question:
- Option A: keep chat_messages job_id-only and authorize by offers table.
- Option B: add offer_id to chat_messages for pre-selection messages.
- Option C: introduce chat_threads for job/offer scoped conversations.

Decision must be made before migration.

---

## Gap 6. Price Negotiation Evidence

Current:
- job_events supports price_adjustment_requested and price_adjustment_approved.
- Runtime does not yet store price negotiation state in offers.

Gap:
- Events exist, but DB offer fields do not store the actual current business price state.
- Chat text alone must not be source of truth.

Target:
- Store price lifecycle fields in offers/jobs.
- Store timeline events in job_events.
- Use chat only as human context.

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

Target:
- Keep card columns/tables as future expansion.
- Do not delete Stripe/card structures blindly.
- Add runtime/API behavior controlled by platform_financial_settings.
- Cash commission collection should be represented explicitly in payment/payment event records when implemented.

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

Target:
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
