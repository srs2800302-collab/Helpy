# Helpy Architecture Registry v1 Foundation

Status: APPROVED ✅

Approved By:
- Roman ✅
- Arthur ✅

## Contract Map / Architecture Groups
Status: APPROVED ✅

Purpose:
- Provide a logical navigation layer over the Architecture Registry.
- Preserve the historical recovery order of contracts.
- Group contracts by architectural responsibility without physically moving existing sections.
- Support closure planning before final Roadmap and new database design.

Rule:
- This map does not replace or rewrite existing contracts.
- Physical regrouping is deferred until Registry v2.
- Contract closure decisions must still be made inside the source contracts.
- New Registry changes should be written in Russian by default.
- English remains allowed for API paths, database entities, enum values, code identifiers and migration names.
- Registry is considered architecturally mature and largely finalized.
- Future changes must prioritize audit, reconciliation and closure of approved decisions.
- New architecture decisions require a proven GAP, contradiction between contracts or a new approved business model.
- Business logic, scenarios and explanatory text are written in Russian.
- Technical identifiers remain in English, including API paths, database entities, enum values, event_type, DTO, migrations, slugs and file names.
- Approved contracts must be strengthened through synchronization rather than rewritten without evidence.

### Group A — Foundation / Product Identity
Scope:
- Product identity.
- Long-term architecture principles.
- Core product and business model.
- Chat governance.
- Reference standards.
- Deferred categories.
- Future business direction.
- Recovery methodology.
- Guided Job Flow foundation.

Contracts:
- Contract 1 — Project Identity — CLOSED.
- Contract 2 — Long-Term Architecture Principle — CLOSED.
- Contract 3 — Core Product Principle — CLOSED.
- Contract 4 — Core Business Model — CLOSED.
- Contract 5 — Chat Governance — CLOSED.
- Contract 8 — Reference Category Standard — CLOSED.
- Contract 9 — Specialized Reference Categories — CLOSED.
- Contract 10 — Electrical Shower Policy — CLOSED.
- Contract 11 — Deferred Categories — CLOSED.
- Contract 18 — Future Business Direction — PARTIALLY CLOSED — FUTURE STRATEGY APPROVED.
- Contract 19 — Registry Expansion Plan — CLOSED — RECOVERY METHODOLOGY APPROVED.
- Contract 39 — Guided Job Flow Foundation — APPROVED ✅.

Closure Notes:
- Foundation is architecturally aligned.
- Future verticals remain post-MVP and require dedicated future contracts.

### Group B — Service Registry / Categories
Scope:
- Root categories.
- Category governance.
- Reference category completion.
- Service-specific question flows, photos, rules, playbooks and admin dependencies.

Contracts:
- Contract 6 — Approved Root Categories — PARTIALLY CLOSED.
- Contract 7 — Category Governance — PARTIALLY CLOSED.
- Contract 20 — Furniture Assembly — CLOSED — STORED + DOCS VERIFIED.
- Contract 21 — Cleaning — CLOSED — STORED + DOCS VERIFIED.
- Contract 22 — Air Conditioning — CLOSED — APPROVED / STORED + DOCS VERIFIED.
- Contract 23 — Electrical — CLOSED — STORED + CATEGORY ARCHITECTURE VERIFIED.
- Contract 24 — Plumbing — CLOSED — STORED + DOCS VERIFIED.
- Contract 25 — Locks — CLOSED — STORED + DOCS VERIFIED.

Closure Notes:
- Electrical is CLOSED and migrated to the current Plumbing-level Registry template.
- Appliance Installation & Connection remains the final required MVP root category before root category closure.
- Categories must support future expansion without schema redesign.

### Group C — Admin / Dynamic Forms / Knowledge / Guidance
Scope:
- Admin as Business Logic Builder.
- Dynamic Form Engine.
- Knowledge Base Engine.
- Guidance Builder.
- Guidance API.
- Mobile guidance slots and rendering.

Contracts:
- Contract 12 — Knowledge Base Engine — PARTIALLY CLOSED.
- Contract 13 — Dynamic Form Engine — PARTIALLY CLOSED.
- Contract 17 — Admin Panel Architecture — PARTIALLY CLOSED — GAP APPROVED.
- Contract 40 — Contextual Guidance Knowledge System — APPROVED ✅.
- Contract 41 — Mobile Guidance Slots Contract — APPROVED ✅.
- Contract 46 — Guidance API Contract — APPROVED ✅.
- Contract 47 — Mobile Guidance Component Contract — APPROVED ✅.

Closure Notes:
- Dynamic Form Engine closure depends on final pure dynamic vs hybrid decision.
- Admin Panel closure depends on builders, platform settings, guidance, rules, evidence, review and DB baseline strategy alignment.
- Guidance implementation requires future DB/API/mobile implementation planning, not direct migration from contract text alone.

### Group D — Order Lifecycle / Timeline / Chat / Evidence
Scope:
- Chat lifecycle.
- Immutable job_events timeline.
- Timeline API.
- Communication layer separation.
- Chat threads.
- Evidence photos.
- Canonical order lifecycle.

Contracts:
- Contract 26 — Chat Lifecycle Rules / Job Events / Timeline API — APPROVED GLOBAL RULE ✅ + GAP_APPROVED timeline sections.
- Contract 30 — Chat Evidence Photos & Job Details Photo Ownership — APPROVED ✅.
- Contract 32 — Communication Layer / Business Timeline Contract — GAP_APPROVED.
- Contract 33 — Chat Threads Architecture Decision — GAP_APPROVED.
- Contract 37 — Structured Job Scope / Price Justification Contract — APPROVED ✅.
- Contract 38 — Helpy Canonical Order Lifecycle Contract — GAP_APPROVED.

Closure Notes:
- Runtime must emit the full canonical timeline before timeline-related contracts can close.
- chat_threads must become the canonical chat context model in the future database.
- job_events remains the immutable lifecycle source of truth.

### Group E — Offers / Pricing / Payments / Financial Snapshot
Scope:
- Entry Price.
- Final Agreed Price.
- Offer lifecycle.
- Payment runtime for Thailand.
- Immutable financial snapshot.

Contracts:
- Contract 31 — Order Entry Price / Final Price Contract — APPROVED ✅.
- Contract 34 — Offer Lifecycle Architecture Decision — GAP_APPROVED.
- Contract 35 — Thailand Payment Runtime Architecture Decision — APPROVED ✅.
- Contract 36 — Final Price Architecture Decision — GAP_APPROVED.

Closure Notes:
- Canonical default deposit / commission percent is 30% of Final Agreed Price.
- 40% is rejected as incorrect legacy Chain 0001 value.
- Deposit / commission percent must be configurable from Admin Panel.
- jobs.deposit_percent stores the Admin-configured percent active at master selection.
- Historical financial snapshots must not be recalculated after Admin changes.
- Offer lifecycle and financial snapshot must be implemented in the future clean database/runtime design.

### Group F — Reviews / Reputation / Ranking / Language Matching
Scope:
- Reviews.
- Reputation metrics.
- Language matching.
- Master ranking.
- Client choice model.

Contracts:
- Contract 29 — Reviews & Reputation System — APPROVED ✅.
- Contract 42 — Language Matching Principle — APPROVED ✅.
- Contract 43 — Language Matching Ranking Rule — APPROVED ✅.
- Contract 44 — Master Ranking Signal Hierarchy — APPROVED ✅.
- Contract 45 — Master Ranking Hybrid Model Contract — APPROVED ✅.

Closure Notes:
- Reviews require admin moderation and anti-abuse rules before full closure.
- Ranking separates eligibility, ordering and client choice.
- Language matching is a ranking signal, not a hard eligibility filter.

### Group G — Recovery / Global Rules
Scope:
- Lost approved global platform rules.
- Recovery from approved sources.

Contracts:
- Contract 16 — Global Platform Rules — PARTIALLY CLOSED — RECOVERED FROM VERIFIED CATEGORY SOURCES.

Closure Notes:
- Seven global rules were previously approved, but their detailed texts are missing.
- Rules must be recovered from approved documentation, service playbooks, category records and approved history.
- Replacement rules must not be invented without evidence.

### Critical Closure Path
1. Recover Contract 16 Global Platform Rules.
2. Contract 23 Electrical — CLOSED.
3. Finalize Appliance Installation & Connection.
4. Close Contract 6 and Contract 7 root category governance.
5. Close Contract 13 Dynamic Form Engine decision.
6. Align Contract 17 Admin Panel Architecture.
7. Close canonical runtime/database group: Contracts 26, 32, 33, 34, 36 and 38.
8. Define Review moderation and anti-abuse rules for Contract 29.
9. Produce final Roadmap.
10. Design new clean database from the completed Roadmap and closed architecture contracts.

---

## Architecture Freeze Decision
Status: APPROVED ✅

Purpose:
- Preserve the agreed critical path.
- Prevent premature work on lifecycle architecture.
- Allow category completion without reopening already stabilized decisions.
- Provide a deterministic restart point if chat context is degraded.

Frozen Contracts:
- Contract 13 — Dynamic Form Engine.
- Contract 16 — Global Platform Rules.
- Contract 26/32/33/34/36/38 — Lifecycle Architecture Group.

Frozen Scope:
- Timeline.
- Chat Threads.
- Offer Lifecycle.
- Final Price Snapshot.
- Canonical Lifecycle.
- Clean Database Design.

Active Scope:
- Contract 23 — Electrical — CLOSED.
- Appliance Installation & Connection.
- Closure of Contract 6.
- Closure of Contract 7.

Unfreeze Conditions:
1. Electrical reaches CLOSED.
2. Appliance Installation & Connection reaches CLOSED.
3. Contract 6 reaches CLOSED.
4. Contract 7 reaches CLOSED.
5. Contract 16 is reconciled against DOCX/TXT evidence.

Next Milestone After Unfreeze:
- Close Lifecycle Architecture Group.
- Produce Final Roadmap.
- Design the new clean database.

Execution Order:
1. Extract Plumbing Category Development Methodology.
2. Contract 23 Electrical — CLOSED against Plumbing Standard.
3. Close Contract 23.
4. Complete Appliance Installation & Connection.
5. Close Contract 6 and Contract 7.
6. Reconcile Contract 16 against DOCX/TXT evidence.
7. Unfreeze Lifecycle Architecture Group.
8. Close Contracts 26/32/33/34/36/38.
9. Produce Final Roadmap.
10. Design the new clean database.

Process Rule:
- Work must follow the approved execution order.
- Earlier frozen milestones cannot be reopened without documentary evidence.
- Later milestones cannot start before prerequisite milestones are closed.
- Chat context degradation must not be used as justification to bypass the approved sequence.

---

## 1. Project Identity
Status: CLOSED

Decision Summary:
- Project identity is fixed for MVP.
- Helpy is an Android-first household services marketplace for Pattaya, Thailand.
- Supported product languages are RU / EN / TH.
- No unresolved architecture decisions remain in this contract.

- Project Name: Helpy
- Region: Pattaya, Thailand
- Platform: Android First
- Languages: RU / EN / TH
- Business Model: Marketplace of household services

## 2. Long-Term Architecture Principle
Status: CLOSED

Decision Summary:
- MVP may simplify or postpone complex features.
- MVP must preserve future expansion points.
- Architecture must not introduce dead ends or require full platform rewrite later.
- Business logic requiring admin control must not be hardcoded.
- No unresolved architecture decisions remain in this contract.

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
Status: CLOSED

Decision Summary:
- Client does not choose a master profession directly.
- Client chooses the work type.
- Client answers system-defined questions for the selected work type.
- Client adds the photos required by the system for assessment and routing.
- Platform uses category, answers, and photo requirements to route the job to relevant masters.
- Category exists for platform routing and master visibility, not as a profession selector for the client.
- No unresolved architecture decisions remain in this contract.

Client chooses problem, not profession.

Client describes the problem.
Platform determines the required specialist.

## 4. Core Business Model
Status: CLOSED

Decision Summary:
- 30% is the default platform commission value.
- Platform commission value is editable from Admin Panel without application release.
- Commission source depends on selected payment method.
- Thailand Payment Runtime Architecture Decision has priority.
- No unresolved architecture decisions remain in this contract.


Canonical business flow is defined by:
- Helpy Canonical Order Lifecycle Contract;
- Order Entry Price / Final Price Contract;
- Thailand Payment Runtime Architecture Decision.

Default Platform Commission:
30% of Final Agreed Price

Commission / Payment Source:
- PromptPay QR: client pays platform deposit.
- Bank Transfer: client pays platform deposit with manual/verified confirmation.
- Cash: client pays master directly; platform creates master commission obligation.

Commission Value:
Editable from Admin Panel.

Rule:
Commission source depends on selected payment method.
Core Business Model must not override the Thailand Payment Runtime Architecture Decision.

## 5. Chat Governance
Status: CLOSED

Decision Summary:
- Chat is mandatory for the order workflow.
- Chat stores agreements between client and master.
- Chat messages are evidence.
- Photos shared in chat are evidence.
- Admin can access any chat for moderation, support, and dispute resolution.
- Disputes must consider chat history.
- No unresolved architecture decisions remain in this contract.

- Chat is mandatory.
- Chat stores agreements.
- Chat is evidence.
- Photos in chat are evidence.
- Admin can access any chat.
- Disputes must consider chat history.

## 6. Approved Root Categories
Status: PARTIALLY CLOSED

Decision Summary:
- MVP root category set is not fully closed yet.
- The currently approved closed root categories are listed below.
- One required MVP root category remains to be finalized before this contract can be CLOSED.
- Root categories are client work/problem entry points, not master profession selectors.
- Root categories are used for routing, marketplace visibility, and admin control.
- Final database architecture and Admin Panel must support at least 20 root categories without schema redesign or application rewrite.

Closed Categories:
- Cleaning
- Air Conditioning
- Plumbing
- Electrical
- Locks
- Furniture Assembly

Next Category Required Before Final Closure:
- Appliance Installation & Connection
- Установка и подключение бытовой техники

## 7. Category Governance
Status: PARTIALLY CLOSED

Decision Summary:
- Category governance is aligned with the Approved Root Categories contract.
- Six MVP root categories are currently closed.
- One final MVP root category remains to be finalized before launch.
- No additional categories may be added before MVP launch.
- Category scaling starts only after real marketplace statistics are collected.
- Final database architecture and Admin Panel must support at least 20 root categories without schema redesign or application rewrite.

Helpy Categories

1. Cleaning
2. Air Conditioning
3. Plumbing
4. Electrical
5. Locks
6. Furniture Assembly

Electrical Category Architecture:
Status: CLOSED ✅

Purpose:
- Provide the category-level source of truth for Create Job screen design.
- Keep Electrical category navigation, form architecture, photo rules, client/master rules and admin dependencies in one place.
- Contract 23 remains the audit/history source; this category block is the practical implementation reference.

Root Category:
Electrical

Root Question:
Что нужно сделать?

Launch Branches:
- Установить розетку/выключатель.
- Заменить розетку/выключатель.
- Перенести розетку/выключатель.

Excluded From MVP:
- Автоматы / электрощит.
- Прокладка проводки.
- Замена проводки.
- Аварийная электрика.

Disabled On Launch:
- Освещение.
- Потолочные вентиляторы.

Moved / Future:
- Диагностика неисправности is moved to future Global Diagnostics.
- Appliance connection belongs to Appliance Installation & Connection.

Form Pattern:
- Electrical uses Point-Based Mini Scope Pattern.
- One physical work point equals one mini technical assignment.
- A mini assignment groups all data related to that point.
- Quantity is determined by the number of added mini scopes, not by a separate quantity question.

Mini Scope Contains:
- work type;
- point-specific parameters;
- required photos for that point.

Photo Pattern:
- Electrical uses Visual Coverage Principle.
- Photos must visually cover the work points.
- One photo may cover multiple points if they are clearly identifiable.
- Total photo limit per order remains 10.
- Equipment photos do not replace work-front photos.

Equipment Verification:
- If new items are already on site, client adds a general photo of those items.
- One photo may cover multiple identical items if the master can identify type, model and quantity.
- Equipment verification helps the master assess compatibility before Final Agreed Price.

### Electrical Category → Установить розетку/выключатель
Status: CLOSED ✅

Definition:
- Установка = монтаж новой розетки или выключателя без демонтажа существующего изделия.
- Одна точка установки = одно мини-ТЗ.

Question / Photo Flow:
1. Новые изделия уже есть на объекте?
   - Да
   - Нет

2. Что нужно установить?

For each work point:
- Что устанавливаем?
  - Розетка
  - Выключатель

- Тип установки:
  - Накладная
  - Внутренняя

- Фото места установки:
  - required

Add More Rule:
- Клиент может добавить одну или несколько точек через кнопку «Добавить ещё».
- Количество точек не задаётся отдельным вопросом.
- Количество точек определяется количеством созданных мини-ТЗ.

Photo Rule:
- Фотографии должны обеспечивать визуальное покрытие всех точек установки.
- Каждая точка установки должна быть однозначно идентифицируема мастером.
- Одно фото может покрывать несколько точек, если они хорошо различимы.
- Общий лимит фотографий заказа — 10.
- Клиент не обязан фотографировать щит, провода, автоматы или выполнять небезопасные действия.

Equipment Verification Rule:
- Если новые изделия уже есть на объекте, клиент добавляет фото общего вида этих изделий.
- Фото оборудования не заменяет фото фронта работ.
- Одно фото может покрывать несколько одинаковых изделий, если мастер видит тип, модель и количество.

Chat Completion Rule:
- Если тип установки, посадочное место, материалы или сложность работ требуют уточнения, мастер уточняет это через чат.
- Эти уточнения могут повлиять на Final Agreed Price до выбора мастера.

### Electrical Category → Заменить розетку/выключатель
Status: CLOSED ✅

Definition:
- Замена = демонтаж существующего изделия + установка нового изделия.
- Одна точка замены = одно мини-ТЗ.

Question / Photo Flow:
1. Новые изделия уже есть на объекте?
   - Да
   - Нет

2. Что нужно заменить?

For each work point:
- Что заменяем?
  - Розетка
  - Выключатель

- Тип установки:
  - Накладная
  - Внутренняя

- Фото существующего места установки:
  - required

Add More Rule:
- Клиент может добавить одну или несколько точек через кнопку «Добавить ещё».
- Количество точек не задаётся отдельным вопросом.
- Количество точек определяется количеством созданных мини-ТЗ.

Photo Rule:
- Фотографии должны обеспечивать визуальное покрытие всех точек замены.
- Существующие изделия должны быть однозначно идентифицируемы мастером.
- Одно фото может покрывать несколько точек, если они хорошо различимы.
- Общий лимит фотографий заказа — 10.
- Клиент не обязан разбирать изделия, фотографировать щит, провода или выполнять небезопасные действия.

Equipment Verification Rule:
- Если новые изделия уже есть на объекте, клиент добавляет фото общего вида этих изделий.
- Фото оборудования не заменяет фото существующих точек замены.
- Одно фото может покрывать несколько одинаковых изделий, если мастер видит тип, модель и количество.

Demolished Equipment Rule:
- Демонтированное изделие является собственностью клиента.
- Демонтированное изделие остаётся на объекте по умолчанию.
- Утилизация или вынос возможны только по отдельной договорённости через чат.

Chat Completion Rule:
- Если совместимость изделий, материалы, посадочные особенности или сложность работ требуют уточнения, мастер уточняет это через чат.
- Эти уточнения могут повлиять на Final Agreed Price до выбора мастера.

### Electrical Category → Перенести розетку/выключатель
Status: CLOSED ✅

Definition:
- Перенос = демонтаж существующего изделия + изменение расположения + установка изделия в новом месте.
- По умолчанию при переносе используется существующее изделие.
- Если клиент предоставляет новое изделие, мастер устанавливает новое изделие вместо существующего.
- Одна точка переноса = одно мини-ТЗ.

Question / Photo Flow:
For each work point:
- Что переносим?
  - Розетка
  - Выключатель

- Фото текущего места:
  - required

- Фото нового места:
  - required

Add More Rule:
- Клиент может добавить одну или несколько точек через кнопку «Добавить ещё».
- Количество точек определяется количеством созданных мини-ТЗ.

Photo Rule:
- Фотографии должны обеспечивать визуальное покрытие текущего и нового расположения всех точек переноса.
- Для каждой точки мастер должен понимать, откуда переносится изделие и куда оно переносится.
- Одно фото может покрывать несколько точек, если соответствие между текущим и новым местом остаётся очевидным.
- Общий лимит фотографий заказа — 10.
- Клиент не обязан фотографировать щит, провода, автоматы или выполнять небезопасные действия.

Equipment Verification Rule:
- Если новые изделия уже есть на объекте, клиент добавляет фото общего вида этих изделий.
- Фото оборудования не заменяет фото текущего и нового места переноса.
- Одно фото может покрывать несколько одинаковых изделий, если мастер видит тип, модель и количество.

Demolished Equipment Rule:
- Демонтированное изделие является собственностью клиента.
- Демонтированное изделие остаётся на объекте по умолчанию.
- Утилизация или вынос возможны только по отдельной договорённости через чат.

Decoration Rule:
- Перенос не включает восстановление декоративной отделки по умолчанию.
- Покраска, штукатурка, плитка, обои и иные отделочные работы не входят в базовую услугу.
- Дополнительные работы по декоративной отделке могут обсуждаться через чат.

Chat Completion Rule:
- Дополнительные работы, материалы, сложность переноса и декоративная отделка могут обсуждаться через чат.
- Эти работы не входят в базовую стоимость по умолчанию.
- Уточнения могут повлиять на Final Agreed Price до выбора мастера.

### Electrical Category → Client Rules
Status: CLOSED ✅

- Клиент отвечает только на вопросы, которые объективно понимает.
- Клиент не обязан обладать специальными знаниями в электрике.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан открывать электрощит.
- Клиент не обязан разбирать изделия.
- Клиент не обязан фотографировать автоматы, проводку и внутренние соединения.
- Если ветка требует новое изделие, новое изделие должно быть на объекте до создания заказа.
- Если новое изделие отсутствует, создание заказа по данной ветке невозможно.
- Фотографии должны обеспечивать визуальное покрытие фронта работ.
- Общий лимит фотографий заказа составляет 10.
- Одно фото может покрывать несколько точек, если они хорошо различимы.
- Фото оборудования не заменяют фотографии фронта работ.
- Дополнительные детали и материалы уточняются через чат.
- Личные вещи клиента перемещает только клиент; мастер не обязан и не должен перемещать, сортировать или убирать личные вещи клиента.

### Electrical Category → Master Rules
Status: CLOSED ✅

Before Work:
- Мастер оценивает достаточность информации.
- При необходимости мастер запрашивает уточнения через чат.
- Мастер предупреждает клиента о несовместимости оборудования или необходимости дополнительных материалов.
- Изменение Final Agreed Price должно быть согласовано до выбора мастера клиентом.
- Мастер не принимает работы, выходящие за рамки MVP или связанные с запрещёнными высокорисковыми операциями.

During Work:
- Работы под напряжением запрещены.
- Перед началом работ мастер обязан отключить электропитание соответствующего участка.

After Work:
- Мастер обязан проверить работоспособность выполненных работ.
- Проверка выполняется без применения специализированного диагностического оборудования, если иное не согласовано отдельно между клиентом и мастером.
- Мастер обязан убедиться в качестве выполненного монтажа.
- Мастер обязан оставить рабочее место в чистом и безопасном состоянии.

Safety Escalation:
- При обнаружении опасного состояния существующей электропроводки, оборудования или условий эксплуатации мастер обязан сообщить об этом клиенту.
- Обнаружение опасности не обязывает мастера выполнять работы вне MVP или вне своей квалификации.
- Мастер вправе отказаться от продолжения работ, если дальнейшее выполнение создаёт угрозу жизни, здоровью или имуществу.

### Electrical Category → Admin Dependencies
Status: CLOSED ✅

Decision:
- Electrical does not introduce new admin modules beyond approved Helpy Admin / Dynamic Form capabilities.
- Electrical inherits the existing category, subcategory, question, photo requirement, pricing, rule visibility and guidance administration model.

Required Admin Capabilities:
- Electrical category enabled/disabled.
- Electrical launch branches enabled/disabled.
- Disabled future branches remain configurable but hidden from launch UI.
- Point-Based Mini Scope Pattern support.
- Question management for install, replace and relocate branches.
- Visual Coverage photo requirement management.
- Equipment Verification photo requirement management.
- Total photo limit enforcement.
- Pricing management for launch branches.
- Rule visibility for client/master guidance.
- Future Global Diagnostics must remain hidden from Electrical launch flow until approved.

Conclusion:
- No unresolved Electrical-specific Admin Dependencies remain.

Future Launch Category:
- Appliance Installation & Connection
- Установка и подключение бытовой техники

Rules:
- Appliance Installation & Connection is designed as the final category before MVP Launch.
- До запуска платформы новые категории не добавляются.
- Масштабирование категорий начинается только после получения реальной статистики.
## 8. Reference Category Standard
Status: CLOSED

Decision Summary:
- Plumbing is the reference category standard for Helpy.
- Every category must reach Plumbing-level detail before it can be considered complete.
- The required minimum architecture sections are fixed in this contract.
- This contract defines the quality gate for all category work.
- No unresolved architecture decisions remain in this contract.

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
## 9. Specialized Reference Categories
Status: CLOSED

Decision Summary:
- Cleaning and Furniture Assembly use specialized business logic.
- Specialized categories are not required to replicate Plumbing structure.
- Specialized categories must not provide a lower level of detail than Plumbing.
- Specialized categories may diverge in form, but never in completeness.
- No unresolved architecture decisions remain in this contract.

Categories:
- Cleaning
- Furniture Assembly

Definition:
- Данные категории используют собственную бизнес-логику.
- Они не обязаны повторять структуру Plumbing.

Rule:
- Уровень детализации не может быть ниже Plumbing.
## Roadmap Decision → Appliance Installation & Connection Architecture

Status: GAP_APPROVED / ROADMAP STORED ✅

Decision Summary:
- Appliance Installation & Connection remains the final unresolved MVP root category before root category closure.
- The category must be designed around the client's real-life scenario, not around technical installation taxonomy.
- MVP launch scope is intentionally narrow and works only with new equipment scenarios.
- Work with used / previously owned household appliances is disabled on launch because of hidden defects, unclear condition, warranty risk and dispute risk.
- Used appliance scenarios are architecturally supported as disabled / future branches.
- Used appliance scenarios may be enabled later through Admin Panel after market demand audit, risk review and operational validation.

MVP Architecture:
Appliance Installation & Connection
├─ Установить новую технику
└─ Заменить существующую технику

MVP Scenario Rules:
- Установить новую технику means the client has new equipment on site and needs installation / connection.
- Заменить существующую технику means the client has new equipment on site and existing equipment must be removed before the new equipment is installed.
- Replacement includes removal / dismantling of existing equipment.
- Separate appliance dismantling is not an MVP launch branch.
- Подключить имеющуюся технику is not an MVP launch branch because it usually means used / previously installed equipment.
- If new equipment was physically placed by another party but still requires connection, the scenario remains Установить новую технику.

MVP Equipment List Rule:
- MVP uses a fixed short equipment list plus Другая бытовая техника.
- The goal is to avoid a large catalogue before launch and collect real demand after launch.
- Current MVP candidates:
  - Стиральная машина.
  - Посудомоечная машина.
  - Измельчитель пищевых отходов / Waste disposer.
  - Другая бытовая техника.

Built-in Classification Rule:
- Built-in remains a technical work-mode classification, not a separate root category.
- The client is asked one simple routing question after selecting the appliance type:
  Техника встроенная?
  - Да
  - Нет
- If the client selects Да, the flow redirects to Kitchen Built-in Appliances.
- If the client selects Нет, the flow continues inside the standard Appliance Installation & Connection scenario.
- The purpose of this question is routing and mistake prevention, not collecting technical specifications.
- The question must not include Не знаю because that option creates weak UX and may make the client feel incompetent.

Kitchen Built-in Appliances Direction:
- Kitchen Built-in Appliances is a Phase 2 branch inside Appliance Installation & Connection, not a separate root category.
- Kitchen Built-in Appliances covers more complex kitchen-related appliance installation scenarios.
- It exists because these scenarios intersect with Kitchen Assembly, niches, furniture, water, drainage, ventilation and electrical readiness.
- Kitchen Built-in Appliances may use mini-scope / add-more architecture similar to Electrical point-based flows when multiple appliances are involved.

Linked Jobs Rule:
- Kitchen Assembly and Kitchen Built-in Appliances must remain separate jobs.
- For the client, they may be presented as one connected kitchen project.
- For the platform, they keep separate deposits, statuses, disputes, reviews and completion logic.
- The system should support a logical Linked Jobs Group between related orders.

Mandatory Guided Transition:
- Kitchen Assembly must be able to guide the client into Kitchen Built-in Appliances.
- Appliance flows must route the client into Kitchen Built-in Appliances through the approved routing question:
  Техника встроенная?
  - Да
  - Нет
- If the client selects Да, the system shows:
  Для встроенной техники используется отдельный сценарий заказа.

  [Продолжить]
- Kitchen Assembly prompt pattern:
  Хотите сразу создать заказ
  на установку встроенной техники?

  [Да, продолжить]
  [Нет, позже]

### Appliance → Установить новую технику → Стиральная машина

Status: APPROVED / STORED ✅

Вопросы:

1. Техника встроенная?
- Да.
- Нет.

Если клиент выбирает «Да», система показывает сообщение:

Для встроенной техники используется отдельный сценарий заказа.

[Продолжить]

и переводит клиента в Kitchen Built-in Appliances.

Обязательные фотографии:
- Фото упаковки со всей информацией на ней;
или
- Карточка приобретённого товара с технической информацией.
- Фото новой техники в упаковке.
- Общий вид места установки.
- Фото зоны подключения.

Правило фотографии зоны подключения:
- Фотография должна позволять оценить место подключения воды и организацию слива.
- Допускается одна фотография, если обе зоны хорошо различимы.

Необязательные фотографии:
- Фото зоны водоснабжения / системы водоотвода.
- Фото электропитания.

Правила для клиента:
- Клиент не обязан извлекать оборудование из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан понимать технические характеристики оборудования.
- Клиент не обязан демонтировать транспортировочные элементы.

Наследуемые правила:
- Packaging Inspection Rules.
- Damage Escalation Rules.
- Chat Evidence Rules.

Правила выполнения работ мастером:

До окончательной установки мастер обязан:
- выполнить визуальный осмотр оборудования;
- убедиться в отсутствии очевидных механических повреждений;
- подключить оборудование к электропитанию;
- убедиться, что панель управления включается и реагирует на команды;
- снять транспортировочные болты, если они предусмотрены производителем;
- извлечь внутренние фиксирующие втулки и иные транспортировочные элементы, удерживающие барабан;
- убедиться, что все транспортировочные элементы полностью удалены.

После подключения мастер обязан:
- выполнить первый запуск оборудования;
- проверить работу машины на короткой программе или минимальном цикле;
- убедиться в корректном наборе воды;
- убедиться в корректной работе слива;
- убедиться в отсутствии протечек;
- убедиться в отсутствии нехарактерных вибраций и посторонних шумов;
- подтвердить корректную работу оборудования.

Правило качества услуги:
- Первый запуск является обязательной частью услуги установки.
- Установка не считается завершённой до подтверждения базовой работоспособности оборудования.
- Неполное удаление транспортировочных элементов считается нарушением правил установки и может привести к повреждению оборудования.
- Если оборудование оснащено системой AquaStop или аналогичным защитным клапаном, мастер обязан соблюдать требования производителя к его положению.

### Appliance → Установить новую технику → Посудомоечная машина

Status: APPROVED / STORED ✅

Вопросы:

1. Техника встроенная?
- Да.
- Нет.

Если клиент выбирает «Да», система показывает сообщение:

Для встроенной техники используется отдельный сценарий заказа.

[Продолжить]

и переводит клиента в Kitchen Built-in Appliances.

Обязательные фотографии:
- Фото упаковки со всей информацией на ней;
или
- Карточка приобретённого товара с технической информацией.
- Фото новой техники в упаковке.
- Общий вид места установки.
- Фото зоны подключения.

Правило фотографии зоны подключения:
- Фотография должна позволять оценить место подключения оборудования.

Необязательные фотографии:
- Фото зоны водоснабжения / системы водоотвода.
- Фото электропитания.

Правила для клиента:
- Клиент не обязан извлекать оборудование из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан понимать технические характеристики оборудования.

Наследуемые правила:
- Packaging Inspection Rules.
- Damage Escalation Rules.
- Chat Evidence Rules.

Правила выполнения работ мастером:

До окончательной установки мастер обязан:
- выполнить визуальный осмотр оборудования;
- убедиться в отсутствии очевидных механических повреждений;
- подключить оборудование к электропитанию;
- убедиться, что панель управления включается и реагирует на команды;
- проверить комплектность оборудования и наличие необходимых элементов подключения.

После подключения мастер обязан:
- выполнить первый запуск оборудования;
- проверить набор воды;
- проверить корректную работу слива;
- убедиться в отсутствии протечек;
- убедиться в отсутствии нехарактерных шумов;
- подтвердить корректную работу оборудования.

Drainage Quality Rule:
- Слив оборудования должен подключаться к системе водоотведения после гидрозатвора (сифона) мойки, раковины или иной сантехнической точки.
- Если существующий вывод расположен до гидрозатвора и его использование может привести к передаче звуков работы оборудования, распространению запахов моющих средств или иным эксплуатационным неудобствам, мастер обязан использовать решение, обеспечивающее подключение после гидрозатвора.

Правило подключения защитного клапана водоснабжения:
- Если оборудование оснащено электрическим клапаном отключения водоснабжения, системой AquaStop либо иным защитным устройством, требующим определённого положения при подключении, мастер обязан установить его в соответствии с требованиями производителя.
- Если производителем предусмотрено вертикальное положение клапана, клапан должен быть подключён в положении вертикально вниз.

Правило качества услуги:
- Первый запуск является обязательной частью услуги установки.
- Установка не считается завершённой до подтверждения базовой работоспособности оборудования.
- Качественной считается установка, обеспечивающая не только работоспособность оборудования, но и комфорт дальнейшей эксплуатации.
- Решения, способные вызвать постоянные шумы или распространение запахов, не должны использоваться при наличии технически корректной альтернативы.
- Использование подключения до гидрозатвора допускается только при отсутствии технически безопасной возможности выполнить подключение после гидрозатвора либо при явном согласовании такого решения с клиентом через чат.
- Подключение защитных систем с нарушением требований производителя считается нарушением правил установки.


### Appliance → Установить новую технику → Измельчитель пищевых отходов

Status: APPROVED / STORED ✅

Вопросы:

1. Мойка уже установлена?
- Да → продолжить оформление заказа.
- Нет → оформление заказа невозможно.

Если клиент выбирает «Нет», система показывает сообщение:

Для установки измельчителя требуется установленная мойка.

[Понятно]

Обязательные фотографии:
- Фото упаковки оборудования со всей информацией на ней. До 4 фотографий.
- Вид мойки сверху. 1 фотография.
- Фото пространства под мойкой с существующей системой водоотведения. 1 фотография.
- Фото точки электропитания. 1 фотография.

Правила для клиента:
- Клиент не обязан извлекать оборудование из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан понимать технические характеристики оборудования.
- Клиент не обязан разбирать сифон, систему водоотведения или элементы мойки.
- Клиент не обязан демонтировать установленное оборудование или сантехнические элементы для выполнения фотографий.

Наследуемые правила:
- Packaging Inspection Rules.
- Damage Escalation Rules.
- Chat Evidence Rules.
- Global Materials Separation Rule.
- Global Electrical Readiness Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.

Правила выполнения работ мастером:

До начала монтажа мастер обязан:
- выполнить визуальный осмотр оборудования;
- убедиться в отсутствии очевидных механических повреждений;
- проверить комплектность оборудования и наличие штатных элементов установки;
- убедиться в наличии технической возможности установки без изменения конструкции мойки;
- убедиться, что диаметр сливного отверстия мойки соответствует требованиям производителя оборудования;
- проверить наличие электропитания в розетке, предназначенной для подключения оборудования.

Предварительная проверка оборудования:
- До начала монтажа мастер вправе выполнить краткую проверку реакции оборудования на включение и выключение без окончательной установки, если такая проверка допускается производителем и может быть выполнена безопасным способом.
- Для измельчителя пищевых отходов мастер может временно подключить предусмотренный производителем элемент управления, например пневмокнопку, и выполнить кратковременное включение и выключение оборудования.
- Такая проверка не является диагностикой оборудования, не подтверждает отсутствие скрытых неисправностей и не заменяет обязательную проверку работоспособности после завершения установки.

Правило комплектности и дополнительных материалов:
- В стоимость услуги установки входят работы по использованию штатных элементов, предусмотренных производителем и входящих в комплект оборудования.
- Переделка системы водоотведения при невозможности подключения оборудования к существующему узлу может потребовать дополнительных материалов и комплектующих. В таком случае применяется Global Materials Separation Rule.

Правило системы водоотведения:
- При установке и замене измельчителя пищевых отходов в системе водоотведения не должны использоваться гофрированные элементы.
- Гофрированные элементы способствуют накоплению пищевых отходов, образованию запахов и увеличению риска засоров.
- При невозможности подключения без изменения существующей системы применяется правило дополнительных материалов и комплектующих.

После подключения мастер обязан:
- выполнить первый запуск оборудования;
- убедиться, что оборудование включается и выключается;
- проверить отсутствие протечек;
- убедиться в отсутствии нехарактерных шумов и вибраций;
- проверить корректный отвод воды через установленную систему;
- подтвердить корректную работу оборудования в рамках выполненной установки;
- направить клиенту через чат платформы фотографии результата выполненных работ.

Client Handover Rule:
- При общении с клиентом мастер может рекомендовать ознакомиться с инструкцией производителя и при необходимости кратко обратить внимание на особенности эксплуатации оборудования.
- Краткое информирование клиента не является обучением эксплуатации оборудования и не заменяет инструкцию производителя.


### Appliance → Заменить существующую технику → Стиральная машина

Status: APPROVED / STORED ✅

Вопросы:

1. Стиральная машина установлена?
- Да.
- Нет.

Если клиент выбирает «Нет», система показывает сообщение:

Для замены требуется наличие установленного оборудования.

Будет использован сценарий установки новой техники.

[Продолжить]

и переводит клиента в Appliance → Установить новую технику → Стиральная машина.

2. Техника встроенная?
- Да.
- Нет.

Если клиент выбирает «Да», система показывает сообщение:

Для встроенной техники используется отдельный сценарий заказа.

[Продолжить]

и переводит клиента в Kitchen Built-in Appliances.

Обязательные фотографии:
- Фото упаковки со всей информацией на ней;
или
- Карточка приобретённого товара с технической информацией.
- Фото новой техники в упаковке.
- Общий вид установленной стиральной машины.
- Фото зоны подключения существующей стиральной машины.

Правило фотографии зоны подключения:
- Фотография должна позволять оценить подключение воды, организацию слива и подключение к электропитанию.
- Допускается одна фотография, если все элементы хорошо различимы.

Правила для клиента:
- Клиент не обязан извлекать новую стиральную машину из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан понимать технические характеристики оборудования.
- Клиент не обязан самостоятельно отключать существующую стиральную машину.
- Клиент не обязан самостоятельно отсоединять водоснабжение, слив или электропитание существующей стиральной машины.
- Клиент не обязан демонтировать транспортировочные элементы новой стиральной машины.
- Клиент обязан обеспечить доступ к существующей стиральной машине и отсутствие внутри неё личных вещей.

Наследуемые правила:
- Packaging Inspection Rules.
- Damage Escalation Rules.
- Chat Evidence Rules.
- Global Materials Separation Rule.
- Global Electrical Readiness Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.

Правила выполнения работ мастером:

1. Проверка новой техники до демонтажа старой:
- Если работа предполагает замену оборудования, мастер обязан проверить новое оборудование до демонтажа существующего.
- Проверка включает совместимость, комплектность, целостность и возможность установки.

2. Демонтаж существующей стиральной машины:
- Мастер выполняет отключение существующей стиральной машины от электропитания, водоснабжения и системы водоотведения в пределах объёма услуги замены.
- Демонтированное оборудование остаётся собственностью клиента и оставляется на объекте.

3. Удаление транспортировочных элементов новой стиральной машины:
- Мастер обязан удалить транспортировочные элементы, предусмотренные производителем оборудования.
- Неполное удаление транспортировочных элементов считается нарушением правил установки и может привести к повреждению оборудования.

4. Подключение новой стиральной машины:
- Мастер выполняет подключение новой стиральной машины в соответствии с требованиями производителя.
- Если оборудование оснащено системой AquaStop или аналогичным защитным клапаном, мастер обязан соблюдать требования производителя к положению клапана.

5. Первый запуск и проверка работоспособности:
- После подключения мастер обязан выполнить первый запуск оборудования.
- Мастер обязан убедиться в корректном наборе воды, корректной работе слива, отсутствии протечек, нехарактерных вибраций и посторонних шумов.
- Первый запуск является обязательной частью услуги замены.
- Услуга не считается качественно выполненной до подтверждения базовой работоспособности результата работ в рамках согласованного объёма заказа.

6. Сдача выполненных работ клиенту:
- После выполнения работ мастер обязан направить клиенту через чат платформы подтверждение результата и фотографии выполненных работ.
- Заказ считается завершённым только после подтверждения клиента посредством функционала платформы.
- Отсутствие клиента на объекте не препятствует выполнению работ.


### Appliance → Заменить существующую технику → Посудомоечная машина

Status: APPROVED / STORED ✅

Вопросы:

1. Посудомоечная машина установлена?
- Да.
- Нет.

Если клиент выбирает «Нет», система показывает сообщение:

Для замены требуется наличие установленного оборудования.

Будет использован сценарий установки новой техники.

[Продолжить]

и переводит клиента в Appliance → Установить новую технику → Посудомоечная машина.

2. Техника встроенная?
- Да.
- Нет.

Если клиент выбирает «Да», система показывает сообщение:

Для встроенной техники используется отдельный сценарий заказа.

[Продолжить]

и переводит клиента в Kitchen Built-in Appliances.

Обязательные фотографии:
- Фото упаковки со всей информацией на ней;
или
- Карточка приобретённого товара с технической информацией.
- Фото новой техники в упаковке.
- Общий вид установленной посудомоечной машины.
- Фото зоны подключения существующей посудомоечной машины.

Правило фотографии зоны подключения:
- Фотография должна позволять оценить подключение воды, организацию слива и подключение к электропитанию.
- Допускается одна фотография, если все элементы хорошо различимы.

Правила для клиента:
- Клиент не обязан извлекать новую посудомоечную машину из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан понимать технические характеристики оборудования.
- Клиент не обязан самостоятельно отключать существующую посудомоечную машину.
- Клиент не обязан самостоятельно отсоединять водоснабжение, слив или электропитание существующей посудомоечной машины.
- Клиент обязан обеспечить доступ к существующей посудомоечной машине и отсутствие внутри неё личных вещей.

Наследуемые правила:
- Packaging Inspection Rules.
- Damage Escalation Rules.
- Chat Evidence Rules.
- Global Materials Separation Rule.
- Global Electrical Readiness Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.

Правила выполнения работ мастером:

1. Проверка новой техники до демонтажа старой:
- Если работа предполагает замену оборудования, мастер обязан проверить новое оборудование до демонтажа существующего.
- Проверка включает совместимость, комплектность, целостность и возможность установки.

2. Демонтаж существующей посудомоечной машины:
- Мастер выполняет отключение существующей посудомоечной машины от электропитания, водоснабжения и системы водоотведения в пределах объёма услуги замены.
- Демонтированное оборудование остаётся собственностью клиента и оставляется на объекте.

3. Подключение новой посудомоечной машины:
- Мастер выполняет подключение новой посудомоечной машины в соответствии с требованиями производителя.
- Если оборудование оснащено электрическим клапаном отключения водоснабжения, системой AquaStop либо иным защитным устройством, требующим определённого положения при подключении, мастер обязан установить его в соответствии с требованиями производителя.
- Если производителем предусмотрено вертикальное положение клапана, клапан должен быть подключён в положении вертикально вниз.

Drainage Quality Rule:
- Слив оборудования должен подключаться к системе водоотведения после гидрозатвора.
- Если существующий вывод расположен до гидрозатвора и его использование может привести к шумам, запахам или иным эксплуатационным неудобствам, мастер обязан использовать решение, обеспечивающее подключение после гидрозатвора.

4. Первый запуск и проверка работоспособности:
- После подключения мастер обязан выполнить первый запуск оборудования.
- Проверить набор воды.
- Проверить корректную работу слива.
- Убедиться в отсутствии протечек.
- Убедиться в отсутствии нехарактерных шумов.
- Подтвердить корректную работу оборудования.
- Первый запуск является обязательной частью услуги замены.

5. Правило качества услуги:
- Услуга не считается качественно выполненной до подтверждения базовой работоспособности результата работ в рамках согласованного объёма заказа.
- Качественной считается установка, обеспечивающая не только работоспособность оборудования, но и комфорт дальнейшей эксплуатации.
- Решения, способные вызвать постоянные шумы или распространение запахов, не должны использоваться при наличии технически корректной альтернативы.
- Подключение защитных систем с нарушением требований производителя считается нарушением правил установки.

6. Сдача выполненных работ клиенту:
- После выполнения работ мастер обязан направить клиенту через чат платформы подтверждение результата и фотографии выполненных работ.
- Заказ считается завершённым только после подтверждения клиента посредством функционала платформы.
- Отсутствие клиента на объекте не препятствует выполнению работ.


### Appliance → Заменить существующую технику → Измельчитель пищевых отходов

Status: APPROVED / STORED ✅

Вопросы:

1. Измельчитель установлен?
- Да.
- Нет.

Если клиент выбирает «Нет», система показывает сообщение:

Для замены требуется наличие установленного оборудования.

Будет использован сценарий установки новой техники.

[Продолжить]

и переводит клиента в Appliance → Установить новую технику → Измельчитель пищевых отходов.

Обязательные фотографии:
- Фото упаковки оборудования со всей информацией на ней. До 4 фотографий.
- Фото пространства под мойкой с установленным измельчителем и существующей системой водоотведения. До 2 фотографий.

Правила для клиента:
- Клиент не обязан извлекать оборудование из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан понимать технические характеристики оборудования.
- Клиент не обязан разбирать сифон, систему водоотведения или элементы мойки.
- Клиент обязан обеспечить свободный доступ к пространству под мойкой.

Наследуемые правила:
- Packaging Inspection Rules.
- Damage Escalation Rules.
- Chat Evidence Rules.
- Global Materials Separation Rule.
- Global Electrical Readiness Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.

Правила выполнения работ мастером:

1. Проверка нового оборудования до демонтажа установленного:
- Если работа предполагает замену оборудования, мастер обязан проверить новое оборудование до демонтажа существующего.
- Проверка включает совместимость, комплектность, целостность и возможность установки.
- До демонтажа установленного измельчителя мастер вправе выполнить краткую проверку реакции оборудования на включение и выключение, если такая проверка допускается производителем и может быть выполнена безопасным способом.
- Для измельчителя пищевых отходов мастер может временно подключить предусмотренный производителем элемент управления, например пневмокнопку, и выполнить кратковременное включение и выключение оборудования.
- Такая проверка не является диагностикой оборудования, не подтверждает отсутствие скрытых неисправностей и не заменяет обязательную проверку работоспособности после завершения замены.

2. Демонтаж установленного измельчителя:
- Мастер выполняет отключение и демонтаж установленного измельчителя в пределах объёма услуги замены.
- Демонтированное оборудование остаётся собственностью клиента и оставляется на объекте.

3. Установка нового измельчителя:
- Мастер выполняет установку нового измельчителя в соответствии с требованиями производителя.

Правило комплектности и дополнительных материалов:
- В стоимость услуги замены входят работы по использованию штатных элементов, предусмотренных производителем и входящих в комплект оборудования.
- Переделка системы водоотведения при невозможности подключения нового оборудования к существующему узлу может потребовать дополнительных материалов и комплектующих. В таком случае применяется Global Materials Separation Rule.

Правило системы водоотведения:
- При установке и замене измельчителя пищевых отходов в системе водоотведения не должны использоваться гофрированные элементы.
- Гофрированные элементы способствуют накоплению пищевых отходов, образованию запахов и увеличению риска засоров.
- При невозможности подключения без изменения существующей системы применяется правило дополнительных материалов и комплектующих.

4. Первый запуск и проверка работоспособности:
- После подключения мастер обязан выполнить первый запуск оборудования.
- Убедиться, что оборудование включается и выключается.
- Проверить отсутствие протечек.
- Убедиться в отсутствии нехарактерных шумов и вибраций.
- Проверить корректный отвод воды через установленную систему.
- Подтвердить корректную работу оборудования в рамках выполненной замены.

5. Правило качества услуги:
- Услуга не считается качественно выполненной до подтверждения базовой работоспособности результата работ в рамках согласованного объёма заказа.

6. Сдача выполненных работ клиенту:
- После выполнения работ мастер обязан направить клиенту через чат платформы подтверждение результата и фотографии выполненных работ.
- Заказ считается завершённым только после подтверждения клиента посредством функционала платформы.
- Отсутствие клиента на объекте не препятствует выполнению работ.


Future / Disabled / Admin-Configurable:
- Подключить имеющуюся технику.
- Used / previously owned appliance connection.
- Appliance diagnostics.
- Appliance repair / malfunction scenarios.
- These scenarios are not enabled on launch.
- Данные ограничения относятся ко всей категории Appliance независимо от типа оборудования и способа установки.
- These scenarios must remain architecturally supported as disabled branches.
- Future Admin Panel must manage these scenarios through enable/disable feature toggles without requiring architectural changes.
- Включение таких сценариев допускается только после отдельного market audit, risk review, dispute rule review и operational validation.

Границы сценария Kitchen Built-in:
- Экран выбора оборудования Kitchen Built-in использует прокручиваемый список выбора, оптимизированный под Android.
- Газовые варочные панели, газовые духовые шкафы, подключение газа и работы с LPG-баллонами исключены из MVP из-за операционных рисков Таиланда и не поддерживаются архитектурой запуска Helpy.
- Кухонный кран / смеситель отображается клиенту как один пункт списка выбора для снижения когнитивной нагрузки; технические различия обрабатываются внутри mini-ТЗ, по фотографиям и через чат при необходимости.
- Проточный водонагреватель остаётся самостоятельным кухонным сценарием и не объединяется с логикой кухонного крана / смесителя, поскольку использует собственную схему подключения и может включать элементы производителя.


Детализация MVP Kitchen Built-in:
- Kitchen Built-in использует паттерн mini-ТЗ.
- Один заказ может содержать несколько mini-ТЗ.
- Каждое mini-ТЗ содержит собственный тип работ:
  - Установить и подключить;
  - Заменить.
- Если выбрана замена, но оборудование отсутствует, тип работ меняется на установку внутри того же mini-ТЗ без перехода между ветками.
- Клиент сначала выбирает всё необходимое оборудование из прокручиваемого списка выбора, после чего последовательно заполняет каждое mini-ТЗ.
- Утверждённый MVP-список оборудования Kitchen Built-in:
  - Варочная панель;
  - Духовой шкаф;
  - Вытяжка;
  - Встроенный холодильник;
  - Стиральная машина;
  - Посудомоечная машина;
  - Кухонная мойка;
  - Кухонный кран / смеситель;
  - Проточный водонагреватель;
  - Другая встроенная техника.
- Другая встроенная техника остаётся единственным свободным полем ввода и используется как сигнал будущего спроса.
- Уже утверждённые сценарии выполнения работ должны переиспользоваться везде, где это возможно.
- Kitchen Built-in в первую очередь объединяет уже утверждённые контракты и не формирует полностью новую самостоятельную категорию.


### Kitchen Built-in Appliances → Кухонная мойка

Status: APPROVED / STORED ✅

Назначение:
- Этот mini-ТЗ описывает установку и замену кухонной мойки внутри Kitchen Built-in Appliances.
- Пользовательское название должно быть «Кухонная мойка», чтобы не смешивать её с раковинами ванной комнаты и улучшить локализацию RU/EN/TH.
- Установка включает монтаж, подключение и базовую проверку результата.
- Замена включает демонтаж, монтаж, подключение и базовую проверку результата.
- Отдельное подключение кухонной мойки не является MVP-сценарием.

Вопросы:

1. Что требуется сделать?
- Установить и подключить.
- Заменить.

Если выбрано «Установить и подключить»:

2. Есть ли отверстие в столешнице?
- Да.
- Нет.

3. Описание материала столешницы и особенностей.
- Необязательное поле.

Если выбрано «Заменить»:

2. Описание материала столешницы и особенностей.
- Необязательное поле.

Правила вопросов:
- Тип кухонной мойки не спрашивается.
- Тип монтажа не спрашивается.
- Количество чаш не спрашивается.
- Тип сифона / выпуска не спрашивается.
- Требуется ли изменение существующего отверстия — не спрашивается.
- Эти детали оцениваются по фотографиям и при необходимости уточняются через чат.
- Дополнительные материалы и расходники регулируются Global Materials Separation Rule.

Обязательные фотографии — Установить и подключить:
- Фото кухонной мойки в упаковке. 1 фотография.
- Фото упаковки со всей информацией на ней. До 4 фотографий.
- Фото места установки сверху. 1 фотография.
- Фото спереди с открытыми дверцами под местом установки, чтобы было видно столешницу и ширину шкафа. 1 фотография.

Обязательные фотографии — Заменить:
- Фото кухонной мойки в упаковке. 1 фотография.
- Фото упаковки со всей информацией на ней. До 4 фотографий.
- Фото сверху. 1 фотография.
- Фото спереди с открытыми дверцами под местом установки, чтобы было видно столешницу и ширину шкафа. 1 фотография.

Правила для клиента:
- Клиент не обязан определять тип кухонной мойки.
- Клиент не обязан демонтировать установленную кухонную мойку.
- Клиент не обязан отключать водоснабжение или водоотведение.
- Клиент не обязан извлекать новую кухонную мойку из упаковки.
- Клиент обязан обеспечить доступ к месту выполнения работ.

Правила выполнения работ мастером:

1. Предварительная проверка столешницы:
- Перед началом работ мастер обязан визуально осмотреть столешницу и прилегающие поверхности.
- Проверка включает видимые сколы, царапины, трещины, следы предыдущего ремонта, расслоения и иные видимые дефекты.
- При обнаружении дефектов мастер обязан зафиксировать их на фотографиях и направить клиенту через чат платформы до продолжения работ.
- Если клиент подтверждает продолжение работ, подтверждение клиента и фотографии становятся частью доказательной базы заказа.
- Мастер вправе отказаться от продолжения работ, если состояние столешницы создаёт неприемлемый риск повреждения или безопасное выполнение работ невозможно.

2. Отверстие в столешнице:
- Изготовление нового отверстия в столешнице под кухонную мойку допускается в рамках этого сценария.
- Если изготовление отверстия, доработка места установки, дополнительные инструменты, расходники или материалы влияют на стоимость заказа, это должно быть согласовано через чат до утверждения финальной цены мастером.
- Если требуются дополнительные инструменты, расходники или материалы, применяется Global Materials Separation Rule.

3. Установка и замена:
- Мастер устанавливает и подключает кухонную мойку в пределах согласованного объёма услуги.
- При замене демонтированное оборудование остаётся собственностью клиента и оставляется на объекте.
- Упаковка новой кухонной мойки остаётся собственностью клиента.
- Вынос или утилизация демонтированного оборудования и упаковки не входят в базовую стоимость услуги и могут быть согласованы отдельно через чат.

4. Проверка подачи воды:
- После завершения работ мастер обязан проверить соединения подачи воды на отсутствие видимых протечек.
- Мастер обязан проверить подачу холодной воды.
- Мастер обязан проверить подачу горячей воды, если она предусмотрена системой.
- Если в заказ включён кухонный кран / смеситель, мастер обязан проверить корректность его работы.
- Если в заказ включён проточный водонагреватель, мастер обязан проверить включение, нагрев воды, работу органов управления и отсутствие видимых протечек.

5. Проверка слива гидроударом:
- После полного подключения мастер обязан наполнить чашу кухонной мойки водой до уровня, достаточного для проверки выпускной системы.
- Во время наполнения мастер проверяет отсутствие видимых протечек в соединениях подачи воды, переливе и выпускной системе.
- После наполнения мастер резко открывает сливное отверстие, чтобы вода прошла через систему под нагрузкой.
- Мастер обязан подтвердить отсутствие протечек при максимальной бытовой нагрузке на слив.
- Если установлен измельчитель пищевых отходов, мастер обязан включить измельчитель во время слива воды.
- Услуга не считается качественно выполненной до успешного прохождения этой проверки.

6. Сдача выполненных работ клиенту:
- После выполнения работ мастер обязан направить клиенту через чат платформы подтверждение результата и фотографии выполненных работ.
- Заказ считается завершённым только после подтверждения клиента посредством функционала платформы.
- Отсутствие клиента на объекте не препятствует выполнению работ.

Наследуемые правила:
- Global Materials Separation Rule.
- Global Electrical Readiness Rule, если в заказ включено электрическое оборудование.
- Global Completion Evidence Rule.
- Global Service Quality Rule.
- Chat Evidence Rules.


### Kitchen Built-in Appliances → Варочная панель

Status: APPROVED / STORED ✅

Назначение:
- Этот mini-ТЗ описывает установку, подключение и замену варочной панели внутри Kitchen Built-in Appliances.
- В MVP поддерживаются только электрические и индукционные варочные панели.
- Газовые варочные панели, подключение газа и работы с LPG-баллонами исключены из MVP и не поддерживаются архитектурой запуска Helpy.
- Установка включает монтаж, подключение и базовую проверку результата.
- Замена включает демонтаж, монтаж, подключение и базовую проверку результата.

Вопросы:

1. Что требуется сделать?
- Установить и подключить.
- Заменить.

Если выбрано «Установить и подключить»:

2. Есть ли отверстие в столешнице?
- Да.
- Нет.

3. Описание материала столешницы и особенностей.
- Необязательное поле.

Если выбрано «Заменить»:

Дополнительных вопросов нет.

Правила вопросов:
- Тип варочной панели не спрашивается.
- Мощность варочной панели не спрашивается.
- Количество конфорок не спрашивается.
- Тип подключения не спрашивается.
- Наличие заземления не спрашивается.
- Тип электрической точки не спрашивается.
- Эти детали оцениваются по фотографиям и при необходимости уточняются через чат.
- Дополнительные материалы и расходники регулируются Global Materials Separation Rule.

Обязательные фотографии — Установить и подключить:
- Фото варочной панели в упаковке. 1 фотография.
- Фото упаковки со всей информацией на ней или карточка приобретённого товара с технической информацией. До 4 фотографий: 1 обязательная и до 3 дополнительных.
- Фото места установки сверху. 1 фотография.
- Фото спереди с открытыми дверцами под местом установки, чтобы было видно столешницу и ширину шкафа. 1 фотография.
- Фото электрической точки. До 2 фотографий: 1 обязательная и до 1 дополнительной.

Лимит фотографий — Установить и подключить:
- Обязательные: 5 фотографий.
- Дополнительные: до 4 фотографий.
- Всего: до 9 из 10 фотографий.

Обязательные фотографии — Заменить:
- Фото варочной панели в упаковке. 1 фотография.
- Фото упаковки со всей информацией на ней или карточка приобретённого товара с технической информацией. До 4 фотографий: 1 обязательная и до 3 дополнительных.
- Фото установленной варочной панели. 1 фотография.

Лимит фотографий — Заменить:
- Обязательные: 3 фотографии.
- Дополнительные: до 3 фотографий.
- Всего: до 6 из 10 фотографий.

Правила для клиента:
- Клиент не обязан определять тип варочной панели.
- Клиент не обязан понимать технические характеристики оборудования.
- Клиент не обязан извлекать варочную панель из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан самостоятельно выполнять подготовку электрической точки подключения.
- Клиент не обязан самостоятельно изменять существующее отверстие в столешнице.
- Клиент не обязан самостоятельно изготавливать новое отверстие в столешнице.
- Клиент не обязан самостоятельно отключать варочную панель.
- Клиент не обязан самостоятельно демонтировать варочную панель.
- Клиент не обязан приобретать дополнительные материалы и комплектующие до осмотра мастером.
- Клиент обязан обеспечить доступ к месту выполнения работ.
- Клиент обязан обеспечить доступ к электрической точке подключения.
- Клиент обязан обеспечить доступ к варочной панели.
- Клиент обязан обеспечить возможность безопасного выполнения работ.

Правила выполнения работ мастером:

1. Проверка варочной панели до установки:
- До начала работ мастер обязан выполнить визуальный осмотр варочной панели.
- Проверка включает наличие видимых механических повреждений.
- При обнаружении повреждений мастер обязан зафиксировать их на фотографиях и направить клиенту через чат платформы до продолжения работ.
- Если клиент подтверждает продолжение работ, подтверждение клиента и фотографии становятся частью доказательной базы заказа.
- Мастер вправе отказаться от продолжения работ, если безопасное выполнение работ невозможно.

2. Проверка столешницы:
- Перед началом работ мастер обязан визуально осмотреть столешницу.
- Проверка включает видимые сколы, царапины, трещины, следы предыдущего ремонта, расслоения и иные видимые дефекты.
- При обнаружении дефектов мастер обязан зафиксировать их на фотографиях и направить клиенту через чат платформы до продолжения работ.
- Если клиент подтверждает продолжение работ, подтверждение клиента и фотографии становятся частью доказательной базы заказа.
- Мастер вправе отказаться от продолжения работ, если безопасное выполнение работ невозможно.

3. Отверстие в столешнице:
- Изготовление нового отверстия в столешнице под варочную панель допускается в рамках сценария установки.
- Изменение существующего отверстия допускается в рамках сценария установки.
- Если изготовление отверстия, доработка места установки, дополнительные инструменты, расходники или материалы влияют на стоимость заказа, это должно быть согласовано через чат до утверждения финальной цены мастером.
- Если требуются дополнительные инструменты, расходники или материалы, применяется Global Materials Separation Rule.

4. Демонтаж варочной панели:
- В сценарии замены мастер выполняет отключение варочной панели от электропитания и извлекает её из отверстия в пределах объёма услуги замены.
- Демонтированное оборудование остаётся собственностью клиента и оставляется на объекте.

5. Установка и подключение:
- Мастер устанавливает и подключает варочную панель в пределах согласованного объёма услуги.
- Упаковка варочной панели остаётся собственностью клиента.
- Вынос или утилизация демонтированного оборудования и упаковки не входят в базовую стоимость услуги и могут быть согласованы отдельно через чат.

6. Проверка электропитания:
- В сценарии установки до начала подключения мастер обязан проверить наличие электропитания в точке подключения.
- Поиск неисправностей существующей электропроводки не входит в объём услуги установки.

7. Первый запуск и проверка работоспособности:
- После подключения мастер обязан выполнить первый запуск оборудования.
- Мастер обязан убедиться, что панель управления включается и реагирует на команды.
- Мастер обязан проверить базовую работоспособность всех доступных режимов нагрева.
- Услуга не считается качественно выполненной до подтверждения базовой работоспособности результата работ в рамках согласованного объёма заказа.

8. Сдача выполненных работ клиенту:
- После выполнения работ мастер обязан направить клиенту через чат платформы подтверждение результата и фотографии выполненных работ.
- Заказ считается завершённым только после подтверждения клиента посредством функционала платформы.
- Отсутствие клиента на объекте не препятствует выполнению работ.

Наследуемые правила — Установить и подключить:
- Global Materials Separation Rule.
- Global Electrical Readiness Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.
- Chat Evidence Rules.

Наследуемые правила — Заменить:
- Global Materials Separation Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.
- Chat Evidence Rules.


### Kitchen Built-in Appliances → Духовой шкаф

Status: APPROVED / STORED ✅

Назначение:
- Этот mini-ТЗ описывает установку, подключение и замену встроенного духового шкафа внутри Kitchen Built-in Appliances.
- В MVP поддерживаются только электрические духовые шкафы.
- Газовые духовые шкафы, подключение газа и работы с LPG-баллонами исключены из MVP и не поддерживаются архитектурой запуска Helpy.
- Установка включает монтаж, подключение и базовую проверку результата.
- Замена включает демонтаж, монтаж, подключение и базовую проверку результата.

Вопросы:

1. Что требуется сделать?
- Установить и подключить.
- Заменить.

Если выбрано «Установить и подключить»:

2. Размер ниши для установки (Ш × В × Г).
- Обязательное поле.

Если выбрано «Заменить»:

Дополнительных вопросов нет.

Правила вопросов:
- Тип духового шкафа не спрашивается.
- Мощность духового шкафа не спрашивается.
- Тип подключения не спрашивается.
- Наличие вилки или провода не спрашивается.
- Наличие заземления не спрашивается.
- Тип электрической точки не спрашивается.
- Размер ниши является характеристикой места установки, а не технической характеристикой оборудования.
- Эти детали оцениваются по фотографиям и при необходимости уточняются через чат.
- Дополнительные материалы, комплектующие и расходники регулируются Global Materials Separation Rule.

Обязательные фотографии — Установить и подключить:
- Фото духового шкафа в упаковке. 1 фотография.
- Фото упаковки со всей информацией на ней или карточка приобретённого товара с технической информацией. До 4 фотографий: 1 обязательная и до 3 дополнительных.
- Фото места установки спереди. 1 фотография.
- Фото электрической точки подключения. До 2 фотографий: 1 обязательная и до 1 дополнительной.

Лимит фотографий — Установить и подключить:
- Обязательные: 4 фотографии.
- Дополнительные: до 4 фотографий.
- Всего: до 8 из 10 фотографий.

Обязательные фотографии — Заменить:
- Фото нового духового шкафа в упаковке. 1 фотография.
- Фото упаковки со всей информацией на ней или карточка приобретённого товара с технической информацией. До 4 фотографий: 1 обязательная и до 3 дополнительных.
- Фото установленного духового шкафа. 1 фотография.
- Фото серии и номера модели установленного духового шкафа. До 2 дополнительных фотографий.

Лимит фотографий — Заменить:
- Обязательные: 3 фотографии.
- Дополнительные: до 5 фотографий.
- Всего: до 8 из 10 фотографий.

Правила для клиента:
- Клиент не обязан понимать технические характеристики духового шкафа.
- Клиент не обязан извлекать духовой шкаф из упаковки.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан самостоятельно выполнять подготовку электрической точки подключения.
- Клиент не обязан самостоятельно отключать установленный духовой шкаф.
- Клиент не обязан самостоятельно демонтировать установленный духовой шкаф.
- Клиент не обязан приобретать дополнительные материалы и комплектующие до осмотра мастером.
- Клиент обязан обеспечить доступ к месту выполнения работ.
- Клиент обязан обеспечить доступ к духовому шкафу.
- Клиент обязан обеспечить доступ к электрической точке подключения.
- Клиент обязан обеспечить возможность безопасного выполнения работ.

Правила выполнения работ мастером:

1. Проверка духового шкафа до установки:
- До начала работ мастер обязан выполнить визуальный осмотр духового шкафа.
- Проверка включает наличие видимых механических повреждений.
- При обнаружении повреждений мастер обязан зафиксировать их на фотографиях и направить клиенту через чат платформы до продолжения работ.
- Если клиент подтверждает продолжение работ, подтверждение клиента и фотографии становятся частью доказательной базы заказа.
- Мастер вправе отказаться от продолжения работ, если безопасное выполнение работ невозможно.

2. Демонтаж духового шкафа:
- В сценарии замены мастер выполняет отключение духового шкафа от электропитания, убирает крепёжные элементы и извлекает его из ниши в пределах объёма услуги замены.
- Демонтированное оборудование остаётся собственностью клиента и оставляется на объекте.

3. Установка и подключение:
- Мастер устанавливает и подключает духовой шкаф в пределах согласованного объёма услуги.
- Упаковка духового шкафа остаётся собственностью клиента.
- Вынос или утилизация демонтированного оборудования и упаковки не входят в базовую стоимость услуги и могут быть согласованы отдельно.

4. Проверка электропитания:
- В сценарии установки до начала подключения мастер обязан проверить наличие электропитания в точке подключения.
- Поиск неисправностей электропроводки не входит в объём услуги установки.

5. Первый запуск и проверка работоспособности:
- После подключения мастер обязан выполнить первый запуск оборудования.
- Мастер обязан убедиться, что органы управления реагируют на команды.
- Мастер обязан проверить включение режима нагрева.
- Мастер обязан убедиться в базовой работоспособности духового шкафа в рамках согласованного объёма заказа.
- Услуга не считается качественно выполненной до подтверждения базовой работоспособности результата работ.

6. Сдача выполненных работ клиенту:
- После выполнения работ мастер обязан направить клиенту через чат платформы подтверждение результата и фотографии выполненных работ.
- Заказ считается завершённым только после подтверждения клиента посредством функционала платформы.
- Отсутствие клиента на объекте не препятствует выполнению работ.

Наследуемые правила — Установить и подключить:
- Global Materials Separation Rule.
- Global Electrical Readiness Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.
- Chat Evidence Rules.

Наследуемые правила — Заменить:
- Global Materials Separation Rule.
- Global Completion Evidence Rule.
- Global Service Quality Rule.
- Chat Evidence Rules.


Closure Note:
- This roadmap decision stores the approved Appliance architecture direction.
- Final closure still requires detailed question flows, photo requirements, client rules, master rules, business rules, service playbook, pricing and admin dependencies.

---

## Pre-Build Decision Gate → Entry Price Architecture

Status: STORED ⚠️ REQUIRED BEFORE DB / MVP / ADMIN PRICING DESIGN

Decision Summary:
- Источник первой цены заказа намеренно не закрыт до начала проектирования БД, MVP и Admin.
- Текущие рабочие варианты:
  1. Platform Entry Price — платформа задаёт входную стоимость.
  2. Client Expected Price — клиент указывает ожидаемую стоимость работ.
- Для Client Expected Price допускается минимальный порог входа по категории / подкатегории.
- Минимальный порог входа не является рыночной ценой услуги и не является рекомендацией стоимости.
- Минимальный порог нужен только для защиты платформы от заведомо нереалистичных заявок.
- Мастер после общения с клиентом через чат может один раз изменить стоимость работ с обоснованием.
- После согласования клиентом и выбора мастера формируется Final Agreed Price.
- Депозит и комиссия платформы рассчитываются только от Final Agreed Price.

Build Gate:
- Перед созданием pricing-related DB structures это решение должно быть явно пересмотрено и закрыто.
- Перед проектированием Admin pricing settings это решение должно быть явно пересмотрено и закрыто.
- Перед реализацией pricing flow в MVP это решение должно быть явно пересмотрено и закрыто.
- Нельзя начинать реализацию pricing logic с неявным предположением, что Entry Price задаёт платформа.

Boundary:
- Existing Final Agreed Price contracts remain valid.
- Existing One-Time Final Price Rule remains valid.
- Existing Commission Rule remains valid.
- Existing Global Materials Separation Rule remains valid.
- This block does not change current category mini-ТЗ work.

Status Effect:
- BLOCKS PRICING IMPLEMENTATION.
- MUST RESURFACE BEFORE DB / MVP / ADMIN PRICING DESIGN.





## Global Surface Protection Rule

Status: STORED ⚠️ ТРЕБУЕТ ПОВТОРНОГО РАССМОТРЕНИЯ ПЕРЕД РЕАЛИЗАЦИЕЙ MVP

Краткое описание:
- При выполнении работ мастер обязан принимать разумные меры по защите имущества клиента от случайного повреждения.
- Правило применяется независимо от категории услуги.
- Наиболее актуально при работах над столешницами, мебелью, бытовой техникой и другими поверхностями в зоне выполнения работ.

Правило:
- Перед началом работ мастер обязан защитить поверхности, которые могут быть повреждены в процессе выполнения работ, если такая защита является разумно необходимой.
- Инструменты и материалы должны размещаться таким образом, чтобы минимизировать риск случайного повреждения имущества клиента.
- При необходимости использования поверхности в качестве временной рабочей опоры мастер обязан предварительно защитить её поверхность.
- Если безопасное выполнение работ невозможно без создания необоснованного риска повреждения имущества клиента, мастер вправе отказаться от продолжения работ до устранения препятствий.

Границы применения:
- Правило не требует использования специальных защитных материалов, отсутствующих у мастера.
- Оценивается соблюдение разумных профессиональных мер предосторожности.

Влияние на статус:
- Должно быть повторно рассмотрено перед реализацией логики выполнения работ в MVP.
- Может наследоваться категориями при необходимости.

## Kitchen Built-in Appliances → Кухонная вытяжка

Status: IN PROGRESS ⚠️ ЧАСТИЧНО ЗАФИКСИРОВАНО

Зафиксировано:
- Архитектура вопросов утверждена.
- Архитектура фотографий утверждена.
- Правила работы через фильтры утверждены.
- Правила для клиента утверждены.
- Правила выполнения работ мастером утверждены.

Остаётся открытым:
- Архитектура сценария «Заменить».
- Наследуемые правила.
- Финальный аудит mini-ТЗ.
- После полного закрытия mini-ТЗ требуется обновление статуса и финальная фиксация блока.

Точка продолжения:
- Следующая рабочая сессия начинается с Kitchen Built-in Appliances → Кухонная вытяжка → сценарий «Заменить».


## Global Materials Separation Rule
Status: APPROVED / STORED ✅

Decision Summary:
- Стоимость работ и стоимость материалов разделяются.
- Материалы, комплектующие и расходные элементы не входят в стоимость заказа платформы.
- Платформа не участвует в ценообразовании дополнительных материалов.

Rule:
- В стоимость заказа входят только работы, предусмотренные согласованным объёмом услуги.
- При необходимости приобретения дополнительных материалов или комплектующих вопрос их приобретения рекомендуется согласовывать посредством чата платформы.

Boundary:
- Платформа не претендует на процент от стоимости материалов.
- Качество и выбор дополнительных материалов остаются предметом договорённости между клиентом и мастером.


## Global Electrical Readiness Rule
Status: APPROVED / STORED ✅

Decision Summary:
- Наличие розетки не подтверждает наличие электропитания.

Rule:
- До начала работ мастер вправе проверить наличие электропитания в точке подключения.
- Поиск неисправностей существующей электропроводки не входит в объём услуги установки.

Boundary:
- Дальнейшие действия согласовываются отдельно между клиентом и мастером.


## Global Completion Evidence Rule
Status: APPROVED / STORED ✅

Decision Summary:
- Завершение работ и завершение заказа являются разными событиями.

Rule:
- После выполнения работ мастер обязан направить клиенту через чат платформы подтверждение результата и фотографии выполненных работ.
- Заказ считается завершённым только после подтверждения клиента посредством функционала платформы.

Boundary:
- Отсутствие клиента на объекте не препятствует выполнению работ.


## Global Service Quality Rule
Status: APPROVED / STORED ✅

Decision Summary:
- Установка не считается качественно выполненной только по факту физического завершения работ.

Rule:
- Базовая работоспособность результата должна быть подтверждена в рамках согласованного объёма заказа.
- Проверки выполняются безопасным способом и в пределах характера выполненных работ.

Boundary:
- Подтверждение базовой работоспособности не является диагностикой скрытых дефектов и не заменяет гарантийные обязательства производителя.


## Registry Language Standard
Status: APPROVED / STORED ✅

Decision Summary:
- Регистр Helpy использует два языка в зависимости от уровня ответственности.
- Настоящий стандарт обязателен для всех последующих изменений регистра.

English:
- code;
- directories;
- database objects;
- table names;
- column names;
- enum values;
- slug values;
- API routes;
- DTO names;
- config keys;
- internal statuses;
- contract names;
- rule names;
- technical identifiers.

Русский:
- UX;
- бизнес-логика;
- правила клиента;
- правила мастера;
- Question Flow;
- Photo Requirements;
- Service Playbook;
- причины принятия решений;
- описания сценариев.

Пример:

Наследуемые правила:
- Packaging Inspection Rules.
- Damage Escalation Rules.
- Chat Evidence Rules.

Closure Note:
- Все последующие изменения регистра должны соответствовать данному стандарту.

---

## Global Diagnostics Pattern
Status: APPROVED / ROADMAP STORED ✅

Decision Summary:
- Diagnostics is not a root category.
- Diagnostics is not a separate marketplace vertical.
- Diagnostics is a reusable category-level branch pattern.
- The client first selects the problem domain/category.
- Inside the category, the client may choose a diagnostic flow when they do not know the exact work required.
- Diagnostic branches are independently enabled or disabled per category.
- Diagnostic branches remain disabled until explicitly approved for that category.

Diagnostics UI Placement Rule:
- Diagnostics lives only inside Create Job flows.
- Diagnostics does not introduce separate application screens.
- Diagnostics does not create a separate marketplace entry mode.
- Diagnostics is implemented using the existing category → subcategory architecture.
- The dynamic form engine requires no special diagnostics support.

Approved Navigation Pattern:

Create Job
↓
Category
↓
Action Branch / Diagnostic Branch
↓
Question Flow
↓
Photo Flow
↓
Preview
↓
Deposit

Reason:
- Clients usually understand the problem domain.
- Clients often do not understand the exact work required.
- The uncertainty exists inside the category, not above it.

Closure Note:
- Future Global Diagnostics is governed by this pattern.
- Root-level diagnostics and entry-mode diagnostics are rejected architectural approaches.

---

## 10. Electrical Shower Policy
Status: CLOSED

Decision Summary:
- Helpy MVP supports installation and replacement scenarios for electric showers.
- Diagnostic and repair scenarios are intentionally excluded from the Electrical domain.
- Repair scenarios are already covered by Plumbing reference flows where applicable.
- In the Thailand market, replacement is generally more economical than repair.
- Electric shower repair will not return to MVP discussion before launch.
- No unresolved architecture decisions remain in this contract.

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
- Замена устройства обычно проще и дешевле ремонта.
## 11. Deferred Categories
Status: CLOSED

Decision Summary:
- Handyman is excluded from MVP launch.
- Handyman will not return to MVP discussion before launch.
- Home Appliances is no longer a deferred category.
- Home Appliances has been promoted into the MVP roadmap as the final category before launch.
- Deferred categories do not block MVP launch.
- No unresolved architecture decisions remain in this contract.

Deferred Categories:
- Handyman

Promoted Category:
- Appliance Installation & Connection
- Установка и подключение бытовой техники

Reason:
- Specialized categories are completed first.
- Handyman is too broad and low-value for Helpy MVP.
- Profile categories, chat negotiation, and fixed-price flows cover most handyman-like scenarios during MVP.

Rule:
- Deferred categories may be reconsidered only after collecting real marketplace statistics following launch.
## 12. Knowledge Base Engine
Status: PARTIALLY CLOSED

Decision Summary:
- Knowledge Base Engine is required for every category.
- Category knowledge must include Client Guidance, Master Guidance, Platform Notes, Safety Notes, and Premium Recommendations.
- Users must not keep category rules in their heads.
- Guidance must be integrated into client and master screens.
- Guidance visibility depends on user role and order stage.
- Exact guidance trigger matrix and mobile screen placement are defined by downstream guidance contracts.
- This contract cannot be CLOSED until the downstream guidance contracts are reviewed and aligned.

Every category must support:
- Client Guidance
- Master Guidance
- Platform Notes
- Safety Notes
- Premium Recommendations

Purpose:
Users should not keep rules in their heads.
System must display information at the correct stage of the order.
## 13. Dynamic Form Engine
Status: PARTIALLY CLOSED

Decision Summary:
- Create Job Screen must be generated dynamically.
- Admin Panel is the source of form structure.
- API delivers form structure to the Mobile Application.
- Mobile Application renders categories, subcategories, questions, photo requirements, rules, and guidance blocks from data.
- No category-specific hardcoded create-job forms are allowed.
- Pure dynamic form engine is the current target architecture.
- Hybrid shell approach may be reconsidered only after the full roadmap and all MVP categories are completed.
- This contract cannot be CLOSED until the final pure dynamic vs hybrid implementation decision is made.

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

## 15. Furniture Skill Levels
Status: CLOSED

Decision Summary:
- Furniture skill levels are manually assigned by the platform.
- A master may be confirmed by the platform or by a more experienced master.
- Skill level controls access to furniture projects by complexity.
- Unconfirmed masters must not access higher-complexity furniture jobs.
- The goal is to prevent masters from learning on the client site and creating avoidable problems.
- No unresolved architecture decisions remain in this contract.

Levels:
- Basic
- Intermediate
- Advanced

Complexity Access:
- Basic: simple cabinet furniture.
- Intermediate: kitchen furniture projects.
- Advanced: complex built-in furniture projects.

Purpose:
Control access to complex furniture projects.
## 16. Global Platform Rules
Status: PARTIALLY CLOSED — RECOVERED FROM VERIFIED CATEGORY SOURCES

Decision Summary:
- Global Platform Rules Registry exists.
- Seven global platform rules were previously approved.
- The rules apply across client, master, and platform workflows.
- Rule #1–Rule #7 are recovered from verified closed category sources: Furniture Assembly, Plumbing and Locks.
- Electrical was reviewed after Contract 23 closure and confirms Rule #1–Rule #7 without introducing new Global Rules.
- Appliance Installation & Connection may add or duplicate global rules before final closure.
- Electrical no longer blocks Contract 16 because its closed category architecture is covered by existing Global Platform Rules.
- No replacement texts may be invented without documentary evidence.

Platform Rules Registry exists.

Confirmed Rules:

### Rule #1 — Client-Safe Scope Rule
Клиент отвечает только на вопросы, которые он объективно может понять.
Платформа не должна требовать от клиента технической диагностики, разборки оборудования, действий с электричеством или иных действий, которые могут быть небезопасны или ухудшить его положение.

Evidence:
- Plumbing: клиент отвечает только на объективно понятные вопросы.
- Plumbing Electric Shower: клиент не разбирает розетки, автоматы или проводку и не выполняет действий, связанных с электричеством.
- Locks: платформа не должна заставлять клиента выполнять действия, которые могут ухудшить его положение как покупателя оборудования.

### Rule #2 — Equipment Packaging Protection Rule
Если клиент уже приобрёл новое оборудование самостоятельно, Helpy не требует вскрытия упаковки до проверки совместимости мастером.
Фотографии упаковки должны позволять увидеть модель, характеристики, размеры и комплектацию, если они указаны производителем.
Клиент должен сохранять право на возврат, обмен и гарантийное обслуживание.

Evidence:
- Plumbing: клиент не должен вскрывать упаковку оборудования для создания заказа.
- Plumbing: при фотографировании упаковки клиент предоставляет упаковку со всей информацией на ней.
- Locks: платформа не требует вскрывать упаковку, нарушать заводские пломбы, раскладывать комплектующие или извлекать оборудование из коробки.

### Rule #3 — Equipment Compatibility Before Demolition Rule
Если работа предполагает замену оборудования, мастер обязан проверить новое оборудование до демонтажа существующего.
Проверка включает совместимость, комплектность, целостность и возможность установки.
Только после проверки мастер приступает к демонтажу.

Evidence:
- Plumbing faucet replacement: мастер проверяет совместимость до демонтажа.
- Plumbing toilet/electric shower replacement: новое оборудование должно быть проверено до работ.
- Locks: проверка нового оборудования до демонтажа существующего закреплена как Global Equipment Verification Rule.

### Rule #4 — Structured Scope Before Chat Rule
Форма заказа собирает первоначальное техническое задание и закрывает визуальную часть ТЗ.
Чат завершает текстовую часть ТЗ, уточняет скрытые работы, материалы, доступ и фиксирует окончательную стоимость.
Чат не заменяет структурированную форму заказа.

Evidence:
- Plumbing: форма собирает первоначальное ТЗ и закрывает визуальную часть.
- Plumbing: чат завершает текстовую часть ТЗ и фиксирует окончательную стоимость.
- Structured Job Scope Contract: Initial job scope is formed from structured questions, answers and required photos.

### Rule #5 — No Extra Photo Requests In Chat Rule
Мастер не может запрашивать дополнительные фотографии в чате, если обязательные фотографии уже определены формой заказа.
Фото-ТЗ должно формироваться через approved photo requirements.
Исключения возможны только через будущие утверждённые правила жизненного цикла чата.

Evidence:
- Plumbing faucet/mixer: мастер не может запрашивать фотографии в чате.
- Plumbing blockage: мастер не может запрашивать дополнительные фотографии в чате.
- Plumbing electric shower: мастер не может запрашивать дополнительные фотографии в чате.

### Rule #6 — One-Time Final Price Rule
Окончательная стоимость заказа может быть изменена мастером только один раз до выбора мастера.
Изменение требует обоснования, обсуждения с клиентом и согласования.
После согласования клиентом и выбора мастера Final Agreed Price становится неизменяемым финансовым фактом заказа.

Evidence:
- Plumbing: окончательная цена фиксируется мастером один раз и после согласования становится неизменяемой.
- Order Entry Price / Final Price Contract: master may change Entry Price only once before selection.
- Final Price Architecture Decision: job-level financial snapshot is immutable after master selection.

### Rule #7 — Platform Boundary / Ownership Rule
Helpy не включает в услугу действия, которые не утверждены как часть сервиса платформы.
Материалы, дополнительные работы, утилизация, вынос демонтированного оборудования, личные вещи клиента, транспортировка, хранение, публичные зоны и вопросы собственности/права доступа не входят в платформенную ответственность, если отдельный контракт явно не утверждает обратное.

Evidence:
- Furniture: master does not move, sort or store client belongings.
- Plumbing: демонтированное оборудование остаётся собственностью клиента; вынос/утилизация не являются услугой Helpy.
- Locks: Helpy не работает с вопросами собственности, аренды и права доступа.
- Air Conditioning: материалы и дополнительные работы согласуются через чат; платформа не участвует в покупке материалов.

Recovery Note:
- Rule #1–Rule #7 recovered from verified category contracts and approved architecture contracts.
- Electrical confirms the existing Global Platform Rules and introduces zero new global rules.
- Electrical evidence is stored in Contract 23 and in the Electrical Category Architecture block.
- Final closure requires review after Appliance Installation & Connection is completed.
- If the future appliance category introduces overlapping global rules, this contract must be reconciled before being marked CLOSED.

## 17. Admin Panel Architecture
Status: PARTIALLY CLOSED — GAP APPROVED

Decision Summary:
- Admin Panel is a Business Logic Builder, not a simple order-management dashboard.
- Admin Panel is the source of truth for categories, subcategories, questions, photo requirements, pricing, guidance, platform settings, rules, evidence, reviews, translations and operational control.
- Mobile app must consume Admin-managed business logic through structured API contracts.
- Runtime Markdown document parsing is not allowed for mobile guidance.
- Draft / Published lifecycle, Audit Log, Preview, Rollback, Health Check and Sandbox Mode are required governance primitives.
- Implementation is not complete: multiple approved builders and roadmap modules remain GAP_APPROVED.
- Final DB baseline vs migration strategy remains DRAFT.
- This contract cannot be CLOSED until Admin builders, platform settings, guidance, rules, evidence, review and DB baseline strategy are aligned.

Implementation State:
- TARGET_APPROVED: Admin Panel as Business Logic Builder.
- IMPLEMENTED: basic Admin dashboard shell, Jobs list, Payments list, Disputes list, Translation Tasks admin endpoints, reset endpoints.
- GAP_APPROVED: Category Builder, Subcategory Builder, Question Builder, Photo Requirement Builder, Pricing Builder, Guidance Builder, Platform Settings Center, Audit Log, Rollback, Rules Simulator, Impact Analysis, Registry Coverage, Sandbox Mode, Notification Center, Admin Order Timeline / Evidence Screen.
- CURRENT GAP: Admin frontend API client still references legacy admin URLs while backend exposes /api/v1/admin/* routes.
- DEFERRED: advanced admin roles, bulk operations, import/export, search everywhere.
- DRAFT: final DB baseline vs 0005 migration strategy.

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

## 18. Future Business Direction
Status: PARTIALLY CLOSED — FUTURE STRATEGY APPROVED

Decision Summary:
- Future Business Direction is strategically approved.
- Design, Production, Logistics and Installation are confirmed post-MVP expansion directions.
- These directions must influence current architecture decisions.
- MVP implementation is not required.
- Database architecture, Admin Panel and business logic systems must support future expansion without redesign.
- Detailed workflows for these directions remain out of scope until post-MVP planning.
- This contract cannot be CLOSED until dedicated architecture contracts are created for these future verticals.

Helpy Projects:
- Design
- Production
- Logistics
- Installation

Purpose:
Prepare the platform architecture for future expansion without redesign.

Scope:
- Not MVP.
- Not required before launch.
## 19. Registry Expansion Plan
Status: CLOSED — RECOVERY METHODOLOGY APPROVED

Decision Summary:
- Service Architecture Registry defines the approved recovery methodology.
- Categories are recovered and expanded only as needed.
- Recovery follows a fixed category template.
- Approved chat history and future DOCX archives are approved recovery sources.
- The purpose of this methodology is to restore architecture quickly instead of redesigning it.
- No replacement architecture may be invented without evidence from approved sources.
- No unresolved architecture decisions remain in this contract.

Recovery Template:
- Subcategories
- Client Questions
- Required Photos
- Client Guidance
- Master Guidance
- Platform Rules
- Pricing Rules
- Admin Dependencies

Approved Recovery Sources:
- Approved chat history
- Future DOCX archives

Purpose:
Recover approved architecture rather than recreate it.
---
## 20. Service Architecture Registry — Furniture Assembly
Status: CLOSED — STORED + DOCS VERIFIED

Decision Summary:
- Furniture Assembly is fully recovered and verified.
- Registry evidence exists in approved documentation and stored archives.
- Furniture Assembly has reached the approved Helpy reference level of detail.
- Kitchen Assembly, Cabinet Furniture and Built-in Furniture retain their individual historical statuses.
- Internal category contracts remain unchanged.
- No unresolved architecture decisions remain at the Furniture Assembly root level.

Registry Status: STORED + DOCS VERIFIED ✅
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
## 21. Service Architecture Registry — Cleaning
Status: CLOSED — STORED + DOCS VERIFIED

Decision Summary:
- Cleaning is fully recovered and verified.
- Registry evidence exists in approved documentation and stored archives.
- Cleaning is a specialized reference category with its own business logic.
- Regular Cleaning, Deep Cleaning and Post-Repair Cleaning retain their individual historical statuses.
- Internal category contracts remain unchanged.
- No unresolved architecture decisions remain at the Cleaning root level.

Registry Status: STORED + DOCS VERIFIED ✅
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


## 22. Service Architecture Registry — Air Conditioning
Status: CLOSED — APPROVED / STORED + DOCS VERIFIED

Decision Summary:
- Air Conditioning is an approved Helpy MVP root category.
- Repair is removed from Air Conditioning for launch.
- Preventive maintenance is not a separate launch subcategory and is treated as Cleaning from the client perspective.
- Relocation remains disabled on launch.
- Categories and subcategories must support independent enabled/disabled status.
- No unresolved architecture decisions remain at the Air Conditioning root level.

Registry Status: APPROVED / STORED + DOCS VERIFIED ✅

### Root Category
Air Conditioning

### Subcategories
Enabled on launch:
- Cleaning.
- Not Cooling.
- Leaking.
- Installation.
- Removal.
- Remote Control Issues.

Disabled on launch:
- Relocation.

Removed from MVP:
- Repair.

Reason:
- For Pattaya MVP, repair is high-variance and often less practical than replacement.
- Preventive maintenance is perceived by clients as cleaning.
- Relocation requires combined removal, installation and technical risk, so it remains disabled for launch.

---

### 22.1 Cleaning
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions
1. Air conditioner type:
   - Wall split.
   - Cassette.
   - Floor standing.
   - I do not know.

2. Quantity:
   - 1 unit.
   - 2 units.
   - 3 units.
   - More than 3 units.

3. Approximate BTU / size:
   - 9,000–12,000 BTU.
   - 18,000 BTU.
   - 24,000 BTU.
   - I do not know.

4. Is the indoor unit accessible?
   - Yes.
   - No.
   - I do not know.

5. Is the outdoor unit accessible?
   - Yes.
   - No.
   - Balcony access.
   - Requires ladder / difficult access.
   - I do not know.

#### Required Photos
- Indoor unit front view.
- Indoor unit side / installation area.
- Outdoor unit access photo if available.
- Drain hose / water outlet area if visible.

#### Client Rules
- Client provides access to indoor unit.
- Client provides access to outdoor unit if required.
- If outdoor access is unsafe or unavailable, master may clean indoor unit only after agreement in chat.
- Additional chemical cleaning or hard-access work is agreed through chat.

#### Master Rules
- Verify indoor and outdoor access before confirming scope.
- Do not perform unsafe height work without explicit agreement and proper equipment.
- Record unavailable access or visible damage in platform chat before work starts.
- Explain to client if cleaning cannot solve cooling problems.

#### Pricing
- Cleaning Base Price: editable from Admin Panel.
- Multi-unit discount: editable from Admin Panel.
- Difficult access surcharge: agreed through chat.

---

### 22.2 Not Cooling
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions
1. What happens?
   - Blows warm air.
   - Weak cooling.
   - Works then stops cooling.
   - Error light / error code.
   - I do not know.

2. When was the last cleaning?
   - Less than 3 months ago.
   - 3–6 months ago.
   - More than 6 months ago.
   - I do not know.

3. Is the outdoor unit running?
   - Yes.
   - No.
   - I do not know.

4. Is there an error code?
   - Yes, client enters text/photo.
   - No.
   - I do not know.

#### Required Photos
- Indoor unit front view.
- Outdoor unit photo if accessible.
- Remote display / error code if visible.
- General installation area.

#### Client Rules
- This subcategory is diagnostics-first.
- Final repair scope and parts are agreed through chat.
- If replacement is more practical than repair, master must explain before work continues.

#### Master Rules
- Diagnose before offering repair work.
- Do not promise refrigerant refill, compressor repair or PCB repair before inspection.
- High-risk or major repair can be refused for MVP scope.
- Record diagnosis and recommended next step in chat.

#### Pricing
- Diagnostics Base Price: editable from Admin Panel.
- Additional repair / parts are outside base price and agreed through chat.

---

### 22.3 Leaking
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions
1. Where is water leaking?
   - From indoor unit.
   - From drain hose.
   - From outdoor unit.
   - I do not know.

2. When does it leak?
   - Immediately after turning on.
   - After some time.
   - Constantly.
   - Only sometimes.

3. Was the unit recently cleaned or serviced?
   - Yes.
   - No.
   - I do not know.

#### Required Photos
- Leak location.
- Indoor unit front view.
- Drain hose / drain area if visible.
- Wall/floor damage area if present.

#### Client Rules
- Client should stop using the unit if water may damage electrical points or furniture.
- Water damage repair is not included.
- Drain cleaning, cleaning and additional work are agreed through chat if outside base scope.

#### Master Rules
- Check drain blockage, indoor unit slope and visible installation issues.
- Do not open walls or perform construction work under this subcategory.
- Record likely cause and next step in chat.

#### Pricing
- Leak Diagnostics Base Price: editable from Admin Panel.
- Drain cleaning surcharge: editable from Admin Panel or agreed through chat.

---

### 22.4 Installation
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions
1. Is the air conditioner new or used?
   - New.
   - Used.
   - I do not know.

2. Is there an existing installation point?
   - Yes.
   - No.
   - I do not know.

3. Approximate BTU / size:
   - 9,000–12,000 BTU.
   - 18,000 BTU.
   - 24,000 BTU.
   - More than 24,000 BTU.
   - I do not know.

4. Wall type:
   - Concrete.
   - Brick.
   - Drywall / gypsum.
   - I do not know.

5. Outdoor unit location:
   - Balcony.
   - Ground level.
   - Wall bracket.
   - Roof / difficult access.
   - I do not know.

#### Required Photos
- Indoor installation place.
- Outdoor unit installation place.
- Existing wall hole / piping route if present.
- Electrical point / socket / breaker area if visible.
- Air conditioner label / box / specification if available.

#### Client Rules
- Air conditioner and parts must be on site before master arrives.
- Electrical relocation, new wiring, breaker work and wall construction are not included by default.
- Additional pipe length, brackets, drain hose, cable and materials are agreed through chat.
- Platform does not participate in materials purchase.

#### Master Rules
- Verify safe indoor and outdoor installation points.
- Verify wall type and outdoor access.
- Do not perform unsafe height work without proper equipment and agreement.
- Materials and extra work must be confirmed in chat before work starts.

#### Pricing
- Installation Base Price by BTU range: editable from Admin Panel.
- Extra pipe / drain / bracket / difficult access surcharge: agreed through chat or Admin baseline.

---

### 22.5 Removal
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions
1. What should be removed?
   - Indoor and outdoor units.
   - Indoor unit only.
   - Outdoor unit only.
   - I do not know.

2. Should the old unit be preserved?
   - Yes.
   - No.
   - I do not know.

3. Is disposal required?
   - Yes.
   - No.

4. Is outdoor unit accessible?
   - Yes.
   - No.
   - Balcony access.
   - Difficult access.
   - I do not know.

#### Required Photos
- Indoor unit.
- Outdoor unit if accessible.
- Pipe route / wall hole if visible.
- Access area.

#### Client Rules
- Removal does not automatically include disposal.
- Wall repair, repainting and finishing are not included.
- Preservation of removed unit must be agreed before work starts.

#### Master Rules
- Confirm whether unit must be preserved.
- Protect client property during removal.
- Place removed parts in agreed area.
- Record existing wall damage or access risk in chat before work starts.

#### Pricing
- Removal Base Price: editable from Admin Panel.
- Disposal surcharge: editable from Admin Panel or agreed through chat.
- Difficult access surcharge: agreed through chat.

---

### 22.6 Remote Control Issues
Status: APPROVED / CLOSED / STORED + DOCS ✅

#### Client Questions
1. What is the issue?
   - Remote does not turn on.
   - Remote display works but AC does not respond.
   - Some buttons do not work.
   - Remote is lost.
   - I do not know.

2. Are batteries replaced?
   - Yes.
   - No.
   - I do not know.

3. Is there another remote / mobile control?
   - Yes.
   - No.
   - I do not know.

#### Required Photos
- Remote control front.
- Remote display if visible.
- Air conditioner model label if available.
- Indoor unit front view.

#### Client Rules
- Batteries are checked by client before visit if possible.
- Replacement remote purchase is not handled by platform.
- Compatibility and purchase options are agreed through chat.

#### Master Rules
- Verify batteries, remote signal and unit receiver if possible.
- Do not promise remote replacement availability before model check.
- Record model and recommendation in chat.

#### Pricing
- Remote Diagnostics Base Price: editable from Admin Panel.
- Replacement remote/materials are outside platform base price.

---

### 22.7 Relocation
Status: APPROVED / DISABLED ON LAUNCH / STORED + DOCS ✅

#### Scope
Relocation combines removal and installation of the same air conditioner in a new place.

#### Launch Decision
- Disabled on launch.
- Can be enabled later from Admin Panel after operational validation.

#### Reason
- Requires removal, installation, material calculation and access risk in one order.
- Higher chance of hidden extra work.
- Better handled after installation/removal flows are proven.

---

### Business Rules
- Client chooses the problem, not the profession.
- Preventive maintenance is not a separate subcategory for launch.
- Repair is removed from Air Conditioning MVP.
- Materials and additional work are agreed between client and master through chat.
- Platform does not participate in materials purchase.
- Each subcategory has independent enabled/disabled status.
- High-risk work may be refused by master if unsafe or outside MVP scope.

### Service Playbook
1. Client selects Air Conditioning subcategory.
2. Client answers structured questions.
3. Client uploads required photos.
4. Master reviews access, unit type and risk.
5. Master sends offer or asks clarifying questions in chat.
6. Extra materials or additional work are confirmed in chat.
7. Work result and exceptions are recorded in chat before completion.

### Admin Dependencies
- Air Conditioning category enabled/disabled.
- Independent subcategory enabled/disabled.
- Cleaning Base Price.
- Diagnostics Base Price.
- Leak Diagnostics Base Price.
- Installation Base Price by BTU range.
- Removal Base Price.
- Remote Diagnostics Base Price.
- Multi-unit discount.
- Disposal surcharge.
- Difficult access surcharge.
- Required photos management.
- Question management.
- Rule visibility.

### FAQ
- Repair is not a launch subcategory.
- Preventive maintenance is shown to clients as Cleaning.
- Disposal is separate from Removal.
- Materials are not included automatically.
- Platform deposit is platform income and does not cover materials.
- Relocation is approved but disabled on launch.
---
## 23. Service Architecture Registry — Electrical
Status: CLOSED ✅

Decision Summary:
- Electrical is a historically approved root category.
- Legacy category structure has been reconciled against the current Registry standard.
- Legacy decisions have been reconciled and incorporated into the final Electrical Registry.
- Electrical has been migrated to the current Helpy Registry template.
- High-risk electrical work is excluded from MVP.
- Lighting and ceiling fans remain disabled on launch.
- Appliance connection inside Electrical must be re-audited against the future Appliance Installation & Connection root category.
- Materials and additional work are agreed between client and master through chat.
- Platform does not participate in materials purchase.
- Electrical is fully aligned with the current Helpy Registry standard.

Registry Status: CLOSED ✅

Closure Notes:
- No Electrical-specific GAP remained after full audit.
- Existing Helpy Global Rules fully cover Electrical business scenarios.
- Electrical reached Plumbing-level completeness through inheritance and approved category-specific decisions.
- Electrical launch scope is finalized and approved.


Reason:
- Категория №2 после Air Conditioning.
- Содержит утвержденные исторические решения и требует приведения к текущему шаблону Registry.

Approved Legacy Structure:

ROOT: Electrical

Root Question:
Что нужно сделать?

Approved Branches:
- Розетки и выключатели.
- Диагностика неисправности.

See Contract 11:
- Appliance Installation & Connection.
- Установка и подключение бытовой техники.

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


Electrical Re-Audit Decisions:
Status: APPROVED ✅

Point-Based Mini Scope Pattern:
- Electrical uses Point-Based Mini Scope Pattern.
- One physical work point equals one mini technical assignment.
- A mini assignment groups all data related to that point.

Mini Scope contains:
- work type;
- point-specific parameters;
- required photos for that point.

Approved Launch Structure:
Electrical
├─ Установить розетку/выключатель
├─ Заменить розетку/выключатель
└─ Перенести розетку/выключатель

Reason:
- Clients think in terms of "do work here" rather than electrical device taxonomy.
- Point grouping naturally links photos to the correct work location.
- The approach simplifies UX and scales to multiple work points.

Boundary:
- Detailed question flows remain OPEN until full Contract 23 closure.
- Client/Master Rules remain OPEN.
- Service Playbook remains OPEN.
- Pricing remains OPEN.
- Admin Dependencies remain OPEN.


Equipment Verification Principle:
Status: APPROVED ✅

Purpose:
- Allow masters to assess equipment compatibility before work begins.
- Reduce client purchasing mistakes.
- Surface hidden complexity before Final Agreed Price.

Rule:
- If the client already purchased equipment, the form provides visual equipment verification.

Equipment Verification Photos answer:
- Is the equipment compatible?
- Did the client purchase the correct item?
- Does the mounting type match?
- Are additional materials required?
- Is the equipment complete?

Scope:
- Plumbing.
- Electrical.
- Appliance Installation & Connection.
- Future categories involving client-provided equipment.

Optimization Rule:
- If multiple identical items are used in one order, one shared equipment photo is sufficient if the master can identify:
  - model;
  - type;
  - quantity.

Boundary:
- Equipment Verification Photos do not replace Visual Coverage Photos.
- Equipment Verification Photos are required only when equipment is already present on site.
- If equipment has not yet been purchased, compatibility is clarified later through chat.



### Electrical Re-Audit Note → Mixed Work Types Inside Mini Scope

Status: TECH_DEBT / FUTURE FULL CATEGORY AUDIT

Decision Summary:
- Current Electrical MVP uses separate branches for install, replace and relocate scenarios.
- Each branch uses Point-Based Mini Scope Pattern, where one physical work point equals one mini technical assignment.
- During Kitchen Built-in Appliances design, a stronger mini-scope pattern was identified: work type can be stored inside each mini technical assignment.

Current Limitation:
- Current Electrical architecture does not allow one Electrical order to contain mixed work types inside the same order.
- Example real-life scenario:
  - install two new sockets;
  - replace one existing socket;
  - relocate one existing socket.

Future Audit Rule:
- During full category audit, Electrical must be re-audited for mixed work type support inside mini scopes.
- The future target pattern should be evaluated as:
  - one Electrical order;
  - multiple mini technical assignments;
  - each mini technical assignment contains its own work type:
    - install;
    - replace;
    - relocate, if applicable.

Boundary:
- This note does not change the approved Electrical MVP implementation.
- No current Electrical branch should be rewritten from this note alone.
- Any change requires separate full Electrical re-audit, UX review, pricing review, implementation impact review and approval.


### Electrical → Установить розетку/выключатель
Registry Status: 🟨 PARTIALLY APPROVED

Definition:
- Установка = монтаж новой розетки или выключателя без демонтажа существующего изделия.
- Ветка использует Point-Based Mini Scope Pattern.
- Одна точка установки = одно мини-ТЗ.

Question / Photo Flow:
1. Новые изделия уже есть на объекте?
   - Да
   - Нет

2. Что нужно установить?

For each work point:
- Что устанавливаем?
  - Розетка
  - Выключатель
- Тип установки:
  - Накладная
  - Внутренняя
- Фото места установки:
  - required

Add More Rule:
- Клиент может добавить одну или несколько точек через кнопку «Добавить ещё».
- Количество точек не задаётся отдельным вопросом.
- Количество точек определяется количеством созданных мини-ТЗ.

Photo Rule:
- Фотографии должны обеспечивать визуальное покрытие всех точек установки.
- Каждая точка установки должна быть однозначно идентифицируема мастером.
- Одно фото может покрывать несколько точек, если они хорошо различимы.
- Общий лимит фотографий заказа — 10.
- Клиент не обязан фотографировать щит, провода, автоматы или выполнять небезопасные действия.

Equipment Verification Rule:
- Если новые изделия уже есть на объекте, клиент добавляет фото общего вида этих изделий.
- Фото оборудования не заменяет фото фронта работ.
- Одно фото может покрывать несколько одинаковых изделий, если мастер видит тип, модель и количество.

Chat Completion Rule:
- Если тип установки, посадочное место, материалы или сложность работ требуют уточнения, мастер уточняет это через чат.
- Эти уточнения могут повлиять на Final Agreed Price до выбора мастера.

GAP:
- Client Rules remain OPEN.
- Master Rules remain OPEN.
- Service Playbook remains OPEN.
- Business Rules remain OPEN.
- Admin Dependencies remain OPEN.


### Electrical → Заменить розетку/выключатель
Registry Status: 🟨 PARTIALLY APPROVED

Definition:
- Замена = демонтаж существующего изделия + установка нового изделия.
- Ветка использует Point-Based Mini Scope Pattern.
- Одна точка замены = одно мини-ТЗ.

Question / Photo Flow:
1. Новые изделия уже есть на объекте?
   - Да
   - Нет

2. Что нужно заменить?

For each work point:
- Что заменяем?
  - Розетка
  - Выключатель
- Тип установки:
  - Накладная
  - Внутренняя
- Фото существующего места установки:
  - required

Add More Rule:
- Клиент может добавить одну или несколько точек через кнопку «Добавить ещё».
- Количество точек не задаётся отдельным вопросом.
- Количество точек определяется количеством созданных мини-ТЗ.

Photo Rule:
- Фотографии должны обеспечивать визуальное покрытие всех точек замены.
- Существующие изделия должны быть однозначно идентифицируемы мастером.
- Одно фото может покрывать несколько точек, если они хорошо различимы.
- Общий лимит фотографий заказа — 10.
- Клиент не обязан разбирать изделия, фотографировать щит, провода или выполнять небезопасные действия.

Equipment Verification Rule:
- Если новые изделия уже есть на объекте, клиент добавляет фото общего вида этих изделий.
- Фото оборудования не заменяет фото существующих точек замены.
- Одно фото может покрывать несколько одинаковых изделий, если мастер видит тип, модель и количество.

Chat Completion Rule:
- Если совместимость изделий, материалы, посадочные особенности или сложность работ требуют уточнения, мастер уточняет это через чат.
- Эти уточнения могут повлиять на Final Agreed Price до выбора мастера.

GAP:
- Client Rules remain OPEN.
- Master Rules remain OPEN.
- Service Playbook remains OPEN.
- Business Rules remain OPEN.
- Admin Dependencies remain OPEN.


### Electrical → Перенести розетку/выключатель
Registry Status: 🟨 PARTIALLY APPROVED

Definition:
- Перенос = демонтаж существующего изделия + изменение расположения + установка изделия в новом месте.
- Ветка использует Point-Based Mini Scope Pattern.
- Одна точка переноса = одно мини-ТЗ.

Question / Photo Flow:

For each work point:
- Что переносим?
  - Розетка
  - Выключатель

- Фото текущего места:
  - required

- Фото нового места:
  - required

Add More Rule:
- Клиент может добавить одну или несколько точек через кнопку «Добавить ещё».
- Количество точек определяется количеством созданных мини-ТЗ.

Photo Rule:
- Фотографии должны обеспечивать визуальное покрытие текущего и нового расположения всех точек переноса.
- Для каждой точки мастер должен понимать, откуда переносится изделие и куда оно переносится.
- Одно фото может покрывать несколько точек, если соответствие между текущим и новым местом остаётся очевидным.
- Общий лимит фотографий заказа — 10.
- Клиент не обязан фотографировать щит, провода, автоматы или выполнять небезопасные действия.

Equipment Verification Rule:
- Если новые изделия уже есть на объекте, клиент добавляет фото общего вида этих изделий.
- Фото оборудования не заменяет фото текущего и нового места переноса.
- Одно фото может покрывать несколько одинаковых изделий, если мастер видит тип, модель и количество.

Decoration Rule:
- Перенос не включает восстановление декоративной отделки по умолчанию.
- Покраска, штукатурка, плитка, обои и иные отделочные работы не входят в базовую услугу.

Chat Completion Rule:
- Дополнительные работы по декоративной отделке могут обсуждаться через чат.
- Эти работы не входят в базовую стоимость по умолчанию.
- Уточнения могут повлиять на Final Agreed Price до выбора мастера.

GAP:
- Client Rules remain OPEN.
- Master Rules remain OPEN.
- Service Playbook remains OPEN.
- Business Rules remain OPEN.
- Admin Dependencies remain OPEN.

### Electrical → Admin Dependencies
Registry Status: CLOSED ✅

Decision:
- Electrical does not introduce new admin modules beyond approved Helpy Admin / Dynamic Form capabilities.
- Electrical inherits the existing category, subcategory, question, photo requirement, pricing, rule visibility and guidance administration model.

Required Admin Capabilities:
- Electrical category enabled/disabled.
- Electrical launch branches enabled/disabled.
- Disabled future branches remain configurable but hidden from launch UI.
- Point-Based Mini Scope Pattern support.
- Question management for install, replace and relocate branches.
- Visual Coverage photo requirement management.
- Equipment Verification photo requirement management.
- Total photo limit enforcement.
- Pricing management for launch branches.
- Rule visibility for client/master guidance.
- Future Global Diagnostics must remain hidden from Electrical launch flow until approved.

Conclusion:
- No unresolved Electrical-specific Admin Dependencies remain.

### Electrical → Client Rules
Registry Status: CLOSED ✅

- Клиент отвечает только на вопросы, которые объективно понимает.
- Клиент не обязан обладать специальными знаниями в электрике.
- Клиент не обязан выполнять действия, связанные с электричеством.
- Клиент не обязан открывать электрощит.
- Клиент не обязан разбирать изделия.
- Клиент не обязан фотографировать автоматы, проводку и внутренние соединения.
- Если ветка требует новое изделие, новое изделие должно быть на объекте до создания заказа.
- Если новое изделие отсутствует, создание заказа по данной ветке невозможно.
- Фотографии должны обеспечивать визуальное покрытие фронта работ.
- Общий лимит фотографий заказа составляет 10.
- Одно фото может покрывать несколько точек, если они хорошо различимы.
- Фото оборудования не заменяют фотографии фронта работ.
- Дополнительные детали и материалы уточняются через чат.
- Личные вещи клиента перемещает только клиент; мастер не обязан и не должен перемещать, сортировать или убирать личные вещи клиента.

### Electrical → Master Rules
Registry Status: CLOSED ✅

Before Work:
- Мастер оценивает достаточность информации.
- При необходимости мастер запрашивает уточнения через чат.
- Мастер предупреждает клиента о несовместимости оборудования или необходимости дополнительных материалов.
- Изменение Final Agreed Price должно быть согласовано до выбора мастера клиентом.
- Мастер не принимает работы, выходящие за рамки MVP или связанные с запрещёнными высокорисковыми операциями.

During Work:
- Работы под напряжением запрещены.
- Перед началом работ мастер обязан отключить электропитание соответствующего участка.

After Work:
- Мастер обязан проверить работоспособность выполненных работ.
- Проверка выполняется без применения специализированного диагностического оборудования, если иное не согласовано отдельно между клиентом и мастером.
- Мастер обязан убедиться в качестве выполненного монтажа.
- Мастер обязан оставить рабочее место в чистом и безопасном состоянии.

Safety Escalation:
- При обнаружении опасного состояния существующей электропроводки, оборудования или условий эксплуатации мастер обязан сообщить об этом клиенту.
- Обнаружение опасности не обязывает мастера выполнять работы вне MVP или вне своей квалификации.
- Мастер вправе отказаться от продолжения работ, если дальнейшее выполнение создаёт угрозу жизни, здоровью или имуществу.

Electrical Diagnostics:
Status: HISTORICAL — MOVED TO FUTURE GLOBAL DIAGNOSTICS

- Не работает розетка.
- Не работает выключатель.
- Нет света.
- Периодически пропадает питание.
- Искрит.
- Не знаю.
- Другое.

Decision:
- Diagnostics is not part of Electrical launch scope.
- Diagnostics must be re-audited as a future global platform capability.
- Historical diagnostic answers are preserved here as source material only.

Appliance Connection Historical Notes:
- Not part of Electrical launch scope.
- Governed by Contract 11: Appliance Installation & Connection / Установка и подключение бытовой техники.
- Historical launch candidates preserved for Contract 11 category work: варочная панель, духовой шкаф, вытяжка, другое.
- Historical future expansion candidates preserved for Contract 11 category work: микроволновая печь, измельчитель отходов, встроенный холодильник, винный шкаф, кофемашина, ледогенератор, другая кухонная техника.

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

## 24. Service Architecture Registry — Plumbing
Status: CLOSED — STORED + DOCS VERIFIED

Decision Summary:
- Plumbing is fully recovered and verified.
- Registry evidence exists in approved documentation and stored archives.
- Faucet/Mixer, Blockage and Toilet branches are complete.
- Electric Shower installation and replacement branches remain approved.
- Electric Shower repair scenarios were later excluded by the approved Electrical Shower Policy contract.
- Legacy GAP has been aligned with current approved decisions.
- No unresolved architecture decisions remain at the Plumbing root level.

### Plumbing Registry Content

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
Registry Status: ✅ STORED + DOCS

Root Question:
Что нужно сделать?

Approved Branches:
- Установить новый ✅ STORED + DOCS
- Заменить существующий ✅ STORED + DOCS

Excluded From MVP:
- Плохо греет воду
- Протекает
- Выбивает автомат / отключается электричество

Alignment Note:
- Repair scenarios are excluded according to the approved Electrical Shower Policy contract.
- Electric shower repair scenarios do not return to MVP discussion before launch.
- The previous partial storage GAP is closed because excluded repair branches are no longer required for MVP completion.

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
- Нет. Подкатегория завершена.

## 25. Service Architecture Registry — Locks
Status: CLOSED — STORED + DOCS VERIFIED

Decision Summary:
- Locks is fully recovered and verified.
- Registry evidence exists in approved documentation and stored archives.
- Locks remains a standalone Helpy root category.
- Locks is not moved into Handyman.
- Internal category contracts remain unchanged.
- The current Registry Review completes the previous final audit GAP.
- No unresolved architecture decisions remain at the Locks root level.

Registry Status: STORED + DOCS VERIFIED ✅

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
- Нет. Корневая категория Locks завершена и верифицирована в рамках текущего Registry Review.

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

Status: GAP_APPROVED

Implementation State:
- TARGET_APPROVED: full append-only business timeline.
- IMPLEMENTED: master_selected, work_started, evidence_uploaded, completion_confirmed_by_client, job_completed.
- PARTIAL: payment lifecycle exists but timeline coverage is incomplete.
- GAP_APPROVED: order_created, job_published, initial_offer_sent, price_adjustment_requested, price_adjustment_approved, final_application_sent, financial_snapshot_created, deposit_created, deposit_paid, commission_obligation_created, dispute_opened, dispute_resolved, refund_issued, review_submitted, admin_intervention.
- CURRENT GAP: runtime does not emit the full approved canonical timeline.

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
Этот раздел перечисляет технические `event_type`, которые используются в `job_events`.
Названия событий не переводятся, потому что они являются частью будущей схемы БД, API и runtime-логики.

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
- commission_collected;
- refund_issued.

#### Work / Evidence / Completion

- work_started;
- evidence_uploaded;
- arrival_coordination_requested;
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

Current migration `0004_job_events_timeline.sql` already supports active canonical/runtime event types:
- deposit_paid;
- master_selected;
- work_started;
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
- evidence_uploaded.

Current migration also still supports legacy/reserved DB-domain event types:
- work_completed_by_master;
- attachment_policy_changed.

Runtime must not emit legacy/reserved event types unless a future approved migration/runtime contract explicitly reactivates them.

### Known Domain Gap

The current DB domain does not yet include all canonical event types.

Missing canonical event types:
- order_created;
- job_published;
- initial_offer_sent;
- final_application_sent;
- financial_snapshot_created;
- deposit_created;
- commission_obligation_created;
- commission_collected;
- arrival_coordination_requested.

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

Status: GAP_APPROVED

Implementation State:
- TARGET_APPROVED: role-aware Timeline API over job_events.
- IMPLEMENTED: job_events storage and partial event emission.
- GAP_APPROVED: client timeline endpoint, master timeline endpoint, admin timeline endpoint, visibility filtering, event enrichment.
- CURRENT GAP: no runtime Timeline API endpoints exist.

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
| commission_collected | no | selected master | yes | no | yes |
| refund_issued | yes | if affected | yes | yes | no |
| arrival_coordination_requested | yes | selected master | yes | yes | no |
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
| commission_collected | no | selected master | no | explain master commission obligation has been collected |
| arrival_coordination_requested | yes | selected master | yes | guide chat-based arrival coordination after financial route is fixed |
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



## Cognitive Load Audit Backlog
Status: STORED ✅

### 1. Atomic Orders vs Composite Orders
Status: ARCHITECTURAL FACT

Описание:
- Атомарные заказы используются для одиночной техники.
- Составные заказы (mini-ТЗ) используются для Kitchen Built-in.
- Решение утверждено, внесено в регистр и подтверждено аудитом.

Действие:
- Не пересматривать без появления новых доказательств, влияющих на продукт.

Приоритет:
- NONE.


### 2. Унификация формулировок типов работ
Status: TECH DEBT

Описание:
- В старых сценариях Appliance используются формулировки:
  - «Установить новую технику»;
  - «Заменить существующую технику».
- В Kitchen Built-in используются:
  - «Установить и подключить»;
  - «Заменить».

Действие:
- После завершения Appliance провести аудит унификации терминологии.

Приоритет:
- LOW.


### 3. Electrical Cognitive Load Audit
Status: MANUAL REVIEW REQUIRED

Описание:
- Автоматический аудит выявил возможные повторяющиеся технические вопросы.
- Необходимо визуально проверить Electrical на предмет лишней когнитивной нагрузки.

Действие:
- Провести ручной аудит глазами.

Приоритет:
- MEDIUM.


### 4. Global Low Cognitive Load Rule
Status: GLOBAL RULE CANDIDATE

Описание:
- Если информация уже определяется:
  - контекстом категории;
  - ранее выбранной веткой;
  - обязательными фотографиями;
то повторно спрашивать клиента не следует.

Действие:
- После завершения общего аудита оформить как глобальное правило.

Приоритет:
- HIGH.


### 5. Registry Language Cleanup
Status: CONTINUOUS IMPROVEMENT

Описание:
- Во время будущих аудитов устранять остатки англоязычных терминов,
если они не являются технически необходимыми.

Действие:
- Выполнять постепенно без влияния на MVP.

Приоритет:
- LOW.


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

Канонический процент депозита / комиссии:
- 30% — утверждённый базовый процент депозита / комиссии платформы.
- 40% отклонены как ошибочное историческое значение Chain 0001.
- Процент должен изменяться из Admin Panel без релиза приложения.
- Admin может менять процент для утверждённых бизнес-сценариев: сезонные скидки, запусковые кампании, пиковые сезонные надбавки.
- Активный процент, применённый в момент выбора мастера, должен сохраняться в постоянном финансовом снимке заказа.
- Будущая архитектура БД должна хранить процент как версионируемую бизнес-конфигурацию, а не как захардкоженную runtime-логику.

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

Status: GAP_APPROVED

Implementation State:
- TARGET_APPROVED: complete separation of chat context and immutable business timeline.
- IMPLEMENTED: chat_messages separated from job_events; partial timeline event emission.
- GAP_APPROVED: full price negotiation evidence, financial timeline evidence, admin evidence aggregation.
- CURRENT GAP: runtime does not emit and expose the complete approved communication timeline.

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
- financial_snapshot_created;
- deposit_created;
- deposit_paid;
- commission_obligation_created;
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

Status: GAP_APPROVED

Implementation State:
- TARGET_APPROVED: chat_threads as canonical chat context model.
- IMPLEMENTED: chat_messages linked directly to jobs.
- GAP_APPROVED: chat_threads table, thread lifecycle, thread visibility rules, admin thread aggregation.
- CURRENT GAP: runtime does not implement chat_threads.

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

Status: GAP_APPROVED

Implementation State:
- TARGET_APPROVED: full offer lifecycle with negotiation history.
- IMPLEMENTED: offers.status and simple offer.price flow.
- GAP_APPROVED: initial_offer_price, revised_offer_price, price_revision_reason, price_revision_requested_at, final_application_sent_at, final_agreed_price.
- CURRENT GAP: runtime does not preserve approved offer lifecycle facts and history.

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


### Financial Event Creation Rule

After `master_selected`, the platform must first create the immutable job financial snapshot.

Required event:
- financial_snapshot_created.

Then payment method determines the next financial event:

PromptPay:
- create deposit payment state;
- emit deposit_created;
- later emit deposit_paid only after confirmed payment.

Bank Transfer:
- create pending manual/verified deposit payment state;
- emit deposit_created;
- later emit deposit_paid only after admin/verified confirmation.

Cash:
- do not create client deposit-paid state;
- create master commission obligation state;
- emit commission_obligation_created.

Rule:
- deposit_created and commission_obligation_created are mutually exclusive for the selected payment method.
- deposit_paid must never be emitted for Cash unless a future approved cash-collection contract explicitly changes this rule.
- financial_snapshot_created is internal/admin-visible proof that payment/commission was calculated from fixed Final Agreed Price.


---

## Final Price Architecture Decision

Status: GAP_APPROVED

Implementation State:
- TARGET_APPROVED: offer-level negotiation history + immutable job financial snapshot.
- IMPLEMENTED: selected_offer_price copied to jobs and deposit_amount calculated during selection.
- GAP_APPROVED: initial_offer_price, revised_offer_price, offers.final_agreed_price, jobs.final_agreed_price, commission_base_amount, price_change_reason, confirmation_timestamp, client_confirmation_evidence.
- CURRENT GAP: runtime and schema do not preserve final price evolution.

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

### Final Price Ownership Rule

`offers.final_agreed_price` is offer-scoped negotiation history.

It preserves the final price submitted by a specific master in a specific final application.

Multiple offers for the same job may have different `offers.final_agreed_price` values before master selection.

`jobs.final_agreed_price` is the order-level immutable financial snapshot.

It is copied from the selected offer/application at master selection time and becomes the source for commission, deposit, payment method and dispute evidence.

After master selection, `jobs.final_agreed_price` must not be recalculated from offers.

### Canonical Rule

When a master is selected:

- jobs.final_agreed_price becomes the financial snapshot;
- commission_base_amount is fixed;
- deposit_percent is fixed;
- jobs.deposit_percent хранит процент депозита / комиссии, установленный в Admin Panel и действовавший в момент выбора мастера;
- Последующие изменения процента в Admin Panel не должны пересчитывать исторические финансовые снимки заказов.
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

Status: GAP_APPROVED

### Назначение

Контракт определяет канонический жизненный цикл заказа Helpy.

Helpy является Guided Job Flow платформой: заказ проходит через управляемые этапы от создания технического задания до подтверждённого результата, отзыва или спора.

### Текущее состояние

TARGET_APPROVED:
- полный канонический жизненный цикл заказа;
- разделение business lifecycle, chat, financial route и evidence;
- поддержка PromptPay QR, Cash, Bank Transfer и будущих платёжных маршрутов.

IMPLEMENTED:
- structured job creation;
- master selection;
- work_started;
- evidence flow;
- completion flow.

GAP_APPROVED:
- full offer lifecycle;
- immutable financial snapshot;
- payment method route;
- master Safety Gate;
- arrival coordination;
- commission collection для Cash;
- полный timeline через job_events.

CURRENT GAP:
- runtime реализует только часть утверждённого lifecycle;
- старые runtime-фрагменты не должны считаться каноническим источником бизнес-логики.

### Канонический жизненный цикл заказа

Admin / Platform
↓
задаёт Entry Price через pricing rules / Admin Panel
↓
Client
↓
видит Entry Price
↓
создаёт заказ через structured questions и required photos
↓
формирует initial structured job scope
↓
публикует заказ
↓
Master
↓
изучает structured job scope
↓
отправляет initial offer
↓
при необходимости выполняет ONE justified price increase
↓
объясняет причину в чате
↓
сохраняет price_revision_reason
↓
отправляет final application с Final Agreed Price
↓
Client
↓
выбирает мастера
↓
Safety Gate
↓
если мастер проходит обязательные safety requirements:
- фиксируется master_selected;
если мастер отказывается от обязательных safety requirements:
- заказ возвращается в open;
- фиксируется отказ;
- увеличивается счётчик отказов мастера;
- мастер получает предупреждение;
- после третьего такого случая мастер переводится в suspended до решения администрации.
↓
System
↓
создаёт immutable financial snapshot
↓
фиксирует:
- selected master;
- selected offer/application;
- Final Agreed Price;
- commission base amount;
- deposit_percent / commission_percent;
- payment_method;
- commission_payer.
↓
Payment Method Route
↓
PromptPay QR:
- deposit_created;
- client pays platform deposit;
- deposit_paid после подтверждения оплаты.
↓
Bank Transfer:
- deposit_created;
- client pays platform deposit manually / verified;
- deposit_paid после admin / verified confirmation.
↓
Cash:
- client pays full Final Agreed Price directly to master;
- platform creates commission_obligation_created;
- master owes platform commission;
- after platform receives commission, event commission_collected closes the financial obligation.
↓
TrueMoney / Wallets:
- reserved configurable route for local wallet payments;
- exact runtime route requires separate approval before launch.
↓
Cards:
- reserved for later market rollout;
- runtime/mobile must not expose cards until approved and enabled.
↓
Arrival Coordination
↓
Для PromptPay QR / Bank Transfer / future deposit-to-platform routes:
- arrival coordination starts only after deposit_paid.

Для Cash:
- arrival coordination starts only after commission_obligation_created.

Системное уведомление мастеру для депозитных методов:
"Депозит успешно внесён. Свяжитесь с клиентом в чате и согласуйте время прибытия на объект."

Системное уведомление мастеру для Cash:
"Заказ подтверждён. Свяжитесь с клиентом в чате и согласуйте время прибытия на объект."

System event:
- arrival_coordination_requested.
↓
Work Lifecycle
↓
мастер прибывает на объект
↓
мастер нажимает Start Work
↓
work_started
↓
мастер выполняет работу
↓
мастер загружает evidence photos
↓
evidence_uploaded
↓
клиент проверяет результат
↓
клиент подтверждает завершение работ
↓
completion_confirmed_by_client
↓
только после подтверждения клиента мастеру доступна кнопка Complete Order
↓
мастер нажимает Complete Order
↓
job_completed
↓
Review / Dispute

### Канонические правила

- Entry Price задаётся platform/admin pricing rules.
- Initial job scope формируется через structured questions и required photos.
- Мастер может изменить Entry Price только один раз.
- Price revision должен быть обоснован через structured job scope.
- Chat содержит human explanation.
- Structured fields и job_events содержат business facts.
- Client selection of the master constitutes acceptance of Final Price and selected master.
- master_selected создаётся только после прохождения Safety Gate.
- Financial snapshot становится immutable после фиксации.
- Commission и deposit / commission obligation всегда считаются от Final Agreed Price.
- Deposit не является универсальным обязательным этапом для всех payment methods.
- Cash must not be modelled as client deposit paid to platform.
- Для Cash финансовый цикл не закрывается событием job_completed.
- Для Cash финансовый цикл закрывается только после commission_collected.
- Arrival coordination запускается только после финансовой фиксации маршрута оплаты.
- Для депозитных методов arrival coordination запрещён до deposit_paid.
- Для Cash arrival coordination разрешён после commission_obligation_created.
- Master Complete Order доступен только после completion_confirmed_by_client.
- Chat не является единственным источником юридически значимого lifecycle state.
- job_events остаётся источником бизнес-истории заказа.

----

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
---
## Master Ranking Hybrid Model Contract

Status: APPROVED ✅

### Decision

Helpy uses a hybrid master ranking model.

The model separates:

1. Eligibility
2. Ranking
3. Client Choice

These concepts must not be mixed.

### Eligibility

Eligibility answers:

"Can this master participate in this order?"

Eligibility is a yes/no business decision.

Examples:
- master profile is active;
- master is not blocked;
- master supports the selected category/subcategory;
- category/subcategory is enabled;
- master meets required skill or verification rules if applicable.

Ineligible masters must not be shown as available for the order.

### Ranking

Ranking answers:

"In what order should eligible masters or offers be presented?"

Ranking affects presentation order only.

Ranking must not hide eligible masters.

Ranking must use approved MVP signals:

1. shared_spoken_language
2. work_quality_rating
3. reliability_ratio
4. completed_jobs_count
5. review_count

### Hybrid Model

Helpy does not use pure hard sorting.

Helpy does not use unexplained black-box scoring.

Helpy uses a hybrid model:

- eligibility gates define who may participate;
- approved ranking signals influence ordering;
- signal hierarchy defines conceptual priority;
- final choice remains with the client.

### Signal Application Rule

Ranking signals should improve ordering, not create absolute exclusion.

A master with weaker ranking signals may still be visible if eligible.

A master with no shared spoken language may still be visible and selectable.

A new master must not be hidden only because they have fewer reviews or completed jobs.

### No Hidden Penalty Rule

MVP ranking must not use:
- hidden coefficients;
- hidden penalties;
- temporal weights;
- penalties for new masters;
- platform assumptions not supported by explicit user/client feedback.

### Review Count Rule

review_count is the last ranking signal.

It is a confidence/trust signal, not an independent quality signal.

It may increase confidence in work_quality_rating and reliability_ratio, but must not dominate them.

### Client Choice Rule

Helpy recommends.

Client decides.

Client selection of the master is the official acceptance of Final Price and selected master.

### Admin Rule

Any future change to ranking signals, weights, eligibility rules or visibility rules must be explicitly approved and auditable.

Admin configuration may tune published ranking behavior only after the contract, implementation and audit model support it.

### Business Principle

Helpy should help clients find the best-fit master without artificially limiting marketplace supply.

The platform should improve decision quality while preserving client freedom of choice.
---
## Guidance API Contract

Status: APPROVED ✅

### Purpose

Guidance API delivers structured contextual guidance records to mobile screens.

Mobile applications must not read Markdown documents.

Mobile applications must not hardcode business guidance text.

### Source Of Truth

Guidance API reads published Guidance Records managed through Admin / Guidance Builder.

Guidance content is derived from:
- Client Docs;
- Master Docs;
- Service Playbooks;
- Admin Rules;
- approved category rules;
- approved workflow rules.

### Endpoints

Mobile:

GET /api/v1/guidance

Admin Preview:

GET /api/v1/admin/guidance/preview

### Mobile Request Context

Mobile guidance requests must be able to pass:

- role;
- screen;
- category;
- subcategory;
- scenario_branch;
- form_step;
- question_key;
- photo_step;
- job_status;
- workflow_stage;
- event_type;
- language.

Not every field is required for every screen.

The API must match the most specific published guidance records available.

### Response Shape

Response must use the standard API envelope:

{
  "success": true,
  "data": {
    "items": [
      {
        "id": "...",
        "slot": "before_form_step",
        "role": "client",
        "context": "create_order",
        "title": "...",
        "body": "...",
        "severity": "info",
        "cta": {
          "type": "open_chat",
          "label": "Open chat"
        },
        "dismissible": true
      }
    ]
  }
}

### Empty Response Rule

If no matching guidance exists, API returns:

{
  "success": true,
  "data": {
    "items": []
  }
}

Mobile must keep the screen clean and continue normally.

### Publication Rule

Mobile API returns only Published guidance.

Draft guidance must never be visible to normal users.

Admin Preview API may return Draft guidance for preview and testing.

### Localization Rule

Guidance API returns text in requested language.

Supported launch languages:
- RU;
- EN;
- TH.

If a requested translation is unavailable, API may return configured fallback text, but must not make one language structurally primary.

### CTA Rule

Guidance records may include CTA metadata.

CTA examples:
- open_chat;
- pay_deposit;
- upload_evidence_photos;
- confirm_completion;
- complete_order;
- leave_review;
- open_dispute.

CTA from guidance is presentation only.

Backend business rules remain the source of permission.

### Priority Rule

When multiple records match, API should return records ordered by:
1. exact context match;
2. workflow stage specificity;
3. category/subcategory specificity;
4. form step or event specificity;
5. admin-defined sort order.

### Audit / Governance

Guidance changes must support:
- Draft / Published lifecycle;
- Audit Log;
- Preview;
- RU / EN / TH localization;
- publication without APK rebuild.

### Implementation Rule

Flutter renders guidance records.

Flutter does not own guidance content.

Flutter does not duplicate business rules inside widgets.

### Guidance API Contract Completion Addendum

Status: APPROVED ✅

Purpose:
Close the remaining Guidance API contract gaps before implementation.

This addendum is part of the Guidance API Contract.
It does not create a migration by itself.
It defines the required API and data contract for future implementation.

### Required Guidance Record Identity

Every guidance record returned by API must include:

- id;
- guidance_key;
- version;
- published_at;
- slot;
- role;
- context;
- title;
- body;
- severity;
- dismissible.

Rules:
- `id` is the internal record identifier.
- `guidance_key` is the stable business key used by mobile, admin, analytics and dismiss tracking.
- `version` identifies the published content version.
- `published_at` identifies the exact published revision visible to users.
- Mobile must not treat translated text as identity.
- Mobile must not derive identity from title or body.

### Guidance Key Rule

`guidance_key` must be stable across languages.

Allowed format:
- lowercase;
- snake_case;
- scoped by product area where useful.

Examples:
- create_order_plumbing_faucet_photo_tip;
- offer_review_price_change_warning;
- work_started_evidence_photo_reminder;
- completion_confirm_review_notice.

Changing text must not require changing `guidance_key`.

Changing business meaning should create a new `guidance_key` or increment version according to Admin publishing rules.

### Version Rule

Guidance records must support versioning.

Version is required for:
- audit;
- rollback;
- dismiss behavior;
- analytics;
- Admin Preview comparison.

Mobile must receive the currently published version.

If a dismissed guidance record is republished with a new version, dismiss behavior depends on dismiss scope.

### Published At Rule

`published_at` must be returned for every Published guidance record.

Purpose:
- prove which guidance version was visible at runtime;
- support admin audit;
- support dispute and quality review if guidance behavior is questioned.

Draft records returned by Admin Preview may use `draft_updated_at` instead of `published_at`.

### Severity Rule

Supported severity values for MVP:

- info;
- warning;
- critical.

Meaning:
- `info` is normal contextual help.
- `warning` is risk prevention or important workflow guidance.
- `critical` is reserved for safety, payment, dispute, compliance or irreversible workflow risk.

Rules:
- `critical` guidance must be short and action-oriented.
- `critical` guidance must not be dismissible by default unless explicitly approved.
- Mobile rendering may visually emphasize severity, but business permissions remain backend-owned.
- Severity must not be used as a substitute for backend validation.

### Dismissible Rule

`dismissible` controls whether the user may hide a guidance record from the current UI.

Rules:
- `dismissible = true` means user may hide the record according to its dismiss scope.
- `dismissible = false` means mobile must show the record whenever returned by API.
- Payment, dispute, safety and irreversible workflow guidance should default to `dismissible = false`.
- Routine hints and educational guidance may be dismissible.

### Dismiss Scope Rule

Guidance dismiss behavior must support explicit scope.

Supported dismiss scopes:

- session;
- user;
- job;
- job_stage;
- guidance_version.

Meaning:
- `session`: hidden until app/session refresh.
- `user`: hidden for the user until guidance version changes.
- `job`: hidden only for this job.
- `job_stage`: hidden only for this job and workflow stage.
- `guidance_version`: hidden for this exact guidance_key + version.

Default MVP scope:
- `guidance_version`.

Rules:
- Mobile must not invent dismiss scope.
- API response must include dismiss metadata when dismissible is true.
- Dismissed records must not disappear from Admin Preview.
- Dismiss tracking must not delete the guidance record.

### Slot Return Limit Rule

Guidance API must limit records per slot.

MVP default:
- maximum 1 primary guidance record per slot.

Future reserved:
- API may return up to 3 records per slot only if mobile component supports stacked rendering.

Rules:
- API must order records before returning them.
- Mobile must render records in API order.
- Mobile must not choose the best guidance locally.
- If more records match than the slot limit allows, API decides by priority and sort order.

### Response Shape Addendum

Each item in `data.items` must support:

{
  "id": "...",
  "guidance_key": "...",
  "version": 1,
  "published_at": "...",
  "slot": "...",
  "role": "...",
  "context": "...",
  "title": "...",
  "body": "...",
  "severity": "info",
  "dismissible": true,
  "dismiss_scope": "guidance_version",
  "cta": null,
  "analytics": {
    "impression_event": "guidance_impression",
    "dismiss_event": "guidance_dismissed",
    "cta_event": "guidance_cta_clicked"
  }
}

### Analytics Event Rule

Guidance API contract reserves analytics events.

MVP implementation may log server-side only first.

Required analytics event names:

- guidance_impression;
- guidance_dismissed;
- guidance_cta_clicked.

Required event dimensions:

- guidance_key;
- version;
- role;
- screen;
- slot;
- language;
- category;
- subcategory;
- workflow_stage;
- event_type;
- job_id when available.

Rules:
- Analytics must not contain message text or private chat content.
- Analytics must not become a permission source.
- Analytics must support Admin quality review later.

### API Responsibility Rule

Guidance API is responsible for:
- matching records;
- filtering unpublished records;
- applying actor/context visibility;
- sorting by priority;
- enforcing slot limits;
- returning identity/version/dismiss metadata.

Flutter is responsible only for:
- requesting guidance with context;
- rendering returned records;
- sending dismiss / analytics actions when supported.

Flutter must not:
- hardcode guidance text;
- hardcode business conditions for guidance visibility;
- locally rank guidance records;
- silently generate guidance when API returns empty items.

### Contract Closure Rule

Guidance API Contract is considered Closed for MVP only when it defines:

- identity;
- guidance_key;
- version;
- published_at;
- severity rules;
- dismissible rules;
- dismiss scope;
- slot limits;
- analytics events;
- API/mobile responsibility boundary.

Implementation is still a separate step.
No DB migration should be written from this addendum alone.

## Mobile Guidance Component Contract

Status: APPROVED ✅

### Purpose

Mobile Guidance Component defines how Flutter renders structured guidance records returned by Guidance API.

This contract closes the gap between:
- Guidance API Contract;
- Mobile Guidance Slots Contract;
- Guided Job Flow;
- Flutter screen implementation.

Flutter must render guidance records consistently without owning business guidance content.

### Source Of Truth

Guidance text, severity, dismiss behavior, CTA metadata and record priority come from Guidance API.

Flutter owns only:
- layout;
- visual rendering;
- user interaction dispatch;
- loading and empty-state behavior.

Flutter must not:
- hardcode business guidance text;
- hardcode service rules;
- locally decide which guidance is more important;
- create fallback guidance when API returns no items.

### Component Name

Canonical mobile component name:

`GuidanceCard`

Reserved supporting components:
- `GuidanceSlot`;
- `GuidanceCtaButton`;
- `GuidanceDismissButton`.

Implementation may choose exact Flutter class names later, but architecture must preserve these responsibilities.

### Input Contract

The component receives already matched guidance records from API.

Required item fields:
- id;
- guidance_key;
- version;
- published_at;
- slot;
- role;
- context;
- title;
- body;
- severity;
- dismissible;
- dismiss_scope;
- cta;
- analytics.

The component must not require Markdown parsing.

Body text must be plain localized text for MVP.

### Slot Rendering Rule

A mobile screen renders guidance only inside approved guidance slots.

Rules:
- each slot requests or receives guidance by slot key;
- slot placement is screen-owned;
- record content is API-owned;
- empty slots render nothing;
- empty slots must not leave blank cards, loaders or layout gaps;
- mobile must not show guidance outside declared slots.

### Card Layout Rule

GuidanceCard MVP layout:

- optional severity icon;
- title;
- body;
- optional CTA button;
- optional dismiss action if dismissible is true.

Rules:
- title should be short;
- body should be concise and action-oriented;
- card must not block the main flow unless backend permissions block the action;
- card must not replace form validation, payment validation or backend authorization.

### Severity UI Rule

Supported severity values:
- info;
- warning;
- critical.

Rendering rules:
- info: neutral contextual help;
- warning: visible risk-prevention hint;
- critical: high-attention message for safety, payment, dispute, compliance or irreversible workflow risk.

Rules:
- severity changes presentation only;
- severity must not change backend permissions;
- critical guidance should remain visible when dismissible is false;
- mobile must gracefully render unknown severity as info and report the mismatch when analytics/logging exists.

### CTA Rendering Rule

Guidance CTA is presentation metadata.

Supported MVP CTA types:
- open_chat;
- pay_deposit;
- upload_evidence_photos;
- confirm_completion;
- complete_order;
- leave_review;
- open_dispute.

Rules:
- CTA button may navigate or call an existing screen action;
- CTA must not bypass backend permissions;
- if CTA target is unavailable, card remains visible without crashing;
- mobile may hide unsupported CTA button but must still render guidance text;
- CTA labels come from API/localization contract, not hardcoded business text.

### Dismiss UX Rule

If `dismissible = true`, GuidanceCard may show a dismiss action.

Rules:
- dismiss action must use API-provided `guidance_key`, `version` and `dismiss_scope`;
- mobile must not invent dismiss scope;
- dismissing hides only according to dismiss scope;
- dismissing must not delete local or server guidance content;
- non-dismissible guidance must not show a dismiss action.

MVP may store dismiss locally only if backend dismiss endpoint is not implemented yet.
When backend support exists, dismiss must be sent to API.

### Loading Rule

Guidance loading must not block the main screen.

Rules:
- screen must remain usable while guidance loads;
- no full-screen loader for guidance;
- no screen-level flicker when guidance refreshes;
- stale guidance may remain until fresh response arrives;
- failed guidance request must not block job creation, offer submission, chat, payment or completion.

### Error Rule

Guidance errors are non-fatal for MVP.

Rules:
- user-facing red error banners must not be shown for guidance loading failure;
- technical errors may be logged;
- screen continues normally with no guidance items;
- backend validation errors for the actual business action are separate and may still be shown.

### Analytics Dispatch Rule

Component must reserve hooks for:
- guidance_impression;
- guidance_dismissed;
- guidance_cta_clicked.

Rules:
- impression should fire only when a card is actually rendered;
- dismiss event should include guidance_key, version, slot and dismiss_scope;
- CTA event should include guidance_key, version, slot and cta.type;
- analytics must not include body text, private chat content or uploaded photo content.

### Accessibility / Localization Rule

GuidanceCard must support:
- RU;
- EN;
- TH;
- longer translated text;
- multiline body;
- dynamic text scaling.

Rules:
- card must not assume equal text length across languages;
- Thai text must not be truncated in a way that hides action meaning;
- CTA label must remain readable;
- mobile must not duplicate original guidance text in another language unless API explicitly returns it.

### Reuse Rule

GuidanceCard must be reusable across:
- create order flow;
- offer review;
- payment/deposit;
- chat/work coordination;
- evidence upload;
- completion;
- review;
- dispute prevention;
- master workflow.

Each screen owns placement.
The component owns rendering.
The API owns content and matching.

### No Overlay Rule

Guidance must not be implemented as magic overlays wrapped around screens.

Rules:
- no global surprise popups for normal guidance;
- no screen-covering guidance layer for MVP;
- no blocking modal unless future contract explicitly approves it;
- guidance belongs inside declared slots.

### Mobile Responsibility Boundary

Flutter may:
- request guidance;
- render cards;
- navigate from supported CTA;
- send dismiss and analytics events;
- cache last successful guidance response if needed.

Flutter must not:
- derive lifecycle state from guidance;
- decide business permissions from guidance;
- emit job_events from guidance;
- create or modify guidance records;
- read raw Markdown docs;
- rank competing guidance records locally.

### Done Criteria

Mobile Guidance Component Contract is Closed for MVP when it defines:

- component responsibility;
- input fields;
- slot rendering;
- card layout;
- severity rendering;
- CTA behavior;
- dismiss UX;
- loading behavior;
- error behavior;
- analytics hooks;
- localization/accessibility;
- no-overlay rule;
- Flutter/API responsibility boundary.

Implementation is still a separate step.
No Flutter code should be written from this contract until Mobile Timeline Contract and Guided Job Flow Screen Architecture are also closed.

## Client Identity & Usage Contract

### Client Rules

• Клиентом Helpy может быть только человек, который находится в Таиланде и самостоятельно использует сервис.

• Аккаунт Helpy предназначен для личного использования. Передача аккаунта другим лицам запрещена.

• Клиент лично принимает решения по работам, оформленным через Helpy, включая:
  – создание работ;
  – выбор мастера;
  – принятие решений в процессе выполнения;
  – завершение работы;
  – участие в споре при необходимости.

• При регистрации клиент обязан указать:
  – номер телефона;
  – email.

• Email является основной идентичностью клиента и используется для:
  – входа в аккаунт;
  – Email OTP;
  – восстановления доступа;
  – долгосрочной связи платформы с клиентом.

• Номер телефона является обязательным, но вторичным каналом связи и используется для:
  – связи платформы с клиентом при необходимости;
  – административных процедур;
  – разрешения спорных ситуаций.

• Мастера не видят телефон и email клиентов.
• Клиенты не видят телефон и email мастеров.

• Взаимодействие между клиентом и мастером осуществляется только через встроенный чат Helpy.

### Registration Confirmation

При завершении регистрации клиент подтверждает, что:

• находится в Таиланде;
• лично принимает решения по работам, оформленным через Helpy;
• не передаёт свой аккаунт другим лицам.

### Registration Flow

1. Phone *
2. Email *
3. Email OTP
4. Display Name *
5. Подтверждение условий
6. Активировать аккаунт

### Not Used

• SMS OTP;
• обязательная GPS-проверка;
• обязательная проверка IP;
• отображение клиенту термина Guided Job Flow;
• передача контактов между клиентом и мастером;
• использование одного аккаунта несколькими людьми.
