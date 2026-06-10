# Helpy API Contract Gap Map

Status: DRAFT FOR REVIEW

## Source Documents

- Helpy_Architecture_Registry_v1.md
- Helpy_Screen_Contract_Gap_Map.md

## Current Proven API Surface

Current implemented endpoints relevant to the new business flow:

- GET /api/v1/jobs/:jobId/offers
- POST /api/v1/jobs/:jobId/offers
- POST /api/v1/jobs/:jobId/select-offer
- GET /api/v1/jobs/:jobId/messages
- POST /api/v1/jobs/:jobId/messages
- POST /api/v1/jobs/:jobId/deposit
- GET /api/v1/jobs/:jobId/payment-status
- POST /api/v1/jobs/:jobId/start-work
- POST /api/v1/jobs/:jobId/photos
- GET /api/v1/jobs/:jobId/photos
- POST /api/v1/jobs/:jobId/complete
- GET /api/v1/admin/payments
- GET /api/v1/admin/jobs
- GET /api/v1/admin/disputes

---

## Core API Gap

The current API supports the old flow:

Open Job
→ Active Offer
→ Select Offer
→ Deposit
→ Chat
→ Start Work
→ Evidence
→ Completion

The approved Registry requires the new flow:

Platform Entry Price
→ Initial Master Offer
→ Pre-selection Chat
→ Optional One-Time Price Revision
→ Client Price Confirmation
→ Final Master Application
→ Client Selects Master
→ Final Agreed Price Fixed
→ Deposit / Commission Flow
→ Work Chat
→ Start Work
→ Evidence
→ Completion

---

## Gap 1. Entry Price / Final Price Fields

Current:
- jobs.price
- offers.price
- jobs.selected_offer_price
- jobs.deposit_amount

Gap:
- `jobs.price` is not explicitly named Platform Entry Price in API.
- Final Agreed Price is represented as selected_offer_price, not as a clear contract field.
- API does not expose price lifecycle history.

Target:
- API must expose:
  - entry_price;
  - initial_offer_price;
  - revised_offer_price;
  - final_agreed_price;
  - price_revision_reason;
  - price_revision_confirmed_at;
  - deposit_amount;
  - deposit_percent;
  - commission_payer;
  - payment_method.

---

## Gap 2. Offer Lifecycle

Current:
- Offer statuses:
  - active;
  - selected;
  - rejected;
  - cancelled.
- Offer creation immediately stores `price`.

Gap:
- No state for price revision.
- No state for client price confirmation.
- No final application state.
- Select offer is allowed directly from active offer.

Target:
- API must support offer lifecycle:
  - initial_offer_sent;
  - price_revision_requested;
  - price_revision_approved;
  - final_application_sent;
  - selected;
  - rejected;
  - cancelled.

Required business actions:
- create initial offer;
- request one-time price revision;
- confirm or reject revised price;
- send final application;
- select master only from final application.

---

## Gap 3. Pre-selection Chat Access

Current:
- Chat access allows only:
  - client_user_id;
  - selected_master_user_id.
- Read/send statuses exclude `open`.

Gap:
- Master with active offer cannot chat before selection.
- Client cannot negotiate with offering master before selection.
- Adding `open` globally would be unsafe.

Target:
- Pre-selection chat access:
  - client can access chat for an offer context;
  - master can access chat only if he has an active/negotiating offer for that job.
- Work chat access:
  - client;
  - selected master.
- Admin:
  - read-only access to any order chat via Admin Panel.

Required API design question:
- Whether pre-selection chat should be keyed by job_id + offer_id, or by job_id with offer participant authorization.

---

## Gap 4. Price Negotiation Timeline Events

Current:
- job_events supports price_adjustment_requested and price_adjustment_approved.
- Runtime does not write these events for offers.

Gap:
- Price negotiation can happen in chat, but no API action records approved timeline events.

Target:
- API must write:
  - price_adjustment_requested;
  - price_adjustment_approved.
- Chat provides human context.
- job_events provides business proof.

---

## Gap 5. Thailand Finance API

Current:
- Financial foundation exists in migration 0003.
- Runtime still includes card/mock/Stripe-oriented flows.
- createDeposit depends on selected_offer_price and deposit_amount.

Gap:
- No mobile-facing financial settings endpoint.
- No PromptPay QR deposit flow.
- No cash commission collection flow.
- Bank Transfer / Wallet / Cards are not represented as availability states for mobile.
- Card flow exists but should be future/disabled by settings.

Target:
- API must expose platform financial settings:
  - promptpay_enabled;
  - cash_enabled;
  - bank_transfer_enabled;
  - wallet_enabled;
  - card_enabled;
  - default_deposit_percent;
  - commission payer rules.
- Deposit creation must respect selected payment method.
- Cash flow must record that client pays master directly and platform later collects commission from master.
- PromptPay QR must be primary deposit flow.

---

## Gap 6. Admin API

Current:
- Admin has payments/jobs/disputes dashboard endpoints.
- No dedicated order timeline endpoint proven in current route audit.
- Admin chat access is not part of current chat contract.

Gap:
- Admin cannot yet consume complete order lifecycle as one evidence screen.
- Admin cannot read any chat through explicit admin endpoint.
- Admin cannot inspect price negotiation lifecycle as unified evidence.

Target:
- Admin API must support:
  - order timeline;
  - chat viewer;
  - price lifecycle;
  - payment/deposit state;
  - evidence photos;
  - completion state;
  - review state;
  - dispute state.

---

## Implementation Rule

No API changes should be made until this API gap map is reviewed and approved.

No database migration should be written directly from this draft.

API contract must be approved first, then DB contract, then implementation.
