# syntax=docker/dockerfile:1
# Este é um Dockerfile de PRODUÇÃO. Usa multi-stage build para imagens menores e mais seguras.

# ----------------------------------------------------
# STAGE 1: BASE IMAGE (Imagens de runtime)
# ----------------------------------------------------
# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Instala pacotes básicos necessários para o runtime
RUN apt-get update -qq && \
    # Instala libvips para Active Storage, libjemalloc para otimização de memória, postgresql-client
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="1" 

# ----------------------------------------------------
# STAGE 2: BUILD (Instalação de Gems e Precompilação de Assets)
# ----------------------------------------------------
FROM base AS build

# Instala pacotes necessários para COMPILAR as gems (ex: 'pg' gem)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config nodejs && \
    rm -rf /var/lib/apt/lists/*

# Instala aplicação de gems
COPY Gemfile Gemfile.lock ./
# Instala gems, ignorando development/test (mais rápido, menor)
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copia código da aplicação
COPY . .

# Precompila assets para produção (requer Node.js/Yarn/etc., que foram instalados acima)
# SECRET_KEY_BASE_DUMMY evita erro durante o build (a chave real será injetada no Render)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# ----------------------------------------------------
# STAGE 3: FINAL (Imagem de Deploy - A Menor e Mais Segura)
# ----------------------------------------------------
FROM base

# Copia os artefatos construídos: gems instaladas, código e assets compilados
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Entrypoint personalizado para rodar migrações ANTES do servidor iniciar
# 1. Cria o script na pasta 'bin'
COPY bin/render-entrypoint.sh /usr/local/bin/
# 2. Garante que o script é executável
RUN chmod +x /usr/local/bin/render-entrypoint.sh

# Rodar como um usuário não-root (segurança)
# O usuário 'rails' foi criado na sua base do Rails 7.1+, se não estiver usando a base, adicione o comando:
# RUN groupadd --system --gid 1000 rails && useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
# USER 1000:1000 # Use o UID/GID do usuário não-root

# Entrypoint prepara o banco (roda db:migrate)
ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]

# Porta exposta (o Render irá mapear isso para a porta 10000)
EXPOSE 3000

# Comando para iniciar o servidor Puma/Rails
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

# # syntax=docker/dockerfile:1
# # check=error=true

# # This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# # docker build -t app .
# # docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name app app

# # For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# # Make sure RUBY_VERSION matches the Ruby version in .ruby-version
# ARG RUBY_VERSION=3.2.0
# FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# # Rails app lives here
# WORKDIR /rails

# # Install base packages
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Set production environment
# ENV RAILS_ENV="production" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_WITHOUT="development"

# # Throw-away build stage to reduce size of final image
# FROM base AS build

# # Install packages needed to build gems
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Install application gems
# COPY Gemfile Gemfile.lock ./
# RUN bundle install && \
#     rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
#     bundle exec bootsnap precompile --gemfile

# # Copy application code
# COPY . .

# # Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# # Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




# # Final stage for app image
# FROM base

# # Copy built artifacts: gems, application
# COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
# COPY --from=build /rails /rails

# # Run and own only the runtime files as a non-root user for security
# RUN groupadd --system --gid 1000 rails && \
#     useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
#     chown -R rails:rails db log storage tmp
# USER 1000:1000

# # Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Start server via Thruster by default, this can be overwritten at runtime
# EXPOSE 80
# CMD ["./bin/thrust", "./bin/rails", "server"]
