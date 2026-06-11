# Helpy Canonical Database Schema v1

## Goal

Canonical database architecture for Helpy MVP.

The schema must be dictated by the MVP business flow:

client creates job
→ pays/records 30% deposit
→ job becomes open
→ masters create offers
→ client selects master
→ chat starts
→ job in progress
→ completed/cancelled/disputed
→ review/dispute/admin control

## Core rule

`jobs.status` is the only source of truth for job lifecycle.

Allowed statuses:

- draft
- awaiting_payment
- open
- master_selected
- in_progress
- completed
- cancelled
- disputed

## Core MVP tables

### users

Purpose: authentication identity, role and selected language.

Keep:
- id
- role
- phone
- language
- created_at

### client_profiles

Purpose: client profile data.

Keep:
- id
- user_id
- name
- created_at

Constraint:
- user_id unique
- FK user_id -> users(id) ON DELETE CASCADE

### master_profiles

Purpose: master onboarding, category and payment capability flags.

Keep:
- id
- user_id
- name
- category
- bio
- is_verified
- has_billing_method
- billing_status
- cash_jobs_enabled
- created_at

Constraint:
- user_id unique
- FK user_id -> users(id) ON DELETE CASCADE

### service_categories

Purpose: canonical MVP categories.

Keep:
- id
- slug
- is_active
- sort_order
- created_at
- updated_at

Constraint:
- slug unique

### jobs

Purpose: central business entity.

Keep:
- id
- title
- price
- category
- status
- created_at
- updated_at
- client_user_id
- description
- address_text
- title_original
- description_original
- source_language
- title_translations_json
- description_translations_json
- address_translations_json
- budget_type
- budget_from
- budget_to
- currency
- selected_master_user_id
- selected_master_name
- selected_offer_id
- selected_offer_price
- deposit_amount
- latitude
- longitude
- payment_method
- commission_payer
- deposit_percent

Constraints:
- FK client_user_id -> users(id) ON DELETE RESTRICT
- FK selected_master_user_id -> users(id) ON DELETE SET NULL
- FK selected_offer_id -> offers(id) ON DELETE SET NULL

### offers

Purpose: master responses to jobs.

Keep:
- id
- job_id
- master_user_id
- master_name
- price
- message
- comment
- message_translations_json
- comment_translations_json
- status
- created_at

Constraints:
- unique job_id + master_user_id
- FK job_id -> jobs(id) ON DELETE CASCADE
- FK master_user_id -> users(id) ON DELETE SET NULL

### job_photos

Purpose: photos attached to jobs.

Keep:
- id
- job_id
- client_user_id
- url
- created_at

Constraints:
- unique job_id + url
- FK job_id -> jobs(id) ON DELETE CASCADE
- FK client_user_id -> users(id) ON DELETE RESTRICT

### payments

Purpose: platform deposit/payment record.

Keep:
- id
- job_id
- client_user_id
- payer_user_id
- payment_method_id
- payer_role
- source
- provider
- provider_ref
- amount
- currency
- type
- status
- created_at

Constraints:
- unique job_id + type
- FK job_id -> jobs(id) ON DELETE RESTRICT
- FK client_user_id -> users(id) ON DELETE RESTRICT
- FK payer_user_id -> users(id) ON DELETE SET NULL
- FK payment_method_id -> payment_methods(id) ON DELETE SET NULL

### job_events

Purpose: append-only platform lifecycle timeline for orders.

Keep:
- id
- job_id
- event_type
- actor_user_id
- actor_role
- payload_json
- created_at

Constraints:
- FK job_id -> jobs(id) ON DELETE CASCADE
- FK actor_user_id -> users(id) ON DELETE SET NULL
- actor_user_id is nullable for system events.
- actor_role is client, master, admin or system.
- payload_json defaults to '{}'.
- job_events must stay separate from chat_messages.

Indexes:
- job_id, created_at
- job_id, created_at DESC
- event_type, created_at DESC
- actor_user_id, created_at DESC where actor_user_id is not null

### chat_messages

Purpose: client/master job chat.

Keep:
- id
- job_id
- sender_user_id
- text
- text_translations_json
- reply_to_message_id
- reply_text
- reply_sender_user_id
- reply_text_translations_json
- created_at

Constraints:
- FK job_id -> jobs(id) ON DELETE CASCADE
- FK sender_user_id -> users(id) ON DELETE RESTRICT
- FK reply_to_message_id -> chat_messages(id) ON DELETE SET NULL
- FK reply_sender_user_id -> users(id) ON DELETE SET NULL

### reviews

Purpose: post-completion review.

Keep:
- id
- job_id
- client_user_id
- master_user_id
- rating
- comment
- comment_translations_json
- created_at

Constraints:
- unique job_id
- FK job_id -> jobs(id) ON DELETE RESTRICT
- FK client_user_id -> users(id) ON DELETE SET NULL
- FK master_user_id -> users(id) ON DELETE SET NULL

### disputes

Purpose: dispute lifecycle and admin resolution.

Keep:
- id
- job_id
- status
- resolution
- resolved_by_user_id
- resolved_at
- created_by_user_id
- reason
- created_at

Constraints:
- unique job_id
- FK job_id -> jobs(id) ON DELETE RESTRICT
- FK resolved_by_user_id -> users(id) ON DELETE SET NULL
- FK created_by_user_id -> users(id) ON DELETE SET NULL

## Support tables

### translation_tasks

Purpose: runtime translation queue/state.

Keep as support layer, not business core.

### payment_customers

Purpose: provider customer mapping.

Keep as provider support layer.

### payment_methods

Purpose: provider payment method mapping and cash-job billing eligibility.

Keep as provider support layer.

### payment_events

Purpose: provider webhook idempotency and event audit.

Keep as provider support layer.
