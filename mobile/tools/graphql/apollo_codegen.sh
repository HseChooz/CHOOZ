#!/bin/bash

set -euo pipefail

# DIR — путь к директории, где лежит сам скрипт (mobile/tools/graphql)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# PROJECT_DIR — переходим из tools/graphql → mobile/Chooz
PROJECT_DIR="$DIR/../../Chooz"

CONFIG_PATH="$PROJECT_DIR/apollo-codegen-config.json"
SCHEMA_PATH="$PROJECT_DIR/Chooz/Sources/GraphQL/schema.graphqls"
QUERIES_PATH="$PROJECT_DIR/Chooz/Sources/GraphQL/operations"

# Используем локальный CLI из проекта
APOLLO_CLI="$PROJECT_DIR/apollo-ios-cli"

echo "[Apollo] Running codegen..."
echo "[Apollo] PROJECT_DIR: $PROJECT_DIR"

# Проверка CLI apollo-ios (сначала локальный, потом глобальный)
if [ -x "$APOLLO_CLI" ]; then
  echo "[Apollo] Using local CLI: $APOLLO_CLI"
elif command -v apollo-ios-cli >/dev/null 2>&1; then
  APOLLO_CLI="apollo-ios-cli"
  echo "[Apollo] Using global CLI"
else
  echo "[Apollo] CLI 'apollo-ios-cli' not found. Skipping codegen."
  exit 0
fi

# Проверка конфига
if [ ! -f "$CONFIG_PATH" ]; then
  echo "[Apollo] Config not found at $CONFIG_PATH, skipping codegen."
  exit 0
fi

# Проверка схемы
if [ ! -f "$SCHEMA_PATH" ]; then
  echo "[Apollo] Schema not found at $SCHEMA_PATH, skipping codegen."
  exit 0
fi

# Проверка запросов
if [ -z "$(ls -A "$QUERIES_PATH" 2>/dev/null)" ]; then
  echo "[Apollo] No GraphQL operations found, skipping codegen."
  exit 0
fi

# Запускаем из директории проекта (где лежит конфиг)
cd "$PROJECT_DIR"

# Очистка старых сгенерированных файлов
OUTPUT_DIR="$PROJECT_DIR/Chooz/Sources/GraphQL/Generated"
if [ -d "$OUTPUT_DIR" ]; then
  echo "[Apollo] Cleaning old generated files..."
  rm -rf "$OUTPUT_DIR"
fi

"$APOLLO_CLI" generate --path "$CONFIG_PATH" --verbose

echo "[Apollo] Codegen completed."
