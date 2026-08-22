# Прораб+ — Release Tracker

## Назначение
Единый журнал состояния production-разработки. После каждого значимого этапа обновлять этот файл отдельным commit.

## Текущая ветка
`release/google-play-ready`

## Последний зафиксированный этап
2026-08-22 — CI maintenance: setup-java v5

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
- `ProjectRepository` и `TaskRepository` преобразуют Dio/network errors в типизированные `ApiFailure`.
- `FinanceRepository` преобразует Dio/network errors в типизированные `ApiFailure`.
- Android release version увеличен с `1.0.0+1` до `1.0.0+2`.
- Добавлена явная зависимость `connectivity_plus`.
- Android `compileSdk` и `targetSdk` зафиксированы на API 36.
- CI теперь устанавливает Android SDK Platform 36 и Build Tools 36.0.0.
- Добавлен контролируемый Gradle launcher для Linux CI и Windows.
- Gradle distribution для launcher зафиксирован на 8.7.
- Исправлено форматирование network/API infrastructure файлов после реального CI failure на `dart format`.
- GitHub Actions `actions/setup-java` обновлён с v4 до v5.

## Подтвержденные ограничения / блокеры
1. Backend в этом репозитории не обнаружен.
2. Реализация `DELETE /account` на сервере не подтверждена.
3. После format remediation требуется новый фактический workflow run; зелёный CI пока не подтверждён.
4. Privacy Policy требует реального публичного URL и контакт службы поддержки перед публикацией.
5. Production signing keystore должен быть создан/сохранён владельцем проекта вне Git.
6. Offline cache данных пока не реализован; offline UI показывает состояние сети, но не заменяет локальную синхронизацию.
7. CRM/Documents repositories ещё нужно проверить и перевести на единый failure mapping, если они содержат прямые Dio calls.
8. Gradle launcher проверяет/загружает Gradle 8.7 самостоятельно; полноценный стандартный Gradle Wrapper JAR пока не добавлен.

## Следующий этап
1. Получить фактический GitHub Actions run после format remediation.
2. Исправить реальные analyze/test/build ошибки, если CI их обнаружит.
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
