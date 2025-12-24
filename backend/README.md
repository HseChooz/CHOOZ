## Инструкция по локальному запуску API

#### 0) Заменить `.env.example` на `.env` (с заполненными пропусками).

#### 1) Из папки `backend/` запустить контейнеры:
```shell
docker compose -f docker/compose.full.yml up -d
```

#### 2) Перейти по http://localhost:8000/api/graphql/

---

#### 3) Тестовый запрос
```graphql
query {
  me {
    id
  }
}
```

API должно вернуть:
```graphql
{
  "data": {
    "me": null
  }
}
```

#### 4) Остановить контейнеры (по желанию)
```shell
docker compose -f docker/compose.full.yml down
```
