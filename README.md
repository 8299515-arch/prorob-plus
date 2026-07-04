# Прораб+ (Prorab+)

## 🚧 Product Vision
Прораб+ — это мобильное и веб-приложение уровня Google Play / App Store для управления строительством и ремонтами.

Это не шаблон и не TODO-лист. Это цифровая операционная система ремонта: от сметы до сдачи объекта.

---

## 🧠 Что делает продукт реальным (а не учебным)

Прораб+ объединяет:
- управление строительными проектами
- CRM для клиентов
- контроль бригад и исполнителей
- финансовый учет ремонта
- документооборот объекта

---

## 🏗️ Архитектура уровня production

### 📱 Frontend (Flutter)
- Clean Architecture (Domain / Data / Presentation)
- Feature-first modular structure
- BLoC / Cubit state management
- Offline-first (SQLite / Hive)
- Secure API layer (Dio + interceptors)
- Responsive UI (mobile + tablet + web)

### 🧠 Backend (scalable)
- REST API (FastAPI или Node.js)
- PostgreSQL (основная БД)
- Redis (кэш, сессии, очереди)
- Object storage (S3-compatible)

### ☁️ DevOps
- GitHub Actions CI/CD
- Docker контейнеризация
- Staging / Production environments
- Monitoring + logging (Sentry / Prometheus)

---

## 📦 Core Modules (MVP → Product)

### 1. Projects
- создание объектов
- этапы работ
- статус и прогресс

### 2. Tasks
- задачи мастерам
- дедлайны
- чек-листы
- контроль выполнения

### 3. Finance
- сметы
- расходы
- прибыль проекта
- отчеты

### 4. CRM
- клиенты
- история коммуникаций
- документы

### 5. Team Management
- роли (прораб / мастер / клиент / админ)
- права доступа

---

## 🧩 Data Model
- User
- Project
- Task
- FinanceEntry
- Client
- TeamMember

---

## 🚀 Sprint 1 (следующий шаг)
- Flutter project initialization (clean architecture setup)
- Auth module (JWT + refresh tokens)
- Projects CRUD
- Basic dashboard UI

---

## 🧭 Принципы продукта
- offline-first
- быстрые действия вместо сложных меню
- минимум кликов до результата
- адаптация под реальные стройки

---

## 📌 Статус
Архитектурный каркас обновлён до production-level. Дальше — построение модулей как реального продукта, а не шаблона.