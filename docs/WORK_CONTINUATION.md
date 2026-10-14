# Прораб+ — контрольная точка продолжения

Дата: 2026-10-14
Ветка: `release/google-play-ready`

## Последняя зафиксированная точка

Локально проверено на Android-телефоне: `flutter run -d VSGEFY8DEQFIKZM7` собрал debug APK, установил его и запустил приложение.

## Что уже сделано

- Flutter CI проходит.
- Dart Format проходит.
- `flutter analyze --fatal-infos` проходит.
- Тесты проходят: 2/2.
- Java 17 настроена.
- Android SDK/API 36 и Build Tools 36 установлены в CI.
- `android/local.properties` создаётся до Android/Gradle действий.
- Gradle 8.14.5 используется для текущего CI.
- Kotlin Gradle Plugin обновлён до 2.2.20.
- Android Gradle Plugin обновлён до 8.13.2.
- CI signing создаёт временный release keystore.
- Gradle Wrapper генерируется в чистом временном Gradle-проекте.
- Реальный `flutter build appbundle --release` уже запускается.
- Исправлена Android resource theme, которая блокировала AAB.
- Локальная сборка на Flutter 3.24 требует NDK 27 и Java/Kotlin target 17.
- Debug-сборка работает без production keystore; отсутствие `android/key.properties` блокирует только release-сборки.
- Стандартный Gradle Wrapper 8.14.5 сохранён в репозитории и используется локально и в CI.
- `pubspec.lock` включён в Git для воспроизводимого разрешения зависимостей.

## Последний блокер и исправление

Release Check дошёл до `Build Android release`, но Android resource compiler не находил `android:style/Theme.Light.NoActionBar`. В `android/app/src/main/res/values/styles.xml` обе темы переведены на `android:style/Theme.Material.Light.NoActionBar`.

## Следующий шаг

Проверить новый Release Check после публикации исправлений в `release/google-play-ready`.

Порядок проверки:

1. Dependencies
2. Format
3. Analyze
4. Tests
5. CI signing
6. `flutter build appbundle --release`
7. Проверка полученного AAB и Google Play readiness

## Правило продолжения

Не начинать работу заново. Использовать этот файл как контрольную точку. После каждого фактического исправления создавать commit и обновлять этот файл новой контрольной точкой.
