# Helpy Screen Contract Gap Map

Status: APPROVED GAP MAP ✅

## Source Registry Contracts

- Order Entry Price / Final Price Contract
- Communication Layer / Business Timeline Contract
- Job Events / Order Timeline Contract
- Timeline API Contract
- Chat Threads Architecture Decision
- Offer Lifecycle Architecture Decision
- Thailand Payment Runtime Architecture Decision
- Final Price Architecture Decision
- Guided Job Flow Foundation
- Mobile Guidance Slots Contract

## Core Screen Gap

Screen Gap Map must describe UI gaps and screen consequences only.

Registry Reference:
- Helpy Canonical Order Lifecycle Contract
- Guided Job Flow Foundation
- Order Entry Price / Final Price Contract
- Offer Lifecycle Architecture Decision
- Communication Layer / Business Timeline Contract
- Thailand Payment Runtime Architecture Decision

Screen Gap Map must not redefine the canonical business flow.

---

## Current Proven Gaps

### 1. CreateOfferScreen

Current:
- Master enters message.
- Master enters price.
- Master enters price comment.
- Master sends offer immediately.

Gap:
- No Entry Price display.
- No Initial Offer terminology.
- No separation between initial offer and final application.
- No one-time price revision UI.
- No required price revision reason.
- No final application action.

Screen Consequence:
- Show Platform Entry Price.
- Send Initial Offer.
- Show master price as Initial Offer Price.
- Keep price comment as offer explanation.
- Later support one-time Revise Price action.
- Later support Send Final Application action after price agreement.

---

### 2. JobOffersScreen

Current:
- Client sees offers.
- Client sees master name, price, message, comment.
- Client can immediately Select Master while offer is active.

Gap:
- No Entry Price context.
- No negotiation state.
- No client confirmation of revised price.
- No final application state.
- Select Master is available too early.

Screen Consequence:
- Show Entry Price.
- Show Initial Master Offer.
- Show revised price if present.
- Show price revision reason if present.
- Show that client selects master to accept Final Price.
- Show final application status.
- Enable Select Master only when final application is available.

---

### 3. ChatScreen

Current:
- Chat opens only after master_selected.
- Start Work is shown in master_selected.
- Evidence / Complete controls are shown in in_progress.
- Closed states are completed/cancelled/disputed.

Gap:
- No pre-selection chat mode.
- No active-offer based access.
- No price confirmation evidence UI.
- Work controls are mixed into the only chat screen.

Screen Consequence:
- Support chat modes:
  - pre_selection;
  - work;
  - closed.
- Pre-selection mode:
  - allow discussion between client and master with active offer;
  - no Start Work;
  - no Evidence;
  - no Completion.
- Work mode:
  - arrival coordination;
  - Start Work;
  - Evidence Photos;
  - Completion.
- Closed mode:
  - read-only evidence context.

---

### 4. Backend Chat Access

Current:
- Chat access requires client_user_id or selected_master_user_id.
- Read statuses exclude open.
- Send statuses exclude open.

Gap:
- Master with active offer cannot chat before being selected.
- Client cannot negotiate with offering master before selection.
- Admin read access is not part of current chat access function.

Screen Consequence:
- Before selection:
  - client_user_id can access pre-selection chat;
  - master_user_id can access only if active offer exists for that job.
- After selection:
  - client_user_id and selected_master_user_id can access work chat.
- Admin:
  - can access any order chat from Admin Panel, read-only by default.

---

### 5. Offer Lifecycle Screen Dependency

Current:
- Offer-related screens still depend on active/selected/rejected/cancelled status and generic price/message/comment fields.
- No screen currently has a proven final application state.

Gap:
- Screen layer cannot yet render the approved offer lifecycle clearly.
- Screen layer cannot yet separate initial offer, price revision, final application and selected state.

Registry Reference:
- Offer Lifecycle Architecture Decision
- Order Entry Price / Final Price Contract
- Final Price Architecture Decision

Screen Consequence:
- Offer-related screens must display offer lifecycle states returned by API.
- Offer-related screens must not decide lifecycle state locally.
- Select Master action must be rendered only when API exposes final application availability.

### 6. ClientJobDetailsScreen

Current:
- Shows job price.
- Shows deposit amount if present.
- Allows pay deposit in awaiting_payment.
- Allows opening offers while job is open.
- Allows chat only after master_selected / in_progress / completed-related states.

Gap:
- `price` label does not clearly mean Platform Entry Price.
- Final Agreed Price is not visually separated from Entry Price.
- Payment action is not tied clearly to Final Agreed Price.
- No screen-level explanation of why deposit exists.
- No pre-selection chat entry point from offer context.

Screen Consequence:
- Display Platform Entry Price as historical starting price.
- Display Final Agreed Price only after final application / selection.
- Display deposit as 30% of Final Agreed Price.
- Payment CTA should appear only after Final Agreed Price is fixed and payment is required.
- Chat CTA should respect mode:
  - pre-selection from offer context;
  - work chat after master selection.

---

### 7. MasterJobDetailsScreen / Marketplace

Current:
- Master sees job price.
- Master can send offer while job is open and hasApplied is false.
- Master can open chat only after master_selected / in_progress.
- Applied jobs are blocked from repeated offer creation.

Gap:
- Job price is not clearly Platform Entry Price.
- No explanation that master can revise price once after discussion.
- No pre-selection chat access after initial offer.
- No final application action.

Screen Consequence:
- Display Platform Entry Price.
- Explain that offer starts from Entry Price context.
- After initial offer, show Pre-selection Chat CTA.
- Show one-time Revise Price action when allowed.
- Show Send Final Application action after price agreement.

---

### 8. MasterOffersScreen / MasterHome Offers

Current:
- Master sees active offers.
- Shows price, message/comment, status.
- Offers may open chat when selected or in work status.

Gap:
- No distinction between initial offer and final application.
- No status for price revision requested/approved.
- No action to continue pre-selection negotiation.
- No action to send final application.

Screen Consequence:
- Show offer lifecycle:
  - Initial Offer Sent;
  - Pre-selection Chat;
  - Price Revised if applicable;
  - Client Confirmed Price;
  - Final Application Sent;
  - Selected / Rejected / Cancelled.
- Show Pre-selection Chat CTA for active offer.
- Show Final Application CTA only after required confirmation.

---

### 9. JobPaymentScreen

Current:
- Accepts jobId, depositAmount, price.
- Creates deposit payment.
- Currently UX is tied to generic deposit/card-like flow.

Gap:
- Payment methods do not match Thailand finance contract visually.
- PromptPay QR is not primary UX.
- Cash flow does not explain that client pays master full amount and platform later collects commission from master.
- Bank Transfer / Wallet / Card states are not separated by MVP availability.
- Deposit is not explicitly shown as 30% of Final Agreed Price.

Screen Consequence:
- Show Final Agreed Price.
- Show Deposit = 30% of Final Agreed Price.
- Primary option: PromptPay QR.
- Mandatory option: Cash with master commission collection note.
- Secondary option: Bank Transfer.
- Reserved options: Wallet / Cards disabled or marked future depending on admin settings.
- Payment method availability must come from financial settings/API, not hardcoded UI.

---

## Screen Approval Rule

This document becomes APPROVED only after all listed screens are reviewed against Registry contracts.

---

## Implementation Rule

No mobile screen changes should be made until this gap map is reviewed and approved.

No database migration should be written from this map directly.

Screen contract must be approved first, then API contract, then schema changes.

---
