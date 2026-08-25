# Прораб+ — контрольная точка продолжения

Дата: 2026-08-22
Ветка: `release/google-play-ready`

## Последняя зафиксированная точка

Commit: `30170d7a5506c91949f5d5b2f2cb03b275ab00fd`

Исправлена Android launch theme: `Theme.Light.NoActionBar` заменена на доступную Material-тему `Theme.Material.Light.NoActionBar` для прохождения release AAB resource compilation.

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

## Последний блокер и исправление

Release Check дошёл до `Build Android release`, но Android resource compiler не находил `android:style/Theme.Light.NoActionBar`. В `android/app/src/main/res/values/styles.xml` обе темы переведены на `android:style/Theme.Material.Light.NoActionBar`.

## Следующий шаг

Проверить новый Release Check для commit `30170d7a5506c91949f5d5b2f2cb03b275ab00fd`.

Порядок проверки:

1. Generate Gradle wrapper
2. Dependencies
3. Format
4. Analyze
5. Tests
6. CI signing
7. `flutter build appbundle --release`
8. Проверка полученного AAB и Google Play readiness

## Правило продолжения

Не начинать работу заново. Использовать этот файл как контрольную точку. После каждого фактического исправления создавать commit и обновлять этот файл новой контрольной точкой.
