# Прораб+ — Release Tracker

## Назначение
Единый журнал состояния production-разработки. После каждого значимого этапа обновлять этот файл отдельным commit.

## Текущая ветка
`release/google-play-ready`

## Последний зафиксированный этап
2026-08-22 — Android release versioning audit

### Реализовано
- Проекты и задачи подключены к приложению.
- Финансы: доходы, расходы, баланс, операции и маршруты.
- CRM: клиенты, подрядчики, сотрудники, создание/удаление и фильтрация.
- Документы: список, фильтрация по проекту, открытие, удаление, multipart upload API.
- Аккаунт: настройки и клиентский flow удаления аккаунта через `DELETE /account`.
- Secure storage для токена авторизации.
- API base URL через `API_BASE_URL` с production fallback.
- Android release configuration и CI workflow для `analyze`, `test`, `build appbundle --release`.
- CI использует временный signing key; production keystore не хранится в Git.
- Privacy Policy добавлена в репозиторий.
- Regression test для domain-модели задачи.
- Централизованный `NetworkStatus` для определения online/offline состояния и отслеживания восстановления соединения.
- Глобальный offline banner подключён на уровне `MaterialApp`.
- Централизованное преобразование Dio errors в пользовательские `NetworkFailure`, `UnauthorizedFailure`, `ServerFailure`, `RequestFailure`.
- Типизированная граница `ApiResult<T>` / `ApiSuccess<T>` / `ApiError<T>` для безопасной передачи результата между data/domain и UI.
- `ProjectRepository` и `TaskRepository` теперь преобразуют Dio/network errors в типизированные `ApiFailure` вместо передачи сырых Dio exceptions выше data-layer.
- `FinanceRepository` теперь также преобразует Dio/network errors в типизированные `ApiFailure`.
- Android release version увеличен с `1.0.0+1` до `1.0.0+2`.
- Добавлена явная зависимость `connectivity_plus`, необходимая для `NetworkStatus`.

## Подтвержденные ограничения / блокеры
1. Backend в этом репозитории не обнаружен.
2. Реализация `DELETE /account` на сервере не подтверждена.
3. Последний workflow должен быть фактически запущен и проверен; наличие YAML само по себе не означает успешный AAB.
4. Privacy Policy требует реального публичного URL и контакт службы поддержки перед публикацией.
5. Production signing keystore должен быть создан/сохранён владельцем проекта вне Git.
6. Offline cache данных пока не реализован; offline UI показывает состояние сети, но не заменяет локальную синхронизацию.
7. CRM/Documents repositories ещё нужно проверить и перевести на единый failure mapping, если они содержат прямые Dio calls.

## Следующий этап
1. Запустить/проверить фактический GitHub Actions workflow для commit `1c60fbd141853b09558344eac0d7f1b0e55eb910`.
2. Исправить реальные compile/analyze/test ошибки, если CI их обнаружит.
3. Проверить CRM/Documents/Account repositories.
4. Проверить API contracts и backend.
5. Выполнить Android/Google Play pre-release audit.
6. Собрать подписанный production AAB.

## Правило фиксации
Каждый завершённый этап должен:
- быть отражён в этом файле;
- иметь отдельный Git commit;
- содержать краткое описание реализованного;
- содержать явно отмеченные блокеры, если они есть.
