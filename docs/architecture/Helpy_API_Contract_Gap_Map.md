# Helpy API Contract Gap Map

Status: APPROVED GAP MAP ✅

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

Current API still exposes parts of the old offer/payment flow.

Registry Reference:
- Order Entry Price / Final Price Contract
- Offer Lifecycle Architecture Decision
- Final Price Architecture Decision
- Helpy Canonical Order Lifecycle Contract
- Communication Layer / Business Timeline Contract
- Thailand Payment Runtime Architecture Decision

API Gap Map must describe implementation gaps only and must not redefine the canonical business flow.

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
- No explicit rule that selecting master accepts Final Price.
- No final application state.
- Select offer is allowed directly from active offer.

Registry Reference:
- Offer Lifecycle Architecture Decision
- Order Entry Price / Final Price Contract
- Communication Layer / Business Timeline Contract

API Consequence:
- API must expose actions/endpoints for initial offer creation.
- API must expose one-time price revision request/confirmation flow.
- API must expose final application submission.
- API must enforce that master selection is allowed only after final application exists.
- API must write related job_events for immutable business proof.

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

Approved Direction:
- Phase 1 compatibility may use job_id + offer ownership authorization.
- Canonical target remains chat_threads.
- API must not enable open-status chat globally without offer/work authorization.

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

Registry Reference:
- Thailand Payment Runtime Architecture Decision
- Final Price Architecture Decision

API Consequence:
- API must expose mobile-facing platform financial settings.
- API must expose payment method availability from platform_financial_settings.
- Deposit creation must respect selected payment method and fixed financial snapshot.
- Cash flow must create commission obligation state, not client deposit-paid state.
- Disabled payment methods must not be exposed as available mobile actions.

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
