#!/bin/bash
set -e # Sai imediatamente se um comando falhar

# O Render geralmente fornece o DATABASE_URL e garante a conexão.
# O Entrypoint é o lugar ideal para rodar comandos de setup em tempo de execução.

# 1. Roda as Migrações do Banco de Dados
echo "Running database migrations..."
/rails/bin/rails db:migrate

# 2. Inicia o servidor Rails (executa o comando CMD do Dockerfile)
echo "Starting Rails server..."
exec "$@"