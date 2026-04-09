# Архитектура CHOOZ

## Обзор

Репозиторий состоит из двух основных частей:

- `backend/` — backend на Django с GraphQL API;
- `mobile/Chooz/` — iOS-приложение на SwiftUI и Tuist.

На текущем этапе проект представляет собой продуктовый монолит с отдельным мобильным клиентом.

## Backend

### Общая схема

Backend построен как Django-проект `config` с одним основным приложением `api`.

Точки входа:

- `/health/` — healthcheck;
- `/admin/` — Django admin;
- `/api/graphql/` — основной GraphQL endpoint.

### Слои backend

#### 1. Конфигурация проекта

- `backend/config/settings.py` — настройки Django, БД, middleware и окружения;
- `backend/config/urls.py` — корневые маршруты;
- `backend/config/asgi.py` и `backend/config/wsgi.py` — entrypoints для запуска.

#### 2. Доменные модели

Ключевые модели сейчас находятся в `backend/api/models.py`:

- `AppleAccount` и `YandexAccount` — связи пользователя с внешними провайдерами авторизации;
- `WishItem` — элементы вишлиста;
- `Event` — события календаря.

#### 3. API-слой

GraphQL-схема собирается в `backend/api/graphql/schema.py` из отдельных модулей:

- `auth`;
- `wish_items`;
- `events`.

Внутри каждого доменного модуля логика разделена на:

- `queries.py` — GraphQL queries;
- `mutations.py` — GraphQL mutations;
- `service.py` — прикладные helper/service-функции.

Это даёт простую модульную структуру: transport и schema-описание лежат рядом с прикладной логикой по домену.

#### 4. Аутентификация

Запросы приходят через кастомный `AuthGraphQLView` в `backend/api/urls.py`.

Аутентификация опирается на:

- `djangorestframework-simplejwt`;
- `backend/api/middleware.py`;
- доменные auth-модули для внешних провайдеров, сейчас это Яндекс и Apple ID.

С точки зрения клиента backend сейчас предоставляет единый GraphQL endpoint, а пользовательский контекст пробрасывается в resolvers через JWT.

#### 5. Работа с файлами

Для файлов и изображений используется S3-совместимое хранилище через MinIO:

- `backend/api/storage/minio.py`.

Для `WishItem` backend хранит ключ объекта, а наружу отдаёт presigned URL.

#### 6. Тесты

Тесты разделены на:

- `backend/api/tests/unit/` — unit-тесты сервисного слоя и middleware;
- `backend/api/tests/integration/` — интеграционные тесты GraphQL API.

### Архитектурные особенности backend

- Backend сейчас организован как один Django app без выделения на несколько приложений по bounded context.
- Основной публичный интерфейс — GraphQL.
- Доменные модули уже отделены по функциональности, что упрощает дальнейшее расширение под v2.

## iOS

### Общая схема

iOS-приложение собирается через Tuist и использует смешанную архитектуру:

- SwiftUI — для экранов и UI;
- UIKit — для корневой навигации, `UINavigationController`, `UITabBarController` и hosting-контейнеров.

### Composition Root

Главная точка сборки зависимостей — `mobile/Chooz/Chooz/Sources/Application/AppContainer.swift`.

Именно здесь создаются:

- сетевой слой;
- сервисы;
- фабрики экранов;
- shared-state зависимости вроде `TokenStorage`, `ToastManager`, `UserDefaultsService`.

Запуск приложения начинается через `AppBootstraper`, который:

- показывает splash;
- решает, вести ли пользователя в onboarding;
- проверяет наличие сессии;
- роутит пользователя в авторизацию или в основную часть приложения.

### Навигация

Навигация централизована в `AppRouter`:

- root построен на `UINavigationController`;
- таббар инкапсулирован в `MainTabBarController`;
- активный navigation stack отслеживается внутри роутера.

Дополнительно есть `DeepLinkService`, который сейчас умеет открывать social profile по схеме `chooz://profile/:userId`.

### Структура экранных модулей

Экранные модули в основном собраны по повторяющемуся паттерну:

- `Factory` — собирает модуль и зависимости;
- `Router` — отвечает за навигационные переходы;
- `Interactor` — координирует прикладные действия экрана;
- `ViewModel` — управляет состоянием UI;
- `View` — SwiftUI-представление.

Этот паттерн хорошо виден на модулях:

- `Authorization`;
- `Calendar`;
- `Onboarding`;
- `Profile`;
- `Settings`.

### Сетевой слой

Основной клиент — Apollo GraphQL.

Ключевые части:

- `AppContainer` создаёт `ApolloClient`;
- `AuthInterceptorProvider` добавляет interceptors;
- `AuthorizationInterceptor` подставляет access token;
- `TokenRefreshInterceptor` занимается обновлением токена и обработкой истечения сессии.

GraphQL-операции лежат в:

- `mobile/Chooz/Chooz/Sources/GraphQL/operations/`.

Сгенерированный код лежит в:

- `mobile/Chooz/Chooz/Sources/GraphQL/Generated/`.

### Прикладные сервисы

В отдельные сервисы вынесены основные cross-cutting и domain-specific зависимости:

- `WishlistService`;
- `CalendarService`;
- `ProfileService`;
- `YandexAuthService`;
- `GoogleAuthService`;
- `SessionService`;
- `NotificationService`;
- `AnalyticsService`;
- `DeepLinkService`.

### Текущее состояние клиентской архитектуры

- Основной каркас приложения уже готов под MVP.
- Часть направлений v2 уже отражена в структуре проекта, но ещё не полностью реализована в UI и backend.
- На текущем этапе архитектура iOS ориентирована на быстрое развитие продуктовых модулей через фабрики и изолированные сервисы.
