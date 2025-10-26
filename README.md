# 🎬 Filmes App: Plataforma Dockerizada de Catálogo e Comentários

## Descrição do Projeto

O **Filmes App** é uma plataforma web desenvolvida em **Ruby on Rails** com **PostgreSQL** que simula um catálogo de filmes com funcionalidades de autenticação e interação. O projeto é totalmente dockerizado para garantir um ambiente de desenvolvimento portátil e consistente.

### Funcionalidades Implementadas

| Área | Funcionalidades |
| :--- | :--- |
| **Área Pública (Sem Login)** | **Catálogo de Filmes:** Listagem paginada (6 por página), ordenada do mais novo para o mais antigo. |
| | **Detalhes do Filme:** Exibe título, sinopse, ano, duração e diretor. |
| | **Comentários Anônimos:** Permite que visitantes deixem comentários informando apenas um nome. |
| | **Autenticação:** Cadastro de novo usuário e recuperação de senha (via Devise). |
| **Área Autenticada (Com Login)** | **CRUD de Filmes:** O usuário pode cadastrar, editar e apagar **apenas** seus próprios filmes. |
| | **Comentários:** Usuário autenticado comenta com seu nome automaticamente vinculado. |
| | **Perfil:** Possibilidade de editar perfil e alterar senha. |

---

## 🚀 Como Iniciar (Rodando com Docker Compose)

Este guia pressupõe que você tenha o **Docker Desktop** (ou Docker Engine + Docker Compose) e o **Git** instalados na sua máquina.

### 1. Clonar o Repositório

Abra seu terminal e baixe o código-fonte digitando:

```bash
git clone [URL_DO_SEU_REPOSITORIO]
cd filmes-app
```
### 2. Rodar a aplicação

Ainda no terminal digite:
```bash
docker compose build
docker compose up -d db
docker compose run --rm web rails db:setup
docker compose up -d web
```

A plicação estará disponível por padrão em http://localhost:3000
