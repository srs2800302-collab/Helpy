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

### Plumbing → Проточный водонагреватель

Registry Status: ✅ STORED + DOCS

Scenarios:
- Плохо греет воду
- Водонагреватель протекает
- Выбивает автомат / отключается электричество
- Замена водонагревателя
- Установка водонагревателя

Questions:

Плохо греет воду:
- Горит индикатор питания?
  - Да
  - Нет
- Раньше вода была горячее?
  - Да
  - Нет

Водонагреватель протекает:
- Откуда течет вода?
  - Из-под корпуса
  - Из заливного шланга
  - Из шланга лейки
- Водонагреватель продолжает работать?
  - Да
  - Нет
  - Пробивает током
- Опишите проблему своими словами — обязательно

Выбивает автомат / отключается электричество:
- Когда выбивает автомат / отключается электричество?
  - Сразу после включения
  - Во время работы
  - При увеличении температуры
- Раньше водонагреватель работал нормально?
  - Да
  - Нет

Замена водонагревателя:
- Новый водонагреватель уже куплен?
  - Да
  - Нет

Установка водонагревателя:
- Новый водонагреватель уже куплен?
  - Да
  - Нет

Required Photos:
- общий вид водонагревателя
- фото водонагревателя с другого ракурса
- описание проблемы клиентом

Not Required Photos:
- фото шильдика
- фото автомата
- фото проводки

Client Docs:
- Если клиент не понимает точную причину неисправности, он может использовать глобальную услугу диагностики.
- Фото должны быть безопасными для клиента.
- Платформа не требует фото, которые могут потребовать демонтаж или работу с электричеством.

Master Docs:
- Для рынка Паттайи ремонт большинства бытовых проточных водонагревателей обычно экономически нецелесообразен.
- Во многих случаях после диагностики клиенту рекомендуется замена оборудования.
- При признаках протечки из корпуса или удара током мастер должен рассматривать заказ как потенциально опасный.
- Перед рекомендацией замены мастер должен учитывать фото оборудования, подключение, мощность и состояние объекта.

Service Playbook:
- Протечка из шланга обычно решается заменой шланга, уплотнений или подтяжкой соединений.
- Протечка из корпуса является сценарием повышенного риска и часто ведет к диагностике или замене.
- Если отключение электричества связано с водонагревателем, причина может быть не только в оборудовании, но и в электрической линии объекта.
- Не создавать отдельные сценарии, если проблема уже покрыта существующим сценарием.
- Водонагреватель является относительно простым бытовым оборудованием, поэтому форма не должна перегружать клиента.

Pricing:
- Плохо греет воду — от 500 ฿
- Водонагреватель протекает — от 650 ฿
- Выбивает автомат / отключается электричество — от 650 ฿
- Замена водонагревателя — от 1 500 ฿
- Установка водонагревателя — от 1 200 ฿

Business Rules:
- Замена водонагревателя = демонтаж старого + установка нового.
- Установка водонагревателя = монтаж нового без демонтажа старого.
- Если старый водонагреватель уже демонтирован, заказ относится к установке.
- Отдельная диагностика водонагревателя не используется; применяется глобальная услуга диагностики.
- Ремонт не является приоритетным сценарием, если замена экономически разумнее.
- Не требовать от клиента небезопасных фотографий.

Admin Panel:
- Администратор может изменять стартовые цены.
- Администратор может включать/отключать сценарии.
- Администратор может управлять глобальной услугой диагностики.
- Цены и бизнес-правила не должны быть захардкожены.

GAP:
- Нет. Подкатегория завершена.



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

## Global GAP → Reviews & Reputation System

Status: 🟨 STORED PARTIALLY

Problem:
- Simple star rating is not enough for Helpy master reputation.
- A 1–5 rating alone does not give clients enough useful information.
- Early ratings can distort a new master's reputation.
- Some clients rate automatically.
- Some clients do not leave reviews.
- One negative review can unfairly damage a new master.
- Pattaya clients need reputation signals based on experience, reliability, and communication.

Approved Direction:
- Master reputation must not be based only on star rating.

Master Profile Reputation Should Include:
- Average client rating.
- Completed orders count.
- Success rate.
- Refusals after accepting an order.
- Languages available for communication.

Review Flow:
- Review form opens after completed order flow.
- Client can leave a star rating from 1 to 5.
- Client can leave an optional text comment.

Structured Review GAP:
- Structured review options require a separate audit.

Candidates for structured feedback:
- Work quality.
- Politeness.
- Punctuality.
- Cleanliness after work.
- Price matched the agreed final price.

Additional Metrics GAP:
- Repeat clients.
- Average response time.
- On-time arrival.
- Other trust metrics require a separate audit.

Admin / Analytics Notes:
- Reviews and reputation should support client decision-making.
- Reviews and reputation should support master quality control.
- Reviews and reputation should support platform analytics.
- Reviews and reputation should help detect weak points in service quality.

GAP:
- Final review form architecture.
- Reputation metric formulas.
- Master profile UI.
- Admin moderation rules.
- Anti-abuse rules.
- Rating display thresholds.
- Handling new masters with few orders.
