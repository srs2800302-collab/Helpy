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
- Cleaning
- Air Conditioning
- Plumbing
- Electrical
- Locks
- Furniture Assembly

## Category Governance

Status: APPROVED ✅

Helpy Categories

1. Cleaning
2. Air Conditioning
3. Plumbing
4. Electrical
5. Locks
6. Furniture Assembly

Future Launch Category:
- Home Appliances

Rules:
- Home Appliances проектируется последней категорией перед MVP Launch.
- До запуска платформы новые категории не добавляются.
- Масштабирование категорий начинается только после получения реальной статистики.

## Reference Category Standard

Status: APPROVED ✅

Reference Category:
- Plumbing

Definition:
- Plumbing является эталонной категорией Helpy.
- Все категории сравниваются с уровнем детализации Plumbing.

Minimum Architecture Standard:

- Business Scope
- Definitions
- Question Flow
- Required Photos
- Service Playbook
- Business Rules
- Admin Rules
- GAP
- Registry Storage

Rule:
- Категория считается завершённой только после достижения уровня детализации Plumbing.

## Specialized Reference Categories

Status: APPROVED ✅

Categories:
- Cleaning
- Furniture Assembly

Definition:
- Данные категории используют собственную бизнес-логику.
- Они не обязаны повторять структуру Plumbing.

Rule:
- Уровень детализации не может быть ниже Plumbing.

## Electrical Shower Policy

Status: APPROVED ✅

Enabled:
- Install New Electric Shower
- Replace Existing Electric Shower

Disabled On Launch:
- Not Heating Water
- Water Leak
- Trips Breaker / Power Loss

Reason:
- Helpy MVP ориентирован на установку и замену оборудования.
- Диагностика и ремонт электрических душей не являются приоритетом запуска.

Future:
- Может быть включено после анализа реальных заказов.

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

Status: ✅ APPROVED

Purpose:
Admin-managed contextual guidance for clients and masters during key product flows.

Guidance content must be derived from approved service documentation, Service Playbooks, Client Docs, Master Docs and Admin Rules, but delivered to mobile app only through structured Admin/API records.

Runtime Markdown document parsing is not allowed for mobile guidance.

Guidance Targets:
- Client Guidance;
- Master Guidance;
- Safety Notes;
- Platform Notes;
- category-specific hints;
- subcategory-specific hints;
- question-specific hints;
- photo requirement hints;
- before-offer master guidance;
- create-order client guidance;
- completion guidance;
- dispute-prevention guidance.

Trigger Context:
- role;
- screen;
- category;
- subcategory;
- form step;
- question key;
- photo step;
- order status;
- language.

Governance Rules:
- Guidance must be editable from Admin Panel without APK rebuild.
- Guidance must support RU, EN and TH.
- Guidance must support Draft / Published lifecycle.
- Only Published guidance is visible to users.
- Guidance must support preview for Client View and Master View.
- Guidance changes must be written to Audit Log.
- Guidance must not contradict approved Service Playbooks.
- Guidance must not replace legal documents.
- Guidance must be short, contextual and action-oriented.
- Mobile app must request guidance through structured API, not from raw documents.

Future Roadmap:
- Guidance Builder must be included in Admin Panel roadmap.
- Guidance Builder must be connected to Dynamic Form Engine.
- Guidance Builder must be connected to Knowledge Base Engine.
- Guidance Builder must be connected to Category Health Check.
- Guidance Builder must allow Admin to attach hints to category, subcategory, question, photo and workflow stages.

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

Status: ✅ APPROVED

Purpose:
Centralized platform settings layer for business, legal, support, compliance, release, maintenance, backup-status and system-health metadata.

This section is part of Admin Panel Architecture.
It defines the required future Platform Settings contract, not the immediate UI implementation.

Editable Settings:
- commission;
- disputes;
- timers;
- premium prices;
- notification settings;
- translation settings;
- company name;
- company legal name;
- company address;
- company country;
- company city;
- support email;
- support phone;
- support WhatsApp;
- support Telegram;
- support working hours;
- Privacy Policy URL;
- Terms of Service URL;
- Refund Policy URL;
- Master Agreement URL;
- Client Agreement URL;
- maintenance mode;
- maintenance message;
- minimum supported Android app version;
- latest Android app version;
- soft update message;
- force update message.

Read-Only Operational Status:
- backup enabled;
- last backup run time;
- last backup status;
- backup retention policy;
- backup storage provider;
- last backup error;
- system status;
- API status;
- database status;
- translation status;
- payment status;
- last health check time;
- Data Safety last review time;
- permissions review status.

Governance Rules:
- Mobile app, backend and Admin Panel must consume public platform settings from one API contract.
- Legal, support and company metadata must not be hardcoded inside APK.
- Admin Panel may edit only approved editable settings.
- Operational status fields are read-only by default.
- Every platform setting change must create an audit log entry.
- Backup execution is infrastructure-owned.
- Admin Panel may display backup status and approved backup actions.
- Admin Panel must not expose unsafe raw database download by default.
- Secrets must never be stored in platform settings.
- API keys, payment credentials, Cloudflare tokens, Google Play credentials and private keys must remain in environment secrets.

Reserved Data Model:
- platform_settings;
- platform_setting_audit_log.

Reserved Public API:
- GET /api/v1/platform/settings/public

Reserved Admin API:
- GET /api/v1/admin/platform/settings
- PATCH /api/v1/admin/platform/settings/:key

### Admin Panel Roadmap Extensions

Status: ✅ APPROVED

Purpose:
Reserved Admin Panel modules that reduce operational risk, prevent business-rule drift and help validate configuration before publication.

These modules are part of the Admin Panel roadmap.
They do not require immediate MVP implementation, but the architecture must reserve space for them before Admin Panel development.

Must-Have Roadmap:
- Rules Simulator;
- Impact Analysis;
- Registry Coverage;
- Sandbox Mode.

Nice-To-Have Roadmap:
- Search Everywhere;
- Bulk Operations;
- Import / Export.

Rules Simulator:
Admin can simulate what the client or master will see for a selected role, category, subcategory, form step, language, pricing rule, guidance rule, photo requirement and workflow state.

Purpose:
- Prove behavior before publication.
- Reduce APK rebuilds.
- Prevent broken category/form/pricing/guidance combinations.

Impact Analysis:
Admin can see what depends on a category, subcategory, question, photo requirement, pricing rule, guidance rule, feature flag or workflow rule before changing, disabling, archiving or publishing it.

Purpose:
- Prevent accidental breakage.
- Show dependencies before risky changes.
- Support safe Admin Panel publishing.

Registry Coverage:
Admin can see readiness coverage per category/subcategory:
- questions;
- photo requirements;
- pricing rules;
- guidance;
- translations;
- client docs;
- master docs;
- service playbook;
- admin rules;
- health check status.

Purpose:
- Show what is complete, missing or risky before launch.
- Support category readiness decisions.
- Keep Registry and Admin Panel aligned.

Sandbox Mode:
Admin can test draft categories, rules, pricing, guidance, completion flows and feature flags without exposing them to real users.

Purpose:
- Separate draft experiments from production.
- Test future service logic safely.
- Support controlled Admin Panel rollout.

Search Everywhere:
Admin can search across categories, subcategories, questions, photo requirements, pricing rules, guidance, translations, notes and platform settings.

Purpose:
- Reduce admin friction as Registry grows.
- Help find duplicated or conflicting rules.
- Support faster maintenance.

Governance Rules:
- Roadmap extensions must follow Draft / Published lifecycle where applicable.
- Roadmap extensions must support Audit Log where changes are possible.
- Roadmap extensions must not bypass Category Health Check.
- Roadmap extensions must not expose secrets or unsafe database access.
- Roadmap extensions should be implemented gradually after core Admin Panel builders.
- Rules Simulator, Impact Analysis, Registry Coverage and Sandbox Mode are higher priority than Search Everywhere, Bulk Operations and Import / Export.

### Future Admin Roles Reserve
Reserved:
- Super Admin
- Content Manager
- Support Manager
- Finance Manager
- Moderator

### Chat Lifecycle / Attachment Rules Builder

Admin can configure:
- Which order stages allow chat access.
- Which order stages allow photo attachments.
- Who can send attachments.
- Attachment limits.
- Attachment rules.
- Chat system guidance.

Purpose:
- Change chat business rules without APK rebuild.
- Keep chat behavior controlled by platform business logic.

### Completion Flow Builder

Admin can configure:
- Who initiates completion.
- Whether client confirmation is required.
- When the master can access Complete Order.
- Completion timers.
- Auto-completion behavior.
- Escalation to disputes.
- Completion notifications.

Purpose:
- Completion flow is business logic.
- Completion rules must remain configurable without APK rebuild.

### Admin Order Timeline / Evidence Screen

Admin must be able to open an order and see the full business lifecycle:

- job created;
- deposit paid;
- master selected;
- work started;
- master evidence photos uploaded;
- client completion confirmation;
- job completed;
- review submitted;
- dispute opened / resolved if applicable.

Prepared MVP Flow:

- Start Work changes order status from master_selected to in_progress.
- Start Work creates job_events.work_started.
- Master can upload evidence photos only after work starts.
- Master can select up to 10 evidence photos per upload action.
- Total order photo limit is 20 photos for MVP.
- Evidence photos are used for hidden defects, unsafe conditions, work process and final result.
- Current DB field job_photos.client_user_id is a legacy name and acts as uploaded_by_user_id until schema-cleanup.
- Final schema-cleanup before launch must rename this concept cleanly.

Admin Screen Requirements:

- Show order status timeline.
- Show chat history.
- Show client initial photos.
- Show master evidence photos.
- Show event history from job_events.
- Show payment/deposit state.
- Show selected master.
- Show completion state.
- Show review state.
- Show dispute state.

Purpose:

- Prepare Admin Panel for operational control.
- Connect Chat Lifecycle, Evidence, Completion Flow, Disputes and Reviews into one order screen.
- Prevent business-rule drift between mobile flow and admin visibility.

### Evidence / Quality Control Center

Admin can access:
- Chat history.
- Chat photos.
- Final work photos.
- Client confirmations.
- Price change history.
- Status history.
- Related disputes.

Purpose:
- Evidence protection.
- Quality control.
- Operational analytics.
- Platform improvement.

### Review / Reputation Builder

Admin can configure:
- Review activation.
- Review visibility.
- Review checkbox management.
- Review translations.
- Reputation metric visibility.
- Reliability icon visibility.
- Review publication rules.

Admin can access:
- Review list.
- Client comments.
- Reputation analytics.
- Review statistics.

Purpose:
- Improve service quality.
- Monitor reputation trends.
- Manage review experience without APK rebuild.

### Global Rules Builder

Admin can manage:
- Global rule activation.
- Global rule versions.
- Category assignments.
- Draft / Published states.
- Feature rollout.

Purpose:
- Reduce APK rebuilds.
- Centralize business logic management.

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

---

## 16. Service Architecture Registry — Furniture Assembly
Status: APPROVED ✅
Registry Status: STORED + DOCS ✅

### Root Category
Furniture Assembly

### Subcategories
- Kitchen Assembly — STORED + DOCS ✅
- Cabinet Furniture — STORED + DOCS ✅
- Built-in Furniture — STORED + DOCS ✅

---

### 16.1 Kitchen Assembly
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions
- Is there a kitchen layout / scheme with dimensions?
  - Yes
  - No

#### Required Photos
- Kitchen layout / scheme with dimensions.
- Supplier specification / комплектовочный лист.
- Front view of installation place.
- Water outputs with tape measure from corner/floor.
- Sockets with tape measure from corner/floor.
- Ventilation opening with tape measure if present.
- General view of furniture boxes.

#### Client Guidance
- Furniture must be on site before master arrives.
- Client provides access and prepared workspace.
- Client provides layout and dimensions if available.
- Appliance connection is separate.

#### Master Guidance
- Verify modules, countertop, fittings and basic completeness.
- Verify layout, water outputs, sockets and ventilation.
- Missing elements must be fixed in platform chat before work starts.
- Before hanging upper modules, verify wall/base safety.

#### Platform Rules
- Kitchen assembly does not include plumbing, electrical relocation or appliance connection.
- Future root category: Home Appliances Installation & Connection.
- Disassembly of old kitchen: 50% of installation price.
- Launch baseline: from 5,000 THB.

#### Admin Dependencies
- Kitchen Assembly Base Price.
- Furniture Disassembly Percent.
- Required photos management.
- Rule visibility.
- Premium inspection service.

---

### 16.2 Cabinet Furniture
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Scope
Includes new corpus/cabinet furniture:
- wardrobes;
- non-built-in sliding wardrobes;
- dressers;
- cabinets;
- shelves;
- beds;
- tables;
- chairs;
- furniture sets;
- similar corpus furniture.

Does not include built-in furniture.

#### Client Questions
1. Furniture list table:
   - Furniture type
   - Quantity
   - Dimensions (W × H × D)

Default:
- 3 rows.
- Button: Add furniture.
- Rows are not limited by platform architecture.

2. Does the item require wall fastening?
   - Yes
   - No
   - I do not know

3. Do children live in the property?
   - Yes
   - No

#### Required Photos
- General view of boxes.
- Image/photo/screenshot of finished product if available.
- Installation place photo.

#### Client Guidance
- Furniture must be on site before master arrives.
- Client prepares access and workspace.
- Client clears personal belongings.
- For large cabinet furniture, enough space is required to assemble the carcass lying down.
- For tall cabinet furniture, ceiling height must exceed furniture height by at least 10 cm.

#### Master Guidance
- Verify packaging before opening.
- Photograph damaged packaging before work starts.
- Verify visible damage before assembly.
- If parts are damaged but usable, continue only after client confirmation in chat.
- Verify wall fastening and safety requirements.

#### Platform Rules
- Category is based on assembly technology, not product names.
- Do not create separate subcategories for шкаф / кровать / комод / стол.
- Master does not move, sort or store client belongings.
- Furniture disassembly with preservation is allowed as a separate service.
- Disassembly for large furniture: 50% of assembly/installation price.

#### Admin Dependencies
- Dynamic furniture table.
- Wall fastening question.
- Children safety question.
- Required photos management.
- Furniture Disassembly Percent.
- Cabinet Furniture Base Price.

---

### 16.3 Built-in Furniture
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Architecture
Built-in furniture is a separate work technology.

Workflow:
Measurement → Project → Installation

Built-in furniture is assembled element-by-element directly in the niche/place of installation.

It is not Cabinet Furniture.

#### Client Questions
1. Is existing furniture disassembly required before installation?
   - No
   - Yes, disposal
   - Yes, preserve

2. Who performed the room measurement before ordering?
   - Client
   - Furniture manufacturer

3. Niche measurement table:
   - Width: bottom outside, bottom inside, middle outside, middle inside, top outside, top inside.
   - Height: left, right.
   - Depth: bottom left, bottom right, middle left, middle right, top left, top right.

4. What material are the installation walls made of?
   - Concrete
   - Brick
   - Aerated concrete
   - Drywall / gypsum board, specify number of layers
   - Other, client describes

5. Is there a stretch ceiling in the installation area?
   - Yes
   - No
   - I do not know

If yes:
- Are reinforcements prepared?
  - Yes
  - No
  - I do not know

6. Does the project include lighting or electrical connections?
   - Yes
   - No

#### Required Photos
- Exterior scheme of the item with dimensions.
- Internal layout / filling scheme with dimensions.
- Installation place photo.
- Packing list / supplier specification, if available.

#### Client Guidance
- Client provides exterior scheme, internal layout, niche measurements and installation place photo.
- Packing list/specification is provided if available.
- Client must disclose if existing furniture must be dismantled.
- Client must disclose if existing furniture must be preserved.
- Furniture and components must be delivered to the installation area before master arrives.
- Workspace must be prepared by the client.
- Personal belongings must be removed by the client.

#### Master Guidance
- Verify niche dimensions against project.
- Verify wall material and safe fastening independently.
- Verify stretch ceiling and reinforcements before installation.
- Verify electrical connection point if lighting/electrical elements are included.
- Verify packaging and completeness before installation.
- Record packaging damage or part damage in platform chat before work starts.
- If preserved furniture is dismantled, place parts in agreed area and collect fittings in one bag/box.

#### Built-in Furniture Rules
- Main document is the product scheme with dimensions and construction.
- After the scheme, the most important data is installation place/niche dimensions.
- Niche dimensions must match project dimensions or construction tolerances.
- Installation complexity is determined not only by external size, but also by internal filling.
- Client measurements are treated as higher risk than manufacturer measurements.
- Master independently verifies safe fastening.
- Stretch ceiling and reinforcements must be checked before installation.
- Lighting/electrical connections increase installation complexity and must be considered.

#### Furniture Rules Stored Inside Built-in Furniture
- Furniture must be delivered before installation.
- Master does not organize transport, lifting, storage or logistics.
- Master does not pack furniture for moving.
- Furniture disassembly is a separate service.
- Furniture disassembly with preservation: 50% of installation price.
- Hardware/fittings are collected into one bag/box.
- Transport, storage, packing and removal are outside the service scope.

#### Pricing
- Built-in Furniture Base Price: from 3,500 THB.
- Furniture disassembly: 50% of installation price.
- Control measurement and completeness verification: 500 THB.
- Prices are MVP baselines and must be editable from Admin Panel.

#### Premium Services
- Control measurement.
- Completeness verification.
- Recommended, not mandatory.
- Especially useful for kitchens, built-in furniture and complex furniture projects.

#### Admin Dependencies
- Built-in Furniture Base Price.
- Furniture Disassembly Percent.
- Inspection Service Price.
- Dynamic niche measurement table.
- Required photos management.
- Master eligibility by Advanced furniture skill level.

---

### 16.4 Furniture Skill Levels
Status: APPROVED ✅

- Basic: Cabinet Furniture.
- Intermediate: Kitchen Assembly.
- Advanced: Built-in Furniture.

Purpose:
Control master access to complex furniture orders.

---

### 16.5 Furniture Admin Settings
Status: APPROVED ✅

Future Admin Panel must support:
- Kitchen Assembly Base Price.
- Cabinet Furniture Base Price.
- Built-in Furniture Base Price.
- Furniture Disassembly Percent.
- Inspection Service Price.
- Required photo management.
- Question management.
- Rule visibility.
- Master eligibility rules.
---
## 17. Service Architecture Registry — Cleaning
Status: APPROVED ✅
Registry Status: STORED + DOCS ✅

### Root Category
Cleaning

### Subcategories
- Regular Cleaning ✅ STORED + DOCS
- Deep Cleaning ✅ STORED + DOCS
- Post-Repair Cleaning ✅ STORED + DOCS

---

### 17.1 Regular Cleaning
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions

1. Тип объекта
- Кондо
- Квартира
- Дом
- Таунхаус
- Другое

2. Площадь объекта
- До 30 м²
- 31–50 м²
- 51–80 м²
- 81–120 м²
- Более 120 м²

3. Есть ли балкон?
- Да
- Нет

Если Да:

4. Требуется уборка балкона?
- Да
- Нет

Если Да:

5. Площадь балкона
- До 3 м²
- 4–6 м²
- 7–10 м²
- Более 10 м²

6. Есть ли домашние животные?
- Да
- Нет

Если Да:

7. Какие животные?
- Текстовое поле

#### Required Photos

Обязательные:
- Кухня — 1 фото.
- Санузел — 2 фото с разных ракурсов.
- Спальня — 2 фото с разных ракурсов.

Итого:
- 5 обязательных фото.

Дополнительно:
- Гостиная.
- Балкон (если выбран).
- Дополнительные помещения.

Максимум:
- 10 фотографий.

#### Client Rules

- Предоставить доступ к зонам уборки.
- Убрать деньги, документы и ценные вещи.
- Если используются специальные средства клиента — согласование через чат.

#### Master Rules

- Не перемещать вещи клиента.
- Не сортировать вещи клиента.
- Использовать безопасные средства при наличии животных.


---

### 17.2 Deep Cleaning
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions

Все вопросы Regular Cleaning.

Дополнительно:

8. Помещение пустое?
- Да
- Нет

#### Required Photos

Такие же, как в Regular Cleaning.

#### Client Rules

- Подготовить мебель для внутренней уборки.
- Если мебель не подготовлена — внутренняя уборка не выполняется.
- Убрать личные вещи из зон внутренней уборки.

#### Master Rules

- Внутренняя уборка только пустой мебели.
- Не перекладывать вещи клиента.
- Не выполнять внутреннюю уборку неподготовленных зон.

---

### 17.3 Post-Repair Cleaning
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Scope

- Строительная пыль.
- Следы краски.
- Следы герметика.
- Следы шпаклёвки.
- Строительные загрязнения.
- Двойная влажная уборка.

#### Client Questions

1. Тип объекта
- Кондо
- Квартира
- Дом
- Таунхаус
- Другое

2. Площадь объекта
- До 30 м²
- 31–50 м²
- 51–80 м²
- 81–120 м²
- Более 120 м²

3. Есть ли балкон?
- Да
- Нет

Если Да:

4. Требуется уборка балкона?
- Да
- Нет

Если Да:

5. Площадь балкона
- До 3 м²
- 4–6 м²
- 7–10 м²
- Более 10 м²

Вопрос про животных отсутствует.

#### Required Photos

Такие же, как в Regular Cleaning.

#### Client Rules

- До начала уборки убрать строительные материалы.
- До начала уборки убрать инструмент.
- Если ремонт продолжается — уборка после ремонта не выполняется.

#### Master Rules

- Исполнитель не отвечает за новую пыль после завершения работ.


## Air Conditioning

Registry Status: 🟨 STORED FOR RE-AUDIT

Reason:
- Первая полноценно проработанная категория Helpy.
- Содержит исторические решения и требует приведения к текущему шаблону Registry.

Approved Legacy Structure:

ROOT: Air Conditioning

- Чистка кондиционера;
- Кондиционер не холодит;
- Кондиционер течет;
- Установка кондиционера;
- Демонтаж кондиционера;
- Пульт управления кондиционером;
- Перенос кондиционера (disabled на запуске).

Removed:
- Ремонт кондиционера.

Reason:
- Для рынка Паттайи чаще выгоднее заменить оборудование, чем ремонтировать его.

Legacy Rules:
- Демонтаж ≠ утилизация.
- Дополнительные работы согласуются через чат.
- Профилактическое обслуживание отдельно не выделяется и воспринимается клиентом как чистка.
- Каждая подкатегория должна иметь собственные вопросы, фотографии и правила.
- Категории и подкатегории должны иметь независимый enabled/disabled статус.

Open For Re-Audit:
- Финальные вопросы.
- Финальные фото.
- Pricing.
- Client Rules.
- Master Rules.
- Service Playbook.
- Business Rules.
- Admin Dependencies.
- FAO.

GAP:
- Требуется перенос на актуальный шаблон Helpy.
- Требуется повторный аудит по утвержденному процессу.

## Electrical

Registry Status: 🟨 STORED FOR RE-AUDIT

Reason:
- Категория №2 после Air Conditioning.
- Содержит утвержденные исторические решения и требует приведения к текущему шаблону Registry.

Approved Legacy Structure:

ROOT: Electrical

Enabled:
- Розетки и выключатели;
- Диагностика неисправности;
- Подключение бытовой техники.

Disabled on launch:
- Освещение;
- Потолочные вентиляторы.

Excluded From MVP:
- Автоматы / электрощит;
- Прокладка проводки;
- Замена проводки;
- Аварийная электрика.

Reason:
- Высокий риск.
- Высокая ответственность.
- Часто нужен лицензированный специалист.
- Не приоритет для MVP.

Approved Legacy Rules:
- Клиент выбирает проблему, а не профессию.
- Установка ≠ замена.
- Замена подразумевает демонтаж.
- Установка не подразумевает демонтаж.
- Материалы и дополнительные работы согласуются между мастером и клиентом через чат.
- Платформа не участвует в покупке материалов.
- Каждая подкатегория должна иметь собственные вопросы, фото, правила и enabled/disabled статус.

Electrical Diagnostics:
- Не работает розетка.
- Не работает выключатель.
- Нет света.
- Периодически пропадает питание.
- Искрит.
- Не знаю.
- Другое.

Appliance Connection:
- Варочная панель.
- Духовой шкаф.
- Вытяжка.
- Другое.

TECH DEBT:
- Расширить бытовую технику позже при реальном спросе.
- Возможные будущие элементы: микроволновая печь, измельчитель отходов, встроенный холодильник, винный шкаф, кофемашина, ледогенератор, другая кухонная техника.

Open For Re-Audit:
- Финальные вопросы.
- Финальные фото.
- Pricing.
- Client Rules.
- Master Rules.
- Service Playbook.
- Business Rules.
- Admin Dependencies.
- FAO.

GAP:
- Требуется перенос на актуальный шаблон Helpy.
- Требуется повторный аудит по утвержденному процессу.

## Plumbing

Plumbing
├── Кран / Смеситель
├── Засор
├── Унитаз
└── Проточный водонагреватель

### Plumbing → Кран / Смеситель

Registry Status: ✅ STORED + DOCS

Root Question:
Что нужно сделать?

Approved Branches:
- Установить новый кран/смеситель ✅ STORED + DOCS
- Заменить существующий кран/смеситель ✅ STORED + DOCS

Excluded From MVP:
- Кран/смеситель не работает
  - Reason: usually leads to replacement and does not add enough value as a separate branch.
- Кран/смеситель протекает
  - Reason: often creates small low-margin diagnostic/material trips and distracts masters from predictable jobs.
- Другая проблема
  - Reason: no real MVP scenarios identified outside install or replacement.

### Plumbing → Кран / Смеситель → Установить новый

Registry Status: ✅ STORED + DOCS

Question Flow:
1. Новый кран/смеситель находится на объекте?
   - Да → continue form.
   - Нет → stop form. Client creates a new order only after the equipment is physically on site.

2. Где будет установлен новый кран/смеситель?
   - Раковина
   - Кухня
   - Душ
   - Балкон

Photo Requirements By Answer:

Раковина:
Required Photos:
- общий вид раковины и места установки
- упаковка нового крана/смесителя с двух сторон
- точки подключения воды
- фото, позволяющее оценить расстояние от места установки до точек подключения

Optional Photos:
- пространство под раковиной, если есть возможность сделать такую фотографию

Кухня:
Required Photos:
- общий вид кухонной мойки и места установки
- упаковка нового крана/смесителя с двух сторон
- точки подключения воды под мойкой
- пространство под кухонной мойкой

Optional Photos:
- фото, позволяющее оценить расстояние между местом установки и точками подключения

Душ:
Required Photos:
- общий вид душевой зоны
- упаковка нового крана/смесителя с двух сторон
- место установки
- точки подключения воды

Not Required:
- фото проточного водонагревателя

Балкон:
Required Photos:
- общий вид места установки
- упаковка нового крана/смесителя с двух сторон
- точки подключения воды

Not Required:
- фото окружающего пространства балкона

Client Rules:
- Клиент отвечает только на вопросы, которые он объективно может понять.
- Клиент не должен вскрывать упаковку оборудования для создания заказа.
- Клиент обязан подготовить рабочую зону к моменту приезда мастера.
- Если оборудование отсутствует на объекте, форма заказа останавливается.

Master Rules:
- Мастер не трогает, не перекладывает и не выносит личные вещи клиента.
- Мастер не вскрывает упаковку, пока не убедится, что кран/смеситель подходит для данного объекта.
- Мастер может через чат уточнить технические детали, выявить скрытые работы, определить необходимость материалов и однократно зафиксировать окончательную стоимость заказа.
- Мастер не может запрашивать фотографии в чате.

Business Rules:
- Helpy доверяет фактам, а не обещаниям.
- Форма заказа собирает первоначальное ТЗ и закрывает визуальную часть ТЗ.
- Чат завершает текстовую часть ТЗ и фиксирует окончательную стоимость заказа.
- Платформа определяет стартовую цену входа для каждой подкатегории заказа.
- Окончательная цена фиксируется мастером один раз, обосновывается в чате и после согласования клиентом становится неизменяемой.
- Комиссия платформы рассчитывается от окончательно утвержденной стоимости заказа.
- Водонагреватели являются отдельной подкатегорией и не входят в ТЗ установки крана/смесителя.
- Отсутствие необязательной фотографии не блокирует создание заказа.
- Если доступ ограничен, дополнительные работы обсуждаются через чат до фиксации окончательной стоимости.

Admin / Analytics Rules:
- Администратор может просматривать любой чат.
- Чат используется не только для споров, но и для контроля качества, аналитики и улучшения форм заказа.

### Plumbing → Кран / Смеситель → Заменить существующий

Registry Status: ✅ STORED + DOCS

Definition:
- Замена = демонтаж старого крана/смесителя + установка нового крана/смесителя.

Question Flow:
1. Новый кран/смеситель находится на объекте?
   - Да → continue form.
   - Нет → stop form. Client creates a new order only after the equipment is physically on site.

2. Где нужно заменить кран/смеситель?
   - Раковина
   - Кухня
   - Душ
   - Балкон

Inherited From Install Flow:
- Клиент не вскрывает упаковку оборудования для создания заказа.
- Мастер не вскрывает упаковку, пока не убедится, что кран/смеситель подходит для данного объекта.
- Клиент обязан подготовить рабочую зону к моменту приезда мастера.
- Мастер не трогает, не перекладывает и не выносит личные вещи клиента.
- Форма заказа собирает первоначальное ТЗ и закрывает визуальную часть ТЗ.
- Чат завершает текстовую часть ТЗ и фиксирует окончательную стоимость заказа.
- Мастер не может запрашивать фотографии в чате.

Additional Photo Requirements By Answer:

Раковина:
Install flow photos +
- общий вид существующего крана
- фото крепления снизу, если доступно

Кухня:
Install flow photos +
- общий вид существующего крана/смесителя
- фото крепления снизу, если доступно

Душ:
Install flow photos +
- общий вид существующего душевого смесителя

Балкон:
Install flow photos +
- общий вид существующего крана

Demolished Equipment Rules:
- Демонтированное оборудование является собственностью клиента.
- Демонтированное оборудование остается на объекте.
- Мастер не обязан забирать, выносить или утилизировать демонтированное оборудование.
- Если клиент просит мастера выбросить демонтированное оборудование, это личная договоренность между клиентом и мастером.
- Вынос или утилизация демонтированного оборудования не является услугой Helpy, не входит в стоимость заказа, не участвует в комиссии и не является предметом спора платформы.

Master Service Playbook:
- Перед началом демонтажа мастер обязан отключить воду.
- До вскрытия упаковки мастер обязан убедиться, что новое оборудование подходит для данного объекта.
- После вскрытия упаковки и перед монтажом мастер обязан визуально проверить оборудование.
- Мастер обязан быстро проверить движимые элементы нового оборудования.
- После завершения работ мастер обязан проверить результат: работу крана/смесителя и отсутствие протечек.
- Мастер обязан предоставить клиенту готовый результат.
- После работы мастер обязан оставить рабочее место в чистоте.
- Мастер убирает мусор и расходники, возникшие в результате его работы: старые прокладки, упаковочный мусор, использованные расходные материалы.
- Это правило не распространяется на демонтированное оборудование клиента.

Business Rules:
- Замена включает демонтаж и монтаж.
- Демонтаж и монтаж считаются разными составляющими работы.
- Стартовая цена входа задается платформой для подкатегории.
- Окончательная цена фиксируется мастером один раз, обосновывается в чате и после согласования клиентом становится неизменяемой.
- Комиссия платформы рассчитывается от окончательно утвержденной стоимости заказа.

GAP:
- Нет. Подкатегория завершена.

### Plumbing → Засор

Registry Status: ✅ STORED + DOCS

Business Decision:
- Подкатегория остается в MVP.
- Засоры дают быстрые недорогие заказы и могут помочь получить объем на старте Helpy.
- Подкатегория может быть включена/отключена через Admin Panel после анализа реальной статистики.

Question Flow:
1. Где засор?
   - Раковина
   - Кухонная мойка
   - Душевой слив
   - Унитаз

2. Что происходит?
   - Вода уходит медленно
   - Вода не уходит совсем

Removed Questions:
- Что уже пробовал клиент
- Опишите проблему своими словами

Removal Reason:
- Не влияют на первоначальное ТЗ.
- Не влияют на стартовую цену.
- Не влияют на обязательные фотографии.
- При необходимости мастер уточняет это в чате.

Photo Requirements By Answer:

Раковина:
Required Photos:
- вид раковины сбоку так, чтобы были видны чаша и сливное отверстие
- фото пространства под раковиной с видом на сифон

Кухонная мойка:
Required Photos:
- вид мойки сбоку так, чтобы были видны чаша и сливное отверстие
- фото пространства под мойкой с видом на сифон

Душевой слив:
Required Photos:
- общий вид душевой зоны
- фото сливного трапа крупным планом

Унитаз:
Required Photos:
- общий вид унитаза
- фото чаши сверху

Client Rules:
- Клиент отвечает только на вопросы, которые объективно может понять.
- Клиент не обязан знать техническую причину засора.
- Клиент не обязан описывать проблему свободным текстом, если место засора и симптом уже выбраны.
- Клиент обязан предоставить обязательные фотографии по выбранному месту засора.

Master Rules:
- Мастер изучает выбранное место засора, симптом и фотографии до отклика.
- Если мастеру важно знать, что клиент уже пробовал, он может уточнить это через чат.
- Мастер не может запрашивать дополнительные фотографии в чате.
- Мастер обязан обосновать изменение окончательной стоимости через чат, если после уточнений выявлены дополнительные работы.

Service Playbook:
- Форма собирает минимальное первоначальное ТЗ.
- Цель формы — не заменить мастера, а дать достаточно данных для осознанного отклика.
- Фото сифона / трапа / чаши помогают заранее оценить доступ, сложность и возможные дополнительные работы.
- Засор является управляемой MVP-подкатегорией: решение о дальнейшем включении принимается по статистике после запуска.

Business Rules:
- Стартовая цена входа задается платформой для подкатегории.
- Окончательная цена фиксируется мастером один раз, обосновывается в чате и после согласования клиентом становится неизменяемой.
- Комиссия платформы рассчитывается от окончательно утвержденной стоимости заказа.
- Администратор может включать/отключать подкатегорию через Admin Panel.
- Реальные данные после запуска важнее предположений.

GAP:
- Нет. Подкатегория завершена.

### Plumbing → Унитаз

Registry Status: ✅ STORED + DOCS

Scenarios:
- Установить новый унитаз ✅ STORED + DOCS
- Заменить существующий унитаз ✅ STORED + DOCS
- Неисправность бачка унитаза ✅ STORED + DOCS

Question Flow:

Вопрос 1:
Что нужно сделать?

- Установить новый унитаз;
- Заменить существующий унитаз;
- Не набирается вода в бачок;
- Вода постоянно течет в чашу.

### Установить новый унитаз

Вопрос 2:
Новый унитаз находится на объекте?

- Да;
- Нет.

Логика:
- Да → продолжаем форму.
- Нет → форма останавливается.

Required Photos:
- Фото места установки.
- Упаковка нового унитаза со всей информацией на ней.
- Фото подключения воды.
- Фото канализационного выпуска.

### Заменить существующий унитаз

Definition:
- Замена = демонтаж существующего унитаза + установка нового унитаза.

Вопрос 2:
Новый унитаз находится на объекте?

- Да;
- Нет.

Логика:
- Да → продолжаем форму.
- Нет → форма останавливается.

Required Photos:
- Общий вид существующего унитаза с 2 ракурсов.
- Упаковка нового унитаза со всей информацией на ней.
- Фото подключения воды.
- Фото канализационного выпуска.

Demolished Equipment Rules:
- Демонтированный унитаз является собственностью клиента.
- Демонтированный унитаз остается на объекте.
- Мастер не обязан выносить или утилизировать демонтированный унитаз.
- Вынос или утилизация не являются услугой Helpy.
- Личная договоренность клиента и мастера не относится к платформе.

Global Rule:
- При фотографировании упаковки оборудования клиент предоставляет упаковку со всей информацией на ней.
- Клиент не обязан понимать, какая информация является технической.

### Неисправность бачка унитаза

Вопрос 1:
Что происходит?

- Вода постоянно течет в чашу;
- В бачок не набирается вода.

Дополнительные вопросы:
- Отсутствуют.

Причина:
- Не влияют на первоначальное ТЗ.
- Не влияют на стартовую цену.
- Не влияют на обязательные фотографии.
- Клиент не обязан разбираться в устройстве бачка.
- При необходимости мастер уточняет детали в чате.

Required Photos:
- Общий вид унитаза с 2-х ракурсов.
- Фото чаши сверху.
- Фото бачка сверху.

Removed Photos:
- Фото бачка с открытой крышкой.
- Фото узла подачи воды.

Removal Reason:
- Клиент не должен разбирать оборудование.
- Исключается риск повреждения крышки бачка.
- Клиент может случайно устранить неисправность самостоятельно.
- Фото подачи воды обычно не относится к данной неисправности.

Master Service Rule:
- Мастер выполняет ремонт только при наличии доступа к бачку и его механизмам.
- Если доступ отсутствует и требуется демонтаж стены, короба, плитки или иных строительных конструкций, такие работы не входят в данную услугу.
- Работы по обеспечению доступа рассматриваются как отдельная услуга и согласовываются отдельно.
- Наличие инсталляции само по себе не является ограничением.
- Если предусмотрен сервисный доступ к механизму, работа выполняется в рамках данной услуги.

GAP:
- Нет. Подкатегория завершена.

### Plumbing → Электрический душ (водонагреватель)

Registry Status: 🟨 STORED PARTIALLY

Root Question:
Что нужно сделать?

Approved Branches:
- Установить новый ✅ STORED + DOCS
- Заменить существующий ✅ STORED + DOCS
- Плохо греет воду 🟨 RE-AUDIT
- Протекает 🟨 RE-AUDIT
- Выбивает автомат / отключается электричество 🟨 RE-AUDIT

Naming Decision:
- Название категории изменено с «Проточный водонагреватель» на «Электрический душ (водонагреватель)».
- Причина: клиенту понятнее бытовое название, но технический термин сохраняется в скобках.
- Внутри категории ветки начинаются с действия или проблемы, без повторения названия оборудования.

### Plumbing → Электрический душ (водонагреватель) → Установить новый

Registry Status: ✅ STORED + DOCS

Definition:
- Установка = монтаж нового электрического душа без демонтажа существующего оборудования.

Question Flow:

1. Новый электрический душ находится на объекте?
   - Да → continue form.
   - Нет → stop form. Client creates a new order only after the equipment is physically on site.

2. Заливной шланг уже куплен?
   - Да
   - Нет

Logic:
- Если заливной шланг отсутствует, мастер уточняет необходимую длину через чат после изучения фотографий.
- Клиент не обязан производить измерения.
- Клиент не обязан разбираться в технических деталях подключения.

Required Photos:
- Упаковка нового электрического душа со всей информацией на ней.
- От 1 до 3 фотографий, позволяющих оценить место установки электрического душа, расположение точки подключения воды и расположение ближайшего электрического подключения.

Photo Rules:
- Если вся информация видна на одном фото — достаточно одного.
- Если точки подключения находятся в разных местах — допускается до 3 фотографий.
- Клиент не обязан вскрывать оборудование.
- Клиент не обязан разбирать розетки, автоматы или проводку.
- Клиент не должен выполнять действия, связанные с электричеством.

Chat Completion Rules:
- Если точка подключения воды находится далеко, мастер уточняет длину заливного шланга через чат.
- Если ближайшее электрическое подключение находится далеко, мастер уточняет необходимость и длину дополнительного электрического кабеля через чат.

### Plumbing → Электрический душ (водонагреватель) → Заменить существующий

Registry Status: ✅ STORED + DOCS

Definition:
- Замена = демонтаж существующего электрического душа + установка нового электрического душа.

Question Flow:

1. Новый электрический душ находится на объекте?
   - Да → continue form.
   - Нет → stop form. Client creates a new order only after the equipment is physically on site.

2. Новый заливной шланг нужен?
   - Да
   - Нет

Logic:
- Новое оборудование желательно оснащать новыми элементами подводки.
- При ответе «Нет» допускается использование существующего заливного шланга.
- Если существующий заливной шланг изношен, повреждён, не подходит по длине или не подходит к новому оборудованию, мастер согласовывает решение через чат до фиксации окончательной стоимости.

Required Photos:
- Упаковка нового электрического душа со всей информацией на ней.
- Общий вид существующего электрического душа, позволяющий оценить условия демонтажа и замены.

Photo Rules:
- Клиент не демонтирует существующее оборудование.
- Клиент не вскрывает корпус устройства.
- Клиент не разбирает розетки, автоматы или проводку.
- Клиент не выполняет действий, связанных с электричеством.

Demolished Equipment Rules:
- Демонтированный электрический душ является собственностью клиента.
- Демонтированный электрический душ остается на объекте.
- Мастер не обязан выносить или утилизировать демонтированный электрический душ.
- Вынос или утилизация не являются услугой Helpy.
- Личная договоренность клиента и мастера не относится к платформе.

Global Rules:
- При фотографировании упаковки оборудования клиент предоставляет упаковку со всей информацией на ней.
- Клиент не обязан понимать, какая информация является технической.
- Форма собирает первоначальное ТЗ.
- Чат завершает текстовую часть ТЗ и фиксирует окончательную стоимость.
- Мастер не может запрашивать дополнительные фотографии в чате.
- Не требовать от клиента небезопасных фотографий.

GAP:
- Завершить аудит ветки «Плохо греет воду».
- Завершить аудит ветки «Протекает».
- Завершить аудит ветки «Выбивает автомат / отключается электричество».

## Locks

Registry Status: ✅ STORED + DOCS

Root Category:
Locks (Замки)

Business Scope:
- Категория предназначена только для работ внутри объекта клиента.
- Категория не является аварийной службой вскрытия.
- Категория не работает с входными дверями.

Approved Subcategories:
1. Замена замка межкомнатной двери
2. Установка замка межкомнатной двери
3. Замена мебельного замка
4. Установка врезного мебельного замка

Excluded From MVP:
- Входные двери
- Вскрытие помещений
- Аварийное открытие дверей
- Замена личинки
- Скобяные задвижки
- Работы со стеклом
- Врезка замка в стекло
- Отдельные подкатегории для шкафов, тумб, комодов, ящиков и витрин

Business Rules:
- Helpy не оказывает услуги вскрытия входных дверей.
- Helpy не работает с вопросами собственности, аренды и права доступа.
- Работы выполняются внутри объекта клиента.
- Работы в публичных зонах не входят в MVP.
- Замена = демонтаж старого элемента + монтаж нового элемента.
- Установка = монтаж нового элемента без демонтажа существующего.
- Клиент выбирает результат, а не технологию выполнения работ.
- Технические детали определяет мастер.

Future Architecture Note:
- После завершения Furniture Assembly, Cleaning и Handyman провести отдельный аудит Locks vs Handyman.
- Предварительная гипотеза: Locks может стать подкатегорией внутри Handyman.
- Решение не утверждено до проектирования Handyman.

### Locks → Замена замка межкомнатной двери

Registry Status: ✅ STORED + DOCS

Definition:
- Замена = демонтаж существующего замка межкомнатной двери + установка нового замка.

Question Flow:
1. Новый замок уже куплен?
   - Да
   - Нет

2. Что произошло с текущим замком?
   - Не работает
   - Работает плохо, требуется замена

Required Photos:
- Общий вид замка с первой стороны двери.
- Общий вид замка со второй стороны двери.
- Торец двери крупным планом.

Required If New Lock Already Bought:
- Фото технических характеристик и комплектации на упаковке нового замка.

Service Playbook:
- Мастер оценивает тип механизма, способ крепления, посадочное место и сложность демонтажа.
- Если новый замок куплен, мастер проверяет совместимость до демонтажа существующего замка.

### Locks → Установка замка межкомнатной двери

Registry Status: ✅ STORED + DOCS

Definition:
- Установка = установка нового замка межкомнатной двери.
- Врезка может быть частью работы, но не выносится в название услуги.

Question Flow:
1. Был ли ранее установлен замок в этой двери?
   - Да
   - Нет

2. Новый замок уже куплен?
   - Да
   - Нет

Photos If Lock Was Previously Installed:
- Общий вид посадочного места с одной стороны двери.
- Общий вид посадочного места с другой стороны двери.
- Посадочное место в торце двери крупным планом.
- Посадочное место в дверной коробке крупным планом.

Photos If Lock Was Not Previously Installed:
- Общий вид двери с первой стороны.
- Общий вид двери со второй стороны.

Required If New Lock Already Bought:
- Фото технических характеристик и комплектации на упаковке нового замка.

Service Playbook:
- Если замок ранее был установлен, мастер оценивает существующие посадочные места.
- Если замок ранее не устанавливался, мастер учитывает разметку, врезку корпуса замка, врезку ответной планки и подготовку посадочных мест.

### Locks → Замена мебельного замка

Registry Status: ✅ STORED + DOCS

Definition:
- Замена = демонтаж существующего мебельного замка + установка нового мебельного замка.

Question Flow:
1. В каком изделии будет выполняться работа?
   - Обязательное текстовое поле.

2. Новый мебельный замок уже куплен?
   - Да
   - Нет

3. Что произошло с текущим мебельным замком?
   - Не работает
   - Работает плохо, требуется замена

Required Photos:
- Общий вид изделия.
- Вид мебельного замка снаружи.
- Фото двери или элемента мебели под углом, чтобы была видна обратная сторона двери и конструкция изделия.

Required If New Lock Already Bought:
- Фото технических характеристик и комплектации на упаковке нового замка.

Service Playbook:
- Мастер оценивает изделие, тип установленного мебельного замка, крепление, конструкцию и совместимость нового замка.
- Отдельные подкатегории по типу мебели не создаются.

### Locks → Установка врезного мебельного замка

Registry Status: ✅ STORED + DOCS

Definition:
- Установка нового мебельного замка в изделие, где ранее мебельный замок отсутствовал.

Question Flow:
1. В каком изделии будет выполняться работа?
   - Обязательное текстовое поле.

2. Новый мебельный замок уже куплен?
   - Да
   - Нет

Required Photos:
- Общий вид изделия.
- Фото двери или элемента мебели под углом, чтобы была видна обратная сторона двери и конструкция изделия.

Required If New Lock Already Bought:
- Фото технических характеристик и комплектации на упаковке нового замка.

Service Playbook:
- Мастер оценивает изделие, конструкцию, толщину материала, совместимость замка и необходимость дополнительной фурнитуры.
- Работа включает разметку, создание посадочного места, врезку мебельного замка, проверку работоспособности и регулировку при необходимости.
- Если мебельный замок ранее был установлен, используется подкатегория «Замена мебельного замка».

Global Equipment Packaging Rule:
- Если клиент уже приобрел новое оборудование самостоятельно, Helpy не требует вскрытия упаковки до подтверждения совместимости мастером.
- Достаточно фотографии упаковки, на которой видны модель, технические характеристики, размеры и комплектация, если она указана производителем.
- Платформа не требует вскрывать упаковку, нарушать заводские пломбы, раскладывать комплектующие или извлекать оборудование из коробки.
- Клиент должен сохранить право на возврат, обмен и гарантийное обслуживание.

Global Equipment Verification Rule:
- Если работа предполагает замену оборудования, мастер обязан проверить новое оборудование до демонтажа существующего.
- Проверка включает совместимость, комплектность, целостность и возможность установки.
- Только после проверки мастер приступает к демонтажу.

Marketplace Safety Rule:
- Платформа не должна заставлять клиента выполнять действия, которые могут ухудшить его положение как покупателя оборудования.
- Примеры: вскрытие упаковки, нарушение пломб, потеря возможности возврата или обмена.

GAP:
- Финальный общий аудит всех категорий выполняется позже перед переносом в Client Docs / Master Docs / Admin Rules.

## Global Rule → Chat Lifecycle Rules

Status: APPROVED GLOBAL RULE ✅

Purpose:
- Chat is not a messenger.
- Chat is a business process tool and changes its role depending on the order lifecycle stage.

### Stage 1. Initial Scope Collection

Client:
- Sends photos only through the order form.

Purpose:
- Build the initial technical specification (TЗ).

### Stage 2. Chat Before Work Starts

Allowed:
- Clarifying questions.
- Discussion of hidden works.
- Material clarification.
- Technical discussion.
- Price justification.
- One-time final price agreement.

Forbidden:

Client:
- Cannot send additional photos.

Master:
- Cannot send photos.

Reason:
- Chat must not become a remote diagnostic/help center.

### Stage 3. Start Work

Trigger:
- Master presses "Start Work".

After this action:

Client:
- Photo sending remains unavailable.

Master:
- Photo sending becomes available.

Purpose:
- Protect the master.
- Record hidden defects.
- Record dangerous conditions.
- Provide evidence.

### Stage 4. Work Completion

Master obligations:
- Verify the result of work.
- Take final photos of completed work.
- Send final photos through Helpy chat.

Examples:
- Installed equipment.
- Final result.
- Clean work area.

### Stage 5. Client Confirmation

Client:
- Reviews the result.
- Confirms work completion.

Before confirmation:
- The master cannot complete the order.

### Stage 6. Complete Order

Trigger:
- "Complete Order" button becomes available to the master only after client confirmation.

Result:
- Order status changes to completed.
- Review flow starts.
- Historical data is preserved.
- Order becomes available for analytics and disputes.

Business Principles:
- Chat is part of the order workflow.
- Chat protects the client.
- Chat protects the master.
- Chat protects the platform.
- Chat generates knowledge for improving Helpy.

## Job Events / Order Timeline Contract

Status: APPROVED CANONICAL ✅

### Purpose

`job_events` is the append-only platform timeline for an order.

It is the source of truth for:
- order lifecycle audit;
- Admin Panel order timeline;
- disputes;
- evidence flow;
- completion flow;
- payment/financial timeline visibility;
- operational analytics;
- future notifications.

### Data Separation

`chat_messages` stores human communication.

`job_events` stores business process history.

System/platform lifecycle events must not be stored as fake user chat messages.

Chat may explain human context.
`job_events` must record business facts.

### Core Fields

- id;
- job_id;
- event_type;
- actor_user_id;
- actor_role;
- payload_json;
- created_at.

### Immutability Rule

`job_events` are append-only.

Normal users must not edit, delete or hide job events.

Admin must not rewrite business history.

If correction or intervention is required, it must be recorded as a new event.

### Actor Rule

`actor_user_id` may be null only for pure system/platform events.

`actor_role` must be one of:
- client;
- master;
- admin;
- system.

### Canonical Event Types

#### Order / Scope

- order_created;
- job_published;
- job_cancelled.

#### Offer / Price

- initial_offer_sent;
- price_adjustment_requested;
- price_adjustment_approved;
- final_application_sent;
- master_selected.

#### Financial

- financial_snapshot_created;
- deposit_created;
- deposit_paid;
- commission_obligation_created;
- refund_issued.

#### Work / Evidence / Completion

- work_started;
- evidence_uploaded;
- completion_confirmed_by_client;
- job_completed.

#### Review / Dispute / Admin

- review_submitted;
- dispute_opened;
- dispute_resolved;
- admin_intervention.

### Event Visibility Principle

Admin can see all job events.

Client and master timelines may show selected user-facing events only.

Internal/system events may be hidden from mobile UI while remaining visible to Admin.

### Current Runtime Coverage

Current backend already writes:
- master_selected;
- work_started;
- evidence_uploaded;
- completion_confirmed_by_client;
- job_completed.

Current backend reads:
- completion_confirmed_by_client.

### Current DB Domain Coverage

Current migration `0004_job_events_timeline.sql` already supports:
- deposit_paid;
- master_selected;
- work_started;
- work_completed_by_master;
- completion_confirmed_by_client;
- job_completed;
- dispute_opened;
- dispute_resolved;
- job_cancelled;
- review_submitted;
- refund_issued;
- admin_intervention;
- price_adjustment_requested;
- price_adjustment_approved;
- evidence_uploaded;
- attachment_policy_changed.

### Known Domain Gap

The current DB domain does not yet include all canonical event types.

Missing canonical event types:
- order_created;
- job_published;
- initial_offer_sent;
- final_application_sent;
- financial_snapshot_created;
- deposit_created;
- commission_obligation_created.

Deprecated / legacy event types:
- work_completed_by_master.

Reserved / admin configuration event types:
- attachment_policy_changed.

### Implementation Rule

No runtime code should emit an event type that is not documented here.

No migration should be written from this contract alone.

Before DB migration, create a concrete migration plan that:
- adds missing canonical event types;
- preserves existing event history;
- keeps compatibility with current runtime events;
- documents deprecated/reserved event types;
- includes APPLY / REGISTER / DONE / audit / smoke.

### Timeline Rule

Timeline contracts must be derived from this event contract.

Mobile timelines may display only selected event types.

Admin timelines must preserve the complete event history.

## Timeline API Contract

Status: APPROVED ✅

### Purpose

Timeline API exposes `job_events` as an ordered order lifecycle timeline.

Timeline API must serve:
- client order timeline;
- master order timeline;
- admin order timeline;
- dispute evidence review;
- operational audit.

### Source Of Truth

Timeline API reads from `job_events`.

Timeline API must not rebuild business history from chat messages.

Timeline API may enrich events with related job, payment, offer, photo, review or dispute data, but `job_events` remains the lifecycle source.

### Endpoints

Client / Master:

GET /api/v1/jobs/:jobId/timeline

Admin:

GET /api/v1/admin/jobs/:jobId/timeline

### Access Rules

Client may read timeline only for own job.

Selected master may read timeline only for selected job.

Master with active pre-selection offer may later read only pre-selection timeline context if approved.

Admin may read full timeline for any job.

### Visibility Rules

Admin timeline shows all events.

Client and master timelines show only user-facing events.

Internal/system events may be hidden from mobile while remaining visible to Admin.

### Timeline Visibility Matrix

| event_type | Client | Master | Admin | Mobile Timeline | Internal Only |
|---|---:|---:|---:|---:|---:|
| order_created | yes | no | yes | yes | no |
| job_published | yes | if eligible / active offer | yes | yes | no |
| job_cancelled | yes | if participant | yes | yes | no |
| initial_offer_sent | yes | owner master | yes | yes | no |
| price_adjustment_requested | yes | owner master | yes | yes | no |
| price_adjustment_approved | yes | owner master | yes | yes | no |
| final_application_sent | yes | owner master | yes | yes | no |
| master_selected | yes | selected master | yes | yes | no |
| financial_snapshot_created | no | no | yes | no | yes |
| deposit_created | yes | selected master | yes | yes | no |
| deposit_paid | yes | selected master | yes | yes | no |
| commission_obligation_created | no | selected master | yes | yes | no |
| refund_issued | yes | if affected | yes | yes | no |
| work_started | yes | selected master | yes | yes | no |
| evidence_uploaded | yes | selected master | yes | yes | no |
| completion_confirmed_by_client | yes | selected master | yes | yes | no |
| job_completed | yes | selected master | yes | yes | no |
| review_submitted | yes | selected master | yes | yes | no |
| dispute_opened | yes | selected master | yes | yes | no |
| dispute_resolved | yes | selected master | yes | yes | no |
| admin_intervention | no | no | yes | no | yes |

### Visibility Rules By Role

Client can see:
- own order lifecycle events;
- selected master lifecycle events;
- offer/price events for offers visible to the client;
- payment/deposit/refund events affecting the client.

Master can see:
- own offer events;
- selected work lifecycle events after selection;
- commission obligation events affecting the master;
- dispute/review events related to selected work.

Admin can see:
- all events;
- internal-only events;
- legacy/reserved events;
- malformed payload warnings when implemented.

### Mobile Timeline Filter Rule

Mobile Timeline must render only events where `Mobile Timeline = yes`.

Mobile must not locally override visibility.

Timeline API is responsible for filtering events according to actor role and relationship to the order.


### Guidance Trigger Matrix

Guidance Trigger Matrix defines which lifecycle events may trigger contextual guidance or next-step CTA cards.

Guidance is not hardcoded in Flutter.

Timeline events may trigger guidance lookup by:
- event_type;
- role;
- screen;
- workflow stage;
- category;
- subcategory;
- language.

| event_type | Client Guidance | Master Guidance | Runtime Now | Purpose |
|---|---:|---:|---:|---|
| order_created | yes | no | no | explain next step before publication |
| job_published | yes | eligible / offer master | no | explain marketplace visibility and offer review |
| initial_offer_sent | yes | owner master | no | explain offer received / waiting state |
| price_adjustment_requested | yes | owner master | no | explain price justification and client decision |
| price_adjustment_approved | yes | owner master | no | explain approved revised price |
| final_application_sent | yes | owner master | no | explain final application and selection |
| master_selected | yes | selected master | yes | guide chat, arrival coordination and deposit state |
| financial_snapshot_created | no | no | no | admin-only financial audit |
| deposit_created | yes | selected master | no | explain deposit/payment obligation |
| deposit_paid | yes | selected master | no | explain next step after payment |
| commission_obligation_created | no | selected master | no | explain master platform commission obligation for cash flow |
| work_started | yes | selected master | yes | guide evidence photos and work process |
| evidence_uploaded | yes | selected master | yes | explain evidence review / continue work |
| completion_confirmed_by_client | yes | selected master | yes | unlock master complete order guidance |
| job_completed | yes | selected master | yes | guide review / closeout |
| review_submitted | yes | selected master | no | explain reputation / completion closure |
| dispute_opened | yes | selected master | no | explain dispute process |
| dispute_resolved | yes | selected master | no | explain resolution outcome |
| admin_intervention | no | no | no | admin-only operational context |

### Guidance Trigger Rules

If `Runtime Now = yes`, mobile may use the event once Timeline API is implemented.

If `Runtime Now = no`, the trigger is approved but must wait until backend emits the event.

Guidance lookup must not be implemented as local Flutter `if event_type` text.

Flutter may use event_type only to request or place guidance records.

Actual guidance text must come from Guidance Records through API.

### CTA Rule

Guidance may include CTA metadata later.

Examples:
- open_chat;
- pay_deposit;
- upload_evidence_photos;
- confirm_completion;
- complete_order;
- leave_review;
- open_dispute.

CTA availability must still be validated by backend business rules.

Mobile must not use guidance CTA as the source of permission.

### Default Sorting

Timeline events are returned in ascending chronological order by default.

created_at ASC

API may later support DESC pagination for large timelines.

### Response Shape

Response must use the standard API envelope:

{
  "success": true,
  "data": {
    "job_id": "...",
    "timeline": [
      {
        "id": "...",
        "event_type": "master_selected",
        "actor_user_id": "...",
        "actor_role": "client",
        "created_at": "...",
        "payload": {},
        "visibility": {
          "client": true,
          "master": true,
          "admin": true
        }
      }
    ]
  }
}

### Event Payload Rule

payload_json is stored as text in DB.

Timeline API must return parsed payload as object.

Invalid payload_json must not crash timeline response.

If payload_json is invalid, API returns an empty object and may include admin-only warning later.

### Mobile Timeline Rule

Mobile must not infer lifecycle from job status alone when timeline is available.

Mobile may render selected timeline events as system cards.

Mobile must not display internal-only events.

### Admin Timeline Rule

Admin timeline must preserve full event history.

Admin timeline must support dispute review, evidence review, payment review and operational audit.

### Localization Rule

Timeline API may return raw event_type first.

User-facing labels must be produced through localization layer or guidance/timeline label registry.

Hardcoded event labels inside Flutter are not allowed.

### Relationship With Guided Job Flow

Timeline API is the read model for Guided Job Flow lifecycle history.

Guided Job Flow defines what should happen.

job_events records what happened.

Timeline API exposes what happened to clients, masters and admins according to visibility rules.

---

## Global GAP → Reviews & Reputation System

Status: ✅ APPROVED

Review Flow:

Вопрос 1:
Как вы оцениваете работу мастера?

- ☆ ☆ ☆ ☆ ☆ (горизонтальный выбор 1–5 звёзд).

Вопрос 2:
Что вы можете отметить?
(можно выбрать несколько вариантов)

- Соблюдал договорённости;
- Работа выполнена аккуратно;
- Убрал за собой после завершения работ;
- Готов(а) обратиться к этому мастеру снова.

Комментарий:
- Необязателен.

Review Rules:
- Клиент самостоятельно решает, оставлять комментарий или нет.
- Экран отзыва можно закрыть.
- Создание новых заказов не блокируется.

Master Metrics:
- ⭐ Качество работы;
- 🛠 Опыт;
- 💬⏰ Надёжность;
- 💬 Отзывы.

Reliability:
- Отражает соблюдение договорённостей.
- Включает соблюдение согласованного времени и качество предварительной коммуникации.
- Использует утверждённый фирменный значок Helpy.

Reputation MVP Formulas:
- ⭐ Качество работы = средняя оценка по оставленным отзывам.
- 🛠 Опыт = количество завершённых заказов.
- 💬⏰ Надёжность = количество отзывов с отметкой «Соблюдал договорённости» / общее количество оставленных отзывов.
- 💬 Отзывы = количество оставленных отзывов.

Reliability Calculation Rules:
- Учитываются только оставленные отзывы.
- Завершённые заказы без отзывов не участвуют в расчёте.
- Закрытый экран отзыва не влияет на репутацию мастера.
- Отсутствие отзыва не считается ни положительным, ни отрицательным сигналом.
- Не используются скрытые коэффициенты.
- Не используются временные веса.
- Не используются штрафы для новых мастеров.
- Платформа не делает выводов за клиента.

Rating Display:
- Показывается сразу после первого отзыва.
- Новые мастера отображаются без специальных ограничений.
- Платформа не создаёт искусственных преимуществ или ограничений.

Reviews:
- Показывается количество отзывов.
- При нажатии открывается список комментариев клиентов.

Admin / Analytics Notes:
- Reviews помогают клиентам принимать решения.
- Reviews используются для контроля качества.
- Reviews используются для аналитики платформы.

GAP:
- Admin moderation rules.
- Anti-abuse rules.

## Global Decision → Chat Evidence Photos & Job Details Photo Ownership

Status: ✅ APPROVED

Scope:
- Mobile chat.
- Backend photo upload endpoint.
- Client job details screen.
- Master job details screen.
- RU / EN / TH localization.

Chat Evidence Photo Rules:
- Master evidence photos are allowed only for the selected master during `in_progress`.
- One user action of selecting N photos creates one chat system message.
- Backend upload batching must not leak into UX.
- Example: if the master selects 10 photos, mobile may upload them as 3+3+3+1, but chat must show one message only.
- Approved chat system message format:
  - RU: `Мастер прикрепил N 📷`
  - EN: `The master attached N 📷`
  - TH: `ช่างแนบ N 📷`
- The message is stored as a normal chat message with localized `text_translations_json`.
- Evidence photos are rendered inline under the upload message in chat.
- Evidence photos must not be rendered as a separate block at the top of chat.
- This keeps evidence visually connected to the exact chat event that created it.
- Current MVP detection of evidence-photo system messages is text-pattern based for RU / EN / TH.
- Future schema improvement: replace text-pattern detection with explicit message type or metadata when chat message schema is revised.

Job Details Photo Display Rules:
- Job details must separate photos into two visual sections:
  - Client photos.
  - Master photos.
- Client and master details screens must use the same grouping logic.
- Empty photo sections are hidden.
- If no photos exist at all, show the existing "photos not saved" message.
- Photo section labels must be localized in RU / EN / TH.
- Master evidence/result photos remain visible in job details after completion.
- This is intentional: both client and master should see the result/history of work after completion.

Photo Ownership Contract:
- `job_photos.client_user_id` currently stores the actor user id that uploaded the photo.
- Backend proof:
  - `INSERT INTO job_photos (... client_user_id ...)`
  - `.bind(id, jobId, actorUserId, url, now)`
- API proof:
  - `GET /jobs/:id/photos` returns `client_user_id`.
- Mobile treats this returned value as `ownerUserId`.
- Current grouping rule:
  - `photo.ownerUserId == job.selectedMasterUserId` → Master photos.
  - Otherwise → Client photos.
- The current field name is legacy and misleading, but current behavior is correct for MVP.

Recorded Technical Debt:
- `job_photos.client_user_id` should be reviewed during the next canonical DB/schema revision.
- Preferred future name: `owner_user_id` or `uploaded_by_user_id`.
- Rename must be done only after read-only usage audit across backend, mobile, admin, migrations and live D1 data.
- Do not rename this field as an isolated quick patch.

---

## Order Entry Price / Final Price Contract

Status: APPROVED ✅

### Platform Entry Price

For each order, the platform assigns a single Entry Price.

Entry Price is calculated by the platform based on the average market price of the selected work type, category, subcategory, client answers and approved pricing rules.

Entry Price:
- is shown to the client during order creation and order review;
- is shown to masters in Marketplace;
- is the starting price of the order;
- is part of the permanent order history;
- is not the final legally significant order price;
- is not used for final commission calculation after master price revision.

### Master One-Time Price Revision

After reviewing the order scope and communicating with the client, the master may change the Entry Price only once.

Price revision is allowed only before the client selects the master.

Price revision requires:
- clear explanation from the master;
- client agreement with the reason;
- client confirmation of the revised price in chat.

The system must store:
- original Entry Price;
- revised master price;
- price change reason;
- confirmation timestamp;
- master user id;
- client confirmation evidence.

Repeated price changes are forbidden for normal users.

Exceptions are allowed only through admin-controlled business rules.

### Final Master Application

After the revised price is agreed and confirmed, the master sends a final application to the client.

The client selects the master based on this confirmed final price.

At the moment of selection, the platform fixes:
- selected master;
- final agreed price;
- selected offer/application;
- commission base amount.

### Commission Rule

Platform commission is calculated only from Final Agreed Price.

Deposit = Final Agreed Price × 30%

### Post-Selection Work Lifecycle

After client selects the master:
- chat is used for arrival coordination;
- master presses Start Work after arriving on site;
- Start Work creates job_events.work_started;
- master uploads evidence photos;
- client confirms completion;
- order can proceed to review or dispute.

### Admin Visibility

Admin Order Timeline must show:
- platform Entry Price;
- master revised price if changed;
- price change reason;
- client confirmation evidence;
- final agreed price;
- payment method;
- deposit amount;
- commission payer;
- chat history;
- work_started event;
- evidence photos;
- completion;
- review;
- dispute state.


---

## Communication Layer / Business Timeline Contract

Status: APPROVED ✅

### Core Principle

Human communication and business lifecycle events must be stored and treated as separate layers.

Chat messages are user communication.

Job events are the immutable business timeline of the order.

This separation is required to prevent business-rule drift, protect dispute evidence and support the future Admin Panel.

### Human Chat Layer

Human chat is stored in `chat_messages`.

Human chat is used for:
- pre-selection communication;
- order scope clarification;
- price discussion;
- arrival coordination;
- normal participant communication;
- supporting evidence context.

Human chat may contain messages, replies and attachments.

Human chat must not be used as the only source of legally significant lifecycle state.

### Business Timeline Layer

Business lifecycle events are stored in `job_events`.

`job_events` is the append-only platform timeline.

Timeline events include:
- price_adjustment_requested;
- price_adjustment_approved;
- master_selected;
- deposit_paid;
- work_started;
- evidence_uploaded;
- completion_confirmed_by_client;
- job_completed;
- review_submitted;
- dispute_opened;
- dispute_resolved;
- refund_issued;
- admin_intervention.

Business state changes must be represented as timeline events, not only as chat text.

### Price Negotiation Evidence Rule

Price negotiation may happen in chat.

However, the legally significant result of price negotiation must be stored as timeline events.

When a master changes the Entry Price:
- the explanation may be discussed in chat;
- the client confirmation may happen in chat;
- the platform must also record the confirmed business result in `job_events`.

Required events:
- price_adjustment_requested;
- price_adjustment_approved.

The chat provides human context.

The timeline provides the business proof.

### Admin Chat Access Rule

Admin must be able to access any order chat from the Admin Panel.

Admin chat access is required for:
- dispute review;
- quality control;
- evidence review;
- operational support;
- fraud prevention;
- business-rule enforcement.

Admin access to chat must be read-only by default unless an explicit admin action is recorded as `admin_intervention`.

### Timeline Immutability Rule

Normal users must not edit, delete or hide `job_events`.

Admin must not rewrite business history.

If admin action is required, it must be recorded as a new `admin_intervention` event.

### Chat Evidence Rule

Chat has two different evidence meanings and they must not be mixed.

Price justification evidence:
- before the client selects a master, the master may explain why the Entry Price must change;
- the explanation may happen in chat;
- the client must understand and confirm the revised price before it becomes final;
- the platform must record the confirmed price result in `job_events`;
- required timeline events: price_adjustment_requested and price_adjustment_approved.

Completion evidence:
- after work starts, the master must upload evidence photos;
- evidence photos prove hidden defects, unsafe conditions, work process and final result;
- the client must confirm completion before the master can complete the order;
- only after client completion confirmation may the master access Complete Order;
- completion confirmation and completion must be recorded in `job_events`.

Disputes must use:
- chat history;
- job_events timeline;
- price change history;
- payment state;
- evidence photos;
- completion state;
- review state.

### Admin Order Timeline Requirement

Admin Order Timeline must combine:
- human chat context from `chat_messages`;
- lifecycle events from `job_events`;
- payment/deposit state;
- evidence photos;
- selected master;
- completion;
- review;
- dispute state.

The Admin Panel must present these layers together while keeping their data responsibilities separate.


---

## Chat Threads Architecture Decision

Status: APPROVED ✅

### Decision

Helpy will use `chat_threads` as the canonical chat context model.

Chat is not a side feature.

Chat is part of the order workflow, business logic, evidence model and future Admin Panel control layer.

### Why

A single order can have multiple chat contexts:
- pre-selection negotiation with each master;
- post-selection work coordination;
- evidence discussion;
- dispute/support review;
- admin-visible operational context.

Using only `job_id` for chat messages would mix different business contexts into one conversation and create long-term drift.

### Canonical Model

`chat_threads` will represent the chat context.

`chat_messages` will belong to a chat thread.

A thread may be linked to:
- job;
- offer;
- selected master;
- lifecycle stage;
- thread type;
- thread status.

### Initial Thread Types

- pre_selection_offer;
- work;
- dispute;
- admin_support.

### Business Rules

Pre-selection offer threads:
- one thread per job + offer;
- visible to the client and the offering master;
- not visible to other masters;
- used for scope clarification and price negotiation.

Work thread:
- created or activated after master selection;
- visible to the client and selected master;
- used for arrival coordination, work execution and evidence context.

Admin:
- can read all threads for an order from the Admin Panel;
- must see thread type, participants, lifecycle stage and related timeline events;
- admin interventions must be recorded as `admin_intervention` events, not by rewriting chat history.

### Timeline Separation

`chat_threads` and `chat_messages` provide human communication context.

`job_events` remains the immutable business timeline.

Chat threads must not replace `job_events`.

`job_events` must not be stored as fake chat messages.


---

## Offer Lifecycle Architecture Decision

Status: APPROVED ✅

### Decision

Helpy will use `offers.status` + offer lifecycle fields + `job_events` for offer lifecycle state, facts and immutable history.

### Responsibility Split

`offers.status` stores current operational state.

Offer lifecycle fields store business facts:
- initial_offer_price;
- revised_offer_price;
- price_revision_reason;
- price_revision_requested_at;
- final_application_sent_at;
- final_agreed_price.

`job_events` stores immutable business history:
- price_adjustment_requested;
- price_adjustment_approved;
- final_application_sent;
- master_selected.

### Why

Status alone is not enough because it does not preserve price amounts, reason, confirmation time and evidence.

Fields alone are not enough because they make current state ambiguous and complicate UI/API business rules.

`job_events` alone is not enough because operational screens need current state and direct facts without rebuilding state from the full timeline.

### Business Rule

Master selection is allowed only after a final application exists.

Final agreed price must be fixed before deposit/commission calculation.

Repeated master price revision is forbidden for normal users unless an admin-controlled business rule explicitly allows it.


---

## Thailand Payment Runtime Architecture Decision

Status: APPROVED ✅

### Decision

Helpy payment runtime must follow Thailand-first payment behavior.

### PromptPay QR

PromptPay QR is the primary deposit payment method.

For PromptPay:
- client pays platform;
- payment type is deposit;
- deposit equals 30% of Final Agreed Price;
- commission payer is client;
- payment status must support pending, paid, failed and expired.

### Cash

Cash is a mandatory option.

For Cash:
- client pays the full Final Agreed Price directly to the master;
- platform does not receive client deposit immediately;
- platform creates a master commission obligation;
- commission payer is master;
- commission obligation equals 30% of Final Agreed Price.

Cash must not be modelled as client deposit paid to platform.

### Bank Transfer

Bank Transfer is an alternative method for larger customers.

MVP model may be simple:
- client transfers deposit to platform bank account;
- payment starts as pending;
- admin or verified process marks payment as paid;
- proof workflow may be added later.

### Wallet / TrueMoney

Wallets, including TrueMoney, are reserved as configurable payment methods.

Wallet availability must be controlled by platform financial settings.

### Cards

Cards are reserved for later market rollout.

Card-related schema may remain for future expansion, but runtime/mobile must not expose cards while card_enabled is false.

### Canonical Rule

Payment method determines payment obligation:

PromptPay:
- client → platform;
- deposit/commission.

Cash:
- master → platform;
- commission obligation.

Bank Transfer:
- client → platform;
- deposit with manual/verified confirmation.


---

## Final Price Architecture Decision

Status: APPROVED ✅

### Decision

Helpy will use offer-level final price history together with a job-level financial snapshot.

### Responsibility Split

Offer lifecycle preserves negotiation history:

- initial_offer_price;
- revised_offer_price;
- final_agreed_price.

Jobs preserve the immutable financial result of the order:

- final_agreed_price;
- commission_base_amount;
- deposit_percent;
- deposit_amount;
- payment_method;
- commission_payer.

### Why

Offer data answers:

> How did the parties arrive at this price?

Job data answers:

> Which financial conditions became part of the order?

Using only jobs would lose price evolution.

Using only offers would couple financial execution to negotiation records.

### Canonical Rule

When a master is selected:

- jobs.final_agreed_price becomes the financial snapshot;
- commission_base_amount is fixed;
- deposit_percent is fixed;
- deposit_amount is fixed;
- payment_method is fixed;
- commission_payer is fixed.

Later negotiations must not rewrite historical financial snapshots.


---

## Structured Job Scope / Price Justification Contract

Status: APPROVED ✅

### Structured Job Scope

A Helpy order scope is not free text.

Initial job scope is formed from:
- category;
- subcategory;
- selected service branch;
- dynamic question flow;
- client answers;
- required photos;
- category business rules;
- category photo rules;
- category service playbook rules.

The Plumbing category is the reference standard for structured scope formation.

### Scope Formation Rule

Client answers and required photos form the initial technical assignment for the order.

The form collects the initial scope and closes the visual part of the scope.

The chat completes the textual clarification part of the scope.

Masters must not request additional photos in chat when required photos were already defined by the form.

### Entry Price Rule

Platform Entry Price is assigned by platform/admin pricing rules for the selected service type before the final job scope is completed.

The client enters the order under this Entry Price.

Structured job scope allows the master to validate the scope, accept the Entry Price or justify a one-time price increase.

Entry Price is not based only on free-text description.

### Price Justification Rule

If a master changes the Entry Price, the master must justify the change against the structured job scope.

The justification must explain what was not covered by the initial scope, client answers, required photos or visible conditions.

Examples:
- hidden work discovered from required photos;
- access limitation visible from photos;
- additional material length or connection distance;
- equipment mismatch;
- condition that changes work complexity;
- missing required equipment on site when the selected branch requires it.

`price_revision_reason` is a structured business field, not only a chat comment.

Chat may contain discussion, but the final price justification must be stored in offer lifecycle data and represented in `job_events`.

### Admin Visibility

Admin must be able to compare:
- structured job scope;
- client answers;
- required photos;
- Entry Price;
- master price justification;
- revised price;
- client confirmation;
- Final Agreed Price;
- related chat context;
- related job_events.

---
## Helpy Canonical Order Lifecycle Contract

Status: APPROVED ✅

Admin / Platform
↓
sets Entry Price

Client
↓
sees Entry Price
↓
agrees to enter under this price
↓
answers structured questions
↓
uploads required photos
↓
forms the initial structured job scope
↓
publishes the order

Master
↓
reviews the structured job scope
↓
either accepts Entry Price
↓
or performs ONE justified price increase
↓
explains the reason in chat
↓
stores `price_revision_reason`
↓
submits an application with Final Price

Client
↓
selects the master
↓
thereby officially accepts Final Price

System
↓
creates immutable financial snapshot
↓
calculates commission from Final Price
↓
calculates deposit from Final Price

Then
↓
Start Work
↓
Evidence Photos
↓
Client Completion Confirmation
↓
Master Complete Order
↓
Review / Dispute

Canonical Rules:
- Entry Price is defined by platform/admin pricing rules.
- Initial job scope is formed through structured questions and required photos.
- Masters may revise Entry Price only once.
- Price revision must be justified against the structured job scope.
- Chat contains human explanation.
- Structured fields and `job_events` contain business facts.
- Client selection of the master constitutes acceptance of Final Price.
- Financial snapshots become immutable after fixation.
- Commission and deposit are always based on Final Price.
---
## Guided Job Flow Foundation

Status: APPROVED ✅

### Definition

Helpy is a Guided Job Flow platform.

Helpy is not a traditional service marketplace.

The primary responsibility of the platform is to guide an order through a controlled lifecycle from entry conditions to a verified outcome.

### Central Object

The order is the center of the system.

Not masters.
Not clients.
Not chat.
Not payments.

All other components exist to support the successful completion of the order lifecycle.

### Purpose

Guided Job Flow exists to help participants safely and predictably complete a job.

The platform guides participants through:

- structured questions;
- required photos;
- service playbooks;
- contextual guidance;
- business rules;
- pricing safeguards;
- evidence protection;
- dispute prevention;
- operational controls.

### Structured Scope Principle

Entry Price is always defined by platform/admin pricing rules.

Structured forms do not calculate Entry Price.

Structured questions and required photos exist to:

- form the initial job scope;
- allow masters to validate the scope;
- allow one justified price increase when necessary;
- protect all participants through evidence;
- support transparent Final Price formation.

### Canonical Lifecycle

Admin / Platform
↓
sets Entry Price

Client
↓
sees Entry Price
↓
agrees to enter under this price
↓
answers structured questions
↓
uploads required photos
↓
forms the initial structured job scope
↓
publishes the order

Master
↓
reviews the structured job scope
↓
either accepts Entry Price
↓
or performs ONE justified price increase
↓
explains the reason in chat
↓
stores price_revision_reason
↓
submits an application with Final Price

Client
↓
selects the master
↓
thereby officially accepts Final Price

System
↓
creates immutable financial snapshot
↓
calculates commission from Final Price
↓
calculates deposit from Final Price

Then
↓
Start Work
↓
Evidence Photos
↓
Client Completion Confirmation
↓
Master Complete Order
↓
Review / Dispute

### Canonical Rules

- Entry Price is defined by platform/admin pricing rules.
- Initial job scope is formed through structured questions and required photos.
- Masters may revise Entry Price only once.
- Price revision must be justified against the structured job scope.
- Chat contains human explanation and agreements.
- Structured fields and job_events contain business facts.
- Client selection of the master constitutes acceptance of Final Price.
- Financial snapshots become immutable after fixation.
- Commission and deposit are always based on Final Price.
- Evidence Photos and Completion are mandatory parts of the lifecycle.
- Disputes use the complete evidence package.

### Product Positioning

Traditional marketplaces answer:

"Who should I hire?"

Guided Job Flow answers:

"How do we safely and predictably guide this job to a successful outcome?"

### Governance Rule

All future decisions regarding categories, screens, APIs, databases, admin capabilities and business logic must be evaluated against Guided Job Flow principles.

If a future decision contradicts Guided Job Flow, the contradiction must be explicitly justified and approved before implementation.
---
## Contextual Guidance Knowledge System

Status: APPROVED ✅

### Definition

Helpy does not treat documents as passive reference materials.

Helpy transforms accumulated platform knowledge into contextual guidance shown exactly when participants need it.

This system is a core part of Guided Job Flow.

### Core Principle

Users should not search for knowledge.

The platform delivers the right knowledge at the right moment.

### Guidance Levels

Level 1 — Structured Scope Formation

The platform gathers objective facts through:
- category;
- subcategory;
- scenario branch;
- structured questions;
- client answers;
- required photos.

Purpose:
- reduce chaos;
- improve initial job scope quality;
- support transparent Final Price formation.

Level 2 — Client Guidance

Clients receive contextual prompts while creating and managing orders.

Examples:
- do not open equipment packaging before master arrival;
- prepare the work area before arrival;
- review the completed work before confirmation.

Level 3 — Master Guidance

Masters receive contextual prompts relevant to the current order.

Examples:
- study photos before applying;
- verify equipment compatibility before opening packaging;
- justify hidden work through chat if a price revision is required.

Level 4 — Workflow Guidance

Guidance depends on the current lifecycle stage.

Examples:

After Master Selection:
- client coordinates arrival through chat;
- master coordinates arrival through chat.

In Progress:
- master records hidden defects and work stages using evidence photos;
- client reviews results before confirmation.

Before Completion:
- client is informed that confirmation closes the order;
- master is informed that completion becomes available only after client confirmation.

Level 5 — Living Knowledge Base

Client Docs, Master Docs, Service Playbooks and Admin Rules become structured knowledge sources.

They are not passive documents.

### Knowledge Flow

Client Docs
      ↓
Master Docs
      ↓
Service Playbooks
      ↓
Admin Rules
      ↓
Guidance Records
      ↓
API
      ↓
Mobile UI

### Runtime Rule

Mobile applications must never read Markdown documents directly.

Mobile applications consume only structured guidance records delivered by API.

Example structure:

{
  "context": "before_offer",
  "role": "master",
  "category": "plumbing",
  "subcategory": "faucet_replace",
  "text": "Do not open equipment packaging before compatibility verification."
}

### Guidance Context Dimensions

Guidance may depend on:
- role;
- category;
- subcategory;
- scenario branch;
- workflow stage;
- form step;
- language.

### Governance

Guidance Records must support:
- Draft / Published;
- Audit Log;
- Preview;
- RU / EN / TH localization;
- publication without APK rebuild.

### Business Outcome

As Helpy grows, the platform scales accumulated experience.

Expected effects:
- fewer client mistakes;
- fewer master mistakes;
- fewer disputes;
- higher quality job scopes;
- faster onboarding of new masters;
- continuous platform improvement without mobile releases.

### Relationship With Guided Job Flow

Guidance is not FAQ.

Guidance is an operational component of Guided Job Flow.

Guided Job Flow answers:

"How does the order progress?"

Contextual Guidance answers:

"How does accumulated platform experience help participants succeed at each stage of the order?"
---
## Mobile Guidance Slots Contract

Status: APPROVED ✅

### Purpose

Mobile screens must not contain hardcoded business knowledge, service rules or contextual guidance.

Mobile screens must contain guidance slots: stable UI placement points where contextual guidance from API can be displayed.

### Core Rule

Flutter UI does not own platform knowledge.

Flutter UI only renders structured guidance records returned by API.

### Why

This prevents business-rule drift between:
- Registry;
- Admin Panel;
- API;
- Mobile UI;
- Client Docs;
- Master Docs;
- Service Playbooks.

### Required Guidance Slots

Mobile screens must reserve guidance slots for key Guided Job Flow stages:

- Create Job;
- photo upload;
- offer creation;
- offer review;
- pre-selection chat;
- price revision;
- master selection;
- deposit/payment;
- work chat;
- start work;
- evidence photos;
- client completion confirmation;
- master complete order;
- review;
- dispute.

### Slot Context

Each guidance request must be able to include:
- role;
- screen;
- category;
- subcategory;
- scenario branch;
- form step;
- job status;
- workflow stage;
- language.

### Runtime Rule

If API returns guidance records, the screen displays them in the matching slot.

If API returns no guidance records, the screen must remain clean and continue normally.

No screen should add local fallback business advice unless explicitly approved.

### Implementation Rule

When changing or creating mobile screens, developers must check whether the screen needs a guidance slot.

If guidance is required, add a generic reusable guidance rendering component.

Do not add hardcoded instructional text as a quick patch.

Do not wrap screens later with magic guidance overlays.

Do not duplicate business knowledge inside Flutter widgets.

### Admin Rule

Guidance content must be managed through Admin/Guidance Builder with:
- Draft / Published lifecycle;
- Audit Log;
- RU / EN / TH localization;
- Preview;
- publication without APK rebuild.

---
## Language Matching Principle

Status: APPROVED ✅

### Decision

Helpy separates three language concepts:

- UI Language;
- Original Content Language;
- Spoken Languages.

These concepts must not be mixed.

### UI Language

UI Language defines how the interface is displayed to the user.

It controls:
- buttons;
- labels;
- guidance;
- timeline labels;
- system messages;
- category texts.

UI Language must not be used as a proxy for communication compatibility.

### Original Content Language

Original Content Language is the language in which the client originally created the order content.

It is preserved as a business signal.

The localized title rule remains approved:

- main bold title is shown in the selected UI language;
- original client title is shown as secondary small text only if it meaningfully differs from the localized title;
- if translation is missing or identical, the original title is not duplicated.

This rule preserves original meaning and helps the platform understand the client communication context.

### Spoken Languages

Spoken Languages describe which languages a user can communicate in.

They are used for communication compatibility between client and master.

### Matching Rule

The platform should prefer masters who share at least one spoken language with the client.

Shared spoken language may improve:
- offer ranking;
- master recommendation;
- chat quality;
- conversion to selected master;
- completion quality;
- review quality;
- dispute prevention.

### Business Principle

Translation helps users understand content.

Language matching helps users communicate.

These are different platform responsibilities.

### Future Product Usage

Language compatibility may later affect:
- master ranking;
- badges in master profile;
- offer sorting;
- admin quality analytics;
- dispute analytics;
- onboarding recommendations.

---
## Language Matching Ranking Rule

Status: APPROVED ✅

### Decision

Language Matching is a ranking signal, not a hard filter.

The platform should prefer masters who share at least one spoken language with the client, but it must not hide other eligible masters.

### Rule

If a client and master share a spoken language:
- the master may receive ranking preference;
- communication quality is expected to improve;
- dispute risk may be reduced.

If no shared spoken language exists:
- the master may still be shown;
- the master may still apply;
- the client may still select that master.

### Business Reason

Helpy should improve communication quality without artificially limiting marketplace supply.

This is especially important in Pattaya, where masters and clients may speak different combinations of:
- RU;
- EN;
- TH;
- other regional languages.

### Implementation Principle

Language compatibility may affect:
- offer ordering;
- master recommendation;
- profile badges;
- admin analytics.

Language compatibility must not be used as the only eligibility rule unless a future explicit business rule is approved.

---
## Master Ranking Signal Hierarchy

Status: APPROVED ✅

### Decision

Master ranking signals are applied in the following conceptual order:

1. shared_spoken_language
2. work_quality_rating
3. reliability_ratio
4. completed_jobs_count
5. review_count

### Signal Meaning

shared_spoken_language
- communication compatibility signal;
- ranking signal only;
- must not hide other eligible masters.

work_quality_rating
- average star rating from submitted reviews;
- represents quality of completed work.

reliability_ratio
- represents adherence to agreements;
- includes punctuality and communication quality;
- uses the approved Helpy reliability icon;
- calculated only from actual submitted reviews.

completed_jobs_count
- represents accumulated experience;
- does not imply quality or reliability by itself.

review_count
- confidence/trust signal;
- increases confidence in other metrics;
- does not represent quality independently.

### Business Principle

Helpy should prioritize:
- effective communication;
- quality of work;
- reliability;
- practical experience;
- confidence in statistics.

No single signal should become an absolute eligibility filter unless explicitly approved by future business rules.
