# Стек проекта CHOOZ

## Backend

- Python 3.12+
- `uv` для управления зависимостями и lock-файла (`backend/uv.lock`)
- Django 6.0
- GraphQL на `strawberry-graphql` и `strawberry-graphql-django`
- Django REST Framework как инфраструктурная зависимость вокруг backend-слоя
- JWT-аутентификация через `djangorestframework-simplejwt`
- PostgreSQL через `psycopg[binary]`
- S3-совместимое файловое хранилище / MinIO через `boto3`
- Pillow для работы с изображениями на backend-стороне
- Gunicorn и Uvicorn для запуска приложения
- Docker и отдельные `compose.dev.yml`, `compose.stage.yml`, `compose.prod.yml`
- `pytest`, `pytest-django`, `ruff`, `bandit`, `pip-audit`, `pre-commit` для тестирования и контроля качества

## iOS

- Swift 6
- iOS 17+
- SwiftUI как основа экранов
- UIKit для root-навигации, контейнеров и интеграции со сценами приложения
- Tuist для описания проекта и сборки
- Swift Package Manager для внешних зависимостей
- Apollo iOS для GraphQL-клиента и генерации кода
- Kingfisher для загрузки и кеширования изображений
- Yandex Login SDK
- Sign in with Apple
- Google Sign-In SDK подключён на уровне зависимостей, но не включён в текущий пользовательский сценарий входа
- AppMetrica и AppMetricaCrashes для аналитики и crash-репортинга
- `UserNotifications` для локальных напоминаний по событиям

## Общие замечания по стеку

- Репозиторий монореповый: backend и iOS-клиент живут вместе.
- Основной контракт между клиентом и сервером — GraphQL.
- В проекте нет отдельного Android-клиента или выделенного frontend web-приложения.
