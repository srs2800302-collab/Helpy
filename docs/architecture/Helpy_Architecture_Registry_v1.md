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

