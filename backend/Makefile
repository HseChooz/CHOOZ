compose-up:
	docker compose -f docker/compose.dev.yml up -d

compose-down:
	docker compose -f docker/compose.full.yml down

run:
	uv run python manage.py runserver

makemigrations:
	uv run python manage.py makemigrations

migrate:
	uv run python manage.py migrate

mmm: compose-up makemigrations migrate
