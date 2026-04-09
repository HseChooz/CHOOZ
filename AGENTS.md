# AGENTS.md
Инструкции для AI-агентов и ассистентов, работающих с этим репозиторием.


## Контекст проекта
CHOOZ – мобильное приложение-помощник в подборе подарков.

Подробный продуктовый контекст находится в файле [docs/project-context.md](docs/project-context.md).


## Стек
Подробный стек backend и iOS находится тут [docs/stack.md](docs/stack.md).


## Архитектура
Описание архитектуры находится здесь [docs/architecture.md](docs/architecture.md).


## Правила
Все файлы AGENTS.md и README.md (не только корневые, но и вложенные) редактировать можно, но только по согласованию с пользователем, то есть перед внесением правок необходимо получить разрешение.


## Git
Для комментов в коммитах используй стандарт Conventional Commits (обязательно на английском), примеры:
- feat(backend): add GraphQL queries for gift collections
- fix(ios): handle Yandex sign-in session expiration
- docs(repo): update AGENTS and project documentation
- test(backend): add integration tests for wishlist mutations
- chore(infra): add pull request template and CODEOWNERS

Ветки называй в таком формате `<prefix>/<type>/<short-description>` где
- `prexif`: backend, ios, repo или infra
- `type` как в branch naming conventions, вот некоторые популярные types: feature/ bugfix/ hotfix/ release/ chore/ docs/ test/

Примеры веток:
- `backend/feature/collections`
- `ios/feature/social-profile`

PR заполняй полностью на русском (как название, так и описание) по шаблону: [.github/pull_request_template.md](.github/pull_request_template.md)

Issues пиши тоже на русском

ВАЖНО! Пиши PR и issues сразу по-русски, не переводи дословно с английского.
То есть текст должен быть естественным (например, не должно быть русских глаголов инфинитивов) – проверь это перед отправкой.


## Язык
Все ответы пользователю должны быть на русском.
