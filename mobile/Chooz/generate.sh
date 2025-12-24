#!/bin/bash
set -euo pipefail

# Переходим в директорию скрипта (mobile/Chooz)
cd "$(dirname "$0")"

echo "🔄 Running Apollo GraphQL codegen..."
../tools/graphql/apollo_codegen.sh

echo ""
echo "🛠  Running tuist generate..."
tuist generate "$@"
