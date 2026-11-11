; Экспертная система "Выбор технологии для веб-проекта"
; Оболочка: CLIPS 6.4

; Факты: ответы пользователя
(deftemplate answers
  (slot project  (type SYMBOL))   ; landing | corporate | shop | service | portal
  (slot budget   (type SYMBOL))   ; low | mid | high
  (slot deadline (type SYMBOL))   ; fast | normal | long
  (slot admin    (type SYMBOL))   ; yes | no
  (slot load     (type SYMBOL))   ; low | mid | high
  (slot skills   (type SYMBOL)))  ; php | js | python | none

; Промежуточный факт: тип решения
(deftemplate platform (slot name (type SYMBOL)))   ; static | cms | framework

; Результаты и объяснение
(deftemplate rec (slot kind (type STRING)) (slot text (type STRING)))
(deftemplate why (slot n (type INTEGER)) (slot id (type SYMBOL)) (slot text (type STRING)))

; УРОВЕНЬ 1: тип решения (R1-R7)
(defrule R1 (answers (project landing) (admin no)) =>
  (assert (platform (name static)))
  (assert (why (n 1) (id R1) (text "Лендинг, контент править не нужно -> статический сайт: без БД и CMS, дёшево и быстро."))))

(defrule R2 (answers (project landing) (admin yes)) =>
  (assert (platform (name cms)))
  (assert (why (n 2) (id R2) (text "Лендинг, но контент правит нетехнический специалист -> нужна CMS с админкой."))))

(defrule R3 (answers (project corporate)) =>
  (assert (platform (name cms)))
  (assert (why (n 1) (id R3) (text "Корпоративный сайт - типовые страницы и новости -> CMS закрывает задачу без заказного кода."))))

(defrule R4 (answers (project shop) (budget low)) =>
  (assert (platform (name cms)))
  (assert (why (n 1) (id R4) (text "Магазин при низком бюджете -> готовое e-commerce решение на CMS, а не разработка с нуля."))))

(defrule R5 (answers (project shop) (budget ?b&~low)) =>
  (assert (platform (name framework)))
  (assert (why (n 1) (id R5) (text "Магазин со средним/высоким бюджетом -> заказная разработка: интеграции (оплата, 1С, склад) и нестандартная логика."))))

(defrule R6 (answers (project service)) =>
  (assert (platform (name framework)))
  (assert (why (n 1) (id R6) (text "Веб-сервис/SaaS - уникальная бизнес-логика и API -> нужен фреймворк."))))

(defrule R7 (answers (project portal)) =>
  (assert (platform (name framework)))
  (assert (why (n 1) (id R7) (text "Портал университета: роли, личные кабинеты, интеграции с ИС -> фреймворк."))))

; УРОВЕНЬ 2: стек (R8-R14)
(defrule R8 (platform (name static)) =>
  (assert (rec (kind "Стек") (text "HTML/CSS/JS или генератор Hugo + готовый шаблон.")))
  (assert (why (n 2) (id R8) (text "Статическое решение -> вёрстка или генератор статики, серверный код не нужен."))))

(defrule R9 (platform (name cms)) (answers (skills python)) =>
  (assert (rec (kind "Стек") (text "Wagtail (Django) + PostgreSQL.")))
  (assert (why (n 2) (id R9) (text "Нужна CMS и команда знает Python -> CMS на Django, а не на PHP."))))

(defrule R10 (platform (name cms)) (answers (skills ~python)) =>
  (assert (rec (kind "Стек") (text "WordPress + MySQL: готовая тема и плагины (WooCommerce для магазина).")))
  (assert (why (n 2) (id R10) (text "Нужна CMS, Python в команде нет -> WordPress: минимум кода, максимум готовых плагинов."))))

(defrule R11 (platform (name framework)) (answers (skills php)) =>
  (assert (rec (kind "Стек") (text "Laravel (PHP) + MySQL + Blade/Vue.")))
  (assert (why (n 2) (id R11) (text "Заказная разработка + PHP -> Laravel: CRUD, авторизация и админка из коробки."))))

(defrule R12 (platform (name framework)) (answers (skills js)) =>
  (assert (rec (kind "Стек") (text "Node.js (NestJS/Express) + React + PostgreSQL.")))
  (assert (why (n 2) (id R12) (text "Заказная разработка + JavaScript -> один язык на клиенте и сервере."))))

(defrule R13 (platform (name framework)) (answers (skills python)) =>
  (assert (rec (kind "Стек") (text "Django + DRF + PostgreSQL.")))
  (assert (why (n 2) (id R13) (text "Заказная разработка + Python -> Django: ORM, админка, авторизация из коробки."))))

(defrule R14 (platform (name framework)) (answers (skills none)) =>
  (assert (rec (kind "Стек") (text "Разработчиков нет: MVP на no-code (Tilda/Bubble) либо передача разработки подрядчику.")))
  (assert (why (n 2) (id R14) (text "Задача требует кода, а команды нет -> no-code для MVP или подрядчик."))))

; УРОВЕНЬ 3: хостинг (R15-R18)
(defrule R15 (platform (name static)) (answers (load ~high)) =>
  (assert (rec (kind "Хостинг и инфраструктура") (text "GitHub Pages / Netlify - бесплатный хостинг статики.")))
  (assert (why (n 3) (id R15) (text "Статика и небольшая нагрузка -> бесплатный статический хостинг."))))

(defrule R16 (platform (name cms)) (answers (load ~high)) =>
  (assert (rec (kind "Хостинг и инфраструктура") (text "Обычный shared-хостинг с PHP и MySQL.")))
  (assert (why (n 3) (id R16) (text "CMS и умеренная нагрузка -> дешёвый виртуальный хостинг."))))

(defrule R17 (answers (load high)) =>
  (assert (rec (kind "Хостинг и инфраструктура") (text "Более 10 000 посетителей/сутки: VPS/облако + Nginx, кэш Redis, CDN, бэкапы.")))
  (assert (why (n 3) (id R17) (text "Высокая нагрузка -> отдельный сервер, кэширование и CDN."))))

(defrule R18 (platform (name framework)) (answers (load ~high)) =>
  (assert (rec (kind "Хостинг и инфраструктура") (text "Небольшой VPS (Docker) или PaaS (Render/Railway); для no-code - хостинг платформы.")))
  (assert (why (n 3) (id R18) (text "Приложению нужен сервер приложений -> VPS или PaaS."))))

; УРОВЕНЬ 4: предупреждения (R19-R20)
(defrule R19 (platform (name framework)) (answers (budget low)) =>
  (assert (rec (kind "Предупреждение") (text "Бюджет мал для заказной разработки: урезать объём до MVP, использовать open-source и бесплатные тарифы.")))
  (assert (why (n 4) (id R19) (text "Конфликт 'заказная разработка + низкий бюджет' -> ограничение объёма работ."))))

(defrule R20 (platform (name framework)) (answers (deadline fast)) =>
  (assert (rec (kind "Предупреждение") (text "Срок до 2 недель: только MVP на готовых библиотеках и шаблонах, остальное - во второй релиз.")))
  (assert (why (n 4) (id R20) (text "Конфликт 'заказная разработка + жёсткий срок' -> поэтапная сдача."))))