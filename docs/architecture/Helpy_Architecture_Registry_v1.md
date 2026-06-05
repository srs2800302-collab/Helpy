# Helpy Architecture Registry v1 Foundation

Status: APPROVED ✅

Approved By:
- Roman ✅
- Arthur ✅

## 1. Project Identity
- Project Name: Helpy
- Region: Pattaya, Thailand
- Platform: Android First
- Languages: RU / EN / TH
- Business Model: Marketplace of household services

## 2. Long-Term Architecture Principle
Status: APPROVED ✅

MVP must not block future platform development.

Allowed:
- simplify MVP;
- postpone complex features;
- reserve future expansion points.

Forbidden:
- architectural dead ends;
- hardcoded business logic where admin control is required;
- decisions requiring full platform rewrite later.

## 3. Core Product Principle
Status: APPROVED ✅

Client chooses problem, not profession.

Client describes the problem.
Platform determines the required specialist.

## 4. Core Business Model
Status: APPROVED ✅

Order Flow:
Client → Create Order → Deposit → Open Marketplace → Offers → Select Master → Chat → Work Execution → Completion → Review

Default Platform Commission: 30%

Commission Source:
Deposit

Commission Value:
Editable from Admin Panel.

## 5. Chat Governance
Status: APPROVED ✅

- Chat is mandatory.
- Chat stores agreements.
- Chat is evidence.
- Photos in chat are evidence.
- Admin can access any chat.
- Disputes must consider chat history.

## 6. Approved Root Categories
Status: APPROVED ✅

Closed Categories:
- Air Conditioning
- Electrical
- Plumbing
- Locks
- Cleaning
- Furniture Assembly

## 7. Deferred Categories
Status: RESERVED ✅

- Handyman
- Home Appliances

Reason:
Specialized categories are completed first.

## 8. Knowledge Base Engine
Status: APPROVED ✅

Every category must support:
- Client Guidance
- Master Guidance
- Platform Notes
- Safety Notes
- Premium Recommendations

Purpose:
Users should not keep rules in their heads.
System must display information at the correct stage of the order.

## 9. Dynamic Form Engine
Status: APPROVED ✅

Create Job Screen must be generated dynamically.

Source:
Admin Panel → API → Mobile Application

Generated Elements:
- Categories
- Subcategories
- Questions
- Photo Requirements
- Rules
- Guidance Blocks

No hardcoded forms.

## 10. Premium Services
Status: APPROVED ✅

Confirmed Premium Services:
- Control Measurement
- Completeness Verification

Purpose:
Reduce installation risks before work begins.

## 11. Furniture Skill Levels
Status: APPROVED ✅

Levels:
- Basic
- Intermediate
- Advanced

Purpose:
Control access to complex furniture projects.

## 12. Global Platform Rules
Status: APPROVED ✅

Platform Rules Registry exists.

Confirmed Rules:
- Rule #1
- Rule #2
- Rule #3
- Rule #4
- Rule #5
- Rule #6
- Rule #7

Detailed texts to be attached during category migration.

## 13. Admin Panel Architecture
Status: FOUNDATION COMPLETE ✅

Admin Panel is not a list of orders.

Admin Panel is a Business Logic Builder.

### Category Builder
- Enable Category
- Disable Category
- Add Category
- Change Category Order
- Change Category Name
- Change Localizations
- Change Icons

### Subcategory Builder
- Enable
- Disable
- Add
- Sort

### Question Builder
- Enable
- Disable
- Add
- Sort

### Photo Requirement Builder
- Enable
- Disable
- Add
- Sort

### Pricing Builder
- Pricing Rules
- Coefficients
- Premium Services

### Guidance Builder
- Client Guidance
- Master Guidance
- Safety Notes
- Platform Notes

### Draft / Published
Changes are prepared in Draft.
Only Published content is visible to users.

### Clone Category
Full category duplication.

### Archive Instead Of Delete
No physical deletion.
Archive only.

### Preview
- Client View
- Master View

### Test Order Preview
Create test orders before publishing.

### Category Health Check
Verify:
- questions;
- photos;
- localizations;
- pricing;
- dependencies.

### Audit Log
Store:
- who changed;
- what changed;
- when changed.

### Rollback
Restore previous published version.

### Dependency Rules
Questions and photos can depend on previous answers.

### Admin Notes
Internal notes.
Not visible to users.

### Master Eligibility Rules
Control access by skill level.

### Translation Review Workflow
Languages:
- RU
- EN
- TH

Statuses:
- Auto Generated
- Reviewed
- Approved

Admin can manually correct translations.

### Multi-Language Admin Interface
Supported:
- Russian
- English
- Thai

Entire admin interface must support localization.

### Feature Flags
Published but hidden functionality.
Enable without release.

### Notification Center
- Client Notifications
- Master Notifications
- Admin Notifications

### Platform Settings Center
Single location for:
- commission;
- disputes;
- timers;
- premium prices;
- notification settings;
- translation settings.

### Future Admin Roles Reserve
Reserved:
- Super Admin
- Content Manager
- Support Manager
- Finance Manager
- Moderator

## 14. Future Business Direction
Status: RESERVED FOR FUTURE EXPANSION ✅

Helpy Projects:
- Design
- Production
- Logistics
- Installation

Future platform expansion.
Not MVP.

## 15. Registry Expansion Plan
Status: APPROVED ✅

Next stage:
Service Architecture Registry

For each approved category:
- Subcategories
- Client Questions
- Required Photos
- Client Guidance
- Master Guidance
- Platform Rules
- Pricing Rules
- Admin Dependencies

Source of truth:
Approved chat history + future DOCX archives.
