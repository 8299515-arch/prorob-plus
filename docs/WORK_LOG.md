# Прораб+ — Work Log

## 2026-08-22

### Release / Google Play preparation
- Создан и ведётся production-ветка `release/google-play-ready`.
- Добавлены production-oriented модули: Finance, CRM, Documents, Account.
- Добавлены маршруты `/finance`, `/crm`, `/documents`, `/account` и project-specific document/finance/task routes.
- Добавлены Android release checks и AAB build в CI.
- CI signing отделён от production keystore.
- API endpoint вынесен в `API_BASE_URL`.
- Token storage оставлен в secure storage.
- Добавлена Privacy Policy.
- Добавлено удаление аккаунта на клиенте с API contract `DELETE /account`.
- Добавлен regression test для задач.
- Выполнена проверка Android Manifest, Gradle, dependencies и network layer.

### Важные решения
- Не хранить production signing keys в GitHub.
- Не создавать фиктивный backend только ради прохождения UI.
- Не объявлять проект Google Play-ready без фактической успешной release AAB сборки.
- Все завершённые этапы фиксировать отдельным commit и обновлением `docs/RELEASE_TRACKER.md`.

### Открытые задачи
- Подтвердить реальный backend и API contracts.
- Реализовать/подтвердить серверное удаление аккаунта.
- Получить фактический CI run и исправить его ошибки.
- Завершить offline/network handling.
- Финальный Play Console compliance audit.
- Production signing и финальная AAB.
