# Архитектура CHOOZ

## Обзор

Репозиторий состоит из двух основных частей:

- `backend/` — Django backend с единым GraphQL API;
- `mobile/Chooz/` — iOS-клиент на SwiftUI, UIKit и Tuist.

По архитектурному смыслу это продуктовый монолит с отдельным мобильным клиентом. Backend и iOS развиваются в одном репозитории и синхронизируются через GraphQL-контракт.

## Backend

### Общая схема

Backend построен как Django-проект `config` с одним основным приложением `api`.

Точки входа:

- `/health/` — healthcheck;
- `/admin/` — Django admin;
- `/api/graphql/` — основной GraphQL endpoint.

Маршрут `/api/graphql/` обслуживает кастомный `AuthGraphQLView`, который пытается поднять пользователя из JWT перед обработкой запроса. Это означает, что для клиента весь основной backend-сценарий сконцентрирован в одном GraphQL endpoint, а контекст пользователя пробрасывается прямо в резолверы.

### Слои backend

#### 1. Конфигурация проекта

- `backend/config/settings.py` — базовые настройки Django, БД, middleware и интеграций;
- `backend/config/settings_test.py` — отдельные настройки для тестов;
- `backend/config/urls.py` — корневые URL;
- `backend/config/asgi.py` и `backend/config/wsgi.py` — точки запуска.

#### 2. Доменные модели

Основные доменные сущности сейчас сосредоточены в `backend/api/models.py`:

- `AppleAccount` и `YandexAccount` — привязки пользователя к внешним провайдерам авторизации;
- `WishItem` — элементы личного вишлиста с ценой, валютой, ссылкой, изображением и опциональной связью с элементом подборки;
- `Event` — события календаря с флагами напоминания и ежегодного повтора;
- `Collection` — подборка подарков;
- `CollectionItem` — отдельный элемент подборки.

Связь `WishItem -> CollectionItem` показывает важный архитектурный сдвиг: подборки уже не изолированный read-only-контент, а часть сценария добавления подарков в личный вишлист.

#### 3. API-слой

GraphQL-схема собирается в `backend/api/graphql/schema.py` из отдельных доменных модулей:

- `auth`;
- `wish_items`;
- `events`;
- `collections`.

Внутри каждого доменного модуля логика разделена на три уровня:

- `queries.py` — GraphQL queries;
- `mutations.py` — GraphQL mutations;
- `service.py` — прикладная логика и преобразование моделей в GraphQL-типы.

Это оставляет transport-слой тонким и удерживает бизнес-логику рядом с конкретным доменом.

#### 4. Аутентификация и сессии

Backend опирается на `djangorestframework-simplejwt` и поддерживает:

- вход через Apple;
- вход через Яндекс;
- refresh access token;
- удаление собственного аккаунта.

На backend сейчас нет опубликованной GraphQL-мутации `loginWithGoogle`, поэтому рабочий серверный auth-контракт ограничен Apple и Яндексом.

#### 5. Работа с файлами

Для изображений вишлиста используется S3-совместимое хранилище через `backend/api/storage/minio.py`.

Сценарий выглядит так:

1. клиент запрашивает presigned upload URL;
2. загружает файл напрямую в объектное хранилище;
3. вызывает отдельную мутацию привязки ключа к `WishItem`.

На стороне модели хранится `image_key`, а наружу GraphQL отдаёт готовый `imageUrl`.

#### 6. Подборки

Домен `collections` уже оформлен как отдельный backend-срез:

- есть `collectionsHome` для выдачи секций подборок;
- есть `collection(slug: ...)` для детального экрана подборки;
- есть мутации добавления и удаления элемента подборки из вишлиста;
- порядок секций фиксирован через enum `Collection.Section`;
- в миграциях и тестах уже присутствуют seed-данные для подборок.

Это сейчас самый явный backend-след второй версии продукта.

#### 7. Тесты

Тесты разделены на:

- `backend/api/tests/unit/` — unit-тесты сервисов, middleware и доменной логики;
- `backend/api/tests/integration/` — интеграционные тесты GraphQL API.

Покрываются auth, wishlist, events и collections.

### Архитектурные особенности backend

- Backend остаётся одним Django app без разбиения на несколько приложений по bounded context.
- Основной внешний контракт — GraphQL, а не REST.
- Домены уже выделены по папкам, даже если физически живут в одном приложении.
- Подборки встроены в существующий сценарий вишлиста, а не развиваются как отдельный subsystem.

## iOS

### Общая схема

iOS-приложение собирается через Tuist и использует смешанную архитектуру:

- SwiftUI — для экранов и большей части интерфейса;
- UIKit — для root-навигации, таббара, контейнеров и lifecycle-интеграции.

### Composition Root

Главная точка сборки зависимостей — `mobile/Chooz/Chooz/Sources/Application/AppContainer.swift`.

В `AppContainer` создаются:

- `ApolloClient` и цепочка сетевых interceptor-ов;
- сервисы домена и инфраструктуры;
- фабрики экранов;
- shared-state зависимости вроде `TokenStorage`, `UserDefaultsService`, `ToastManager`, `AnalyticsService`.

Запуск приложения начинается через `AppBootstraper`, который:

- чистит keychain при первом запуске после установки;
- настраивает кеш изображений;
- отправляет lifecycle-аналитику;
- показывает splash;
- выбирает маршрут в onboarding, авторизацию или основную часть приложения;
- валидирует сессию и при необходимости разлогинивает пользователя.

### Навигация

Навигация централизована в `AppRouter`:

- root построен на `UINavigationController`;
- основная пользовательская зона инкапсулирована в `MainTabBarController`;
- роутер умеет `setRoot`, `push`, `pop`, `present`;
- активный navigation stack переключается между корневым стеком и текущим табом.

Отдельно есть `DeepLinkService`, который обрабатывает deep link `chooz://profile/:userId` и открывает social profile.

### Структура экранных модулей

Экранные модули в основном следуют одному и тому же паттерну:

- `Factory` — собирает зависимости и экран;
- `Router` — описывает навигацию внутри модуля;
- `Interactor` — инкапсулирует прикладные действия;
- `ViewModel` — держит состояние и side effects UI;
- `View` — SwiftUI-представление.

Этот паттерн хорошо виден на модулях:

- `Authorization`;
- `Calendar`;
- `Onboarding`;
- `Profile`;
- `Settings`;
- `SocialProfile`.

### Сетевой слой

Клиентский networking построен на Apollo GraphQL.

Ключевые элементы:

- `AppContainer` создаёт основной `ApolloClient` и отдельный `refreshClient`;
- `AuthInterceptorProvider` собирает цепочку interceptor-ов;
- `AuthorizationInterceptor` подставляет access token;
- `TokenRefreshInterceptor` обновляет токены и сообщает о протухшей сессии;
- GraphQL-операции лежат в `mobile/Chooz/Chooz/Sources/GraphQL/operations/`;
- сгенерированный код лежит в `mobile/Chooz/Chooz/Sources/GraphQL/Generated/`.

### Прикладные сервисы

В отдельные сервисы вынесены основные domain и cross-cutting зависимости:

- `WishlistService`;
- `CalendarService`;
- `ProfileService`;
- `SessionService`;
- `NotificationService`;
- `AnalyticsService`;
- `DeepLinkService`;
- `AppleAuthService`;
- `YandexAuthService`;
- `GoogleAuthService`.

При этом важно различать уровень готовности:

- инфраструктура под Google Sign-In в клиенте есть;
- экран авторизации сейчас показывает вход через Apple и Яндекс;
- backend-контракт на данный момент тоже опирается именно на Apple и Яндекс.

### Пользовательские сценарии, уже закреплённые в архитектуре

Текущая клиентская архитектура уже обслуживает несколько устойчивых сценариев:

- onboarding;
- авторизация;
- личный вишлист с загрузкой изображений;
- календарь событий с локальными уведомлениями и ежегодным повтором;
- профиль и настройки;
- удаление аккаунта;
- просмотр чужого вишлиста через social profile.

### Текущее состояние архитектуры

- Core-сценарии мобильного приложения уже собраны и изолированы по сервисам и модулям.
- Backend ушёл дальше MVP и уже содержит отдельный домен подборок.
- Основное асинхронное расхождение между слоями сейчас в том, что backend-подборки уже оформлены, а основной iOS UI ещё сосредоточен на wishlist/calendar/profile flow.
