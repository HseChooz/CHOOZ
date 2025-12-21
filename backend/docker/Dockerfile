ARG PYTHON_BASE=python:3.11.14-slim-bookworm@sha256:50068b28f3105e4a3116e091993304eccb38895d676c8dae174c5b01a4d30dfb

FROM ${PYTHON_BASE}

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /backend

ENV UV_LINK_MODE=copy

COPY pyproject.toml uv.lock ./

RUN uv sync --frozen --no-dev

COPY . .

ENV PATH="/backend/.venv/bin:$PATH"

EXPOSE 8000

ENTRYPOINT ["sh", "-c", "python manage.py migrate --noinput && exec \"$@\"", "--"]
CMD ["gunicorn", "config.asgi:application", "-k", "uvicorn.workers.UvicornWorker", "-w", "2", "-b", "0.0.0.0:8000"]
