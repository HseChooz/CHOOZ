# AGENTS.md
Инструкции для AI-агентов и ассистентов, работающих с этим репозиторием.


## Контекст проекта
CHOOZ — мобильное приложение-помощник в подборе подарков.
Подробнее тут [docs/project-context.md](docs/project-context.md)


## Стек
Подробный стек backend и iOS находится в файле [docs/stack.md](docs/stack.md)


## Архитектура
Описание архитектуры находится здесь [docs/architecture.md](docs/architecture.md)


## Инструкции
Все маркдаун файлы (не только корневые, но и вложенные) можно редактировать только по запросу пользователя.
То есть тебе нельзя самостоятельно вносить правки в файлы с расширением `.md` или же без спроса предлагать пользователю актуализировать их. 


## Git
Для комментов в коммитах используй стандарт Conventional Commits (обязательно на английском), вот несколько примеров:
- feat(backend): add GraphQL queries for gift collections
- fix(ios): handle Yandex sign-in session expiration
- docs(repo): update AGENTS and project documentation
- test(backend): add integration tests for wishlist mutations
- chore(infra): add pull request template and CODEOWNERS

Ветки называй в таком формате `<prefix>/<type>/<short-description>` (всегда по-английски) где
- `prexif` backend, ios или infra
- `type` как в branch naming conventions, вот некоторые популярные types: feature/ bugfix/ hotfix/ release/ chore/ docs/ test/
Пример ветки: backend/feature/collections

PR заполняй полностью на русском (как название, так и описание) по шаблону: [.github/pull_request_template.md](.github/pull_request_template.md)

Issues пиши тоже на русском.

ВАЖНО! Пиши PR и issues сразу по-русски, не переводи дословно с английского.
То есть текст должен быть естественным – проверь это перед отправкой.

Особенно важно чтобы вместо глаголов инфинитивов ты использовал краткие страдательные причастия прошедшего времени.
Например, не "добавить", а "добавлен" или "добавлено".


## Язык
Все ответы пользователю должны быть на русском.

## Прочее
Обязательно изучи локальный файл AGENTS.local.md, если таковой имеется.
