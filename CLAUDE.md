# CLAUDE.md — AI Assistant Guide for Mailadmin

## Project Overview

Mailadmin is a Ruby on Rails web application for managing email domains, mailboxes, and aliases. It targets docker-mailserver but can work with any Postfix/Dovecot setup. The app provides both a web UI (Devise-authenticated) and a token-based JSON/text API.

**Repository**: https://github.com/aspettl/mailadmin

## Tech Stack

- **Ruby** 4.0.1 / **Rails** 8.1.2
- **Database**: MySQL / MariaDB (mysql2 gem, utf8mb4 encoding)
- **Web server**: Puma 7.2
- **Authentication**: Devise 5.0
- **Frontend**: ERB templates, Sprockets asset pipeline, SCSS, importmap-rails (ES modules)
- **Testing**: Minitest, Capybara + Selenium (system tests)
- **Linting**: Rubocop with rubocop-rails and rubocop-minitest plugins

## Quick Commands

```bash
# Install dependencies
bundle install

# Database setup (requires running MySQL/MariaDB)
bundle exec rails db:create
bundle exec rails db:migrate

# Run all tests (unit + controller + system)
bundle exec rails test:all

# Run unit and controller tests only
bundle exec rails test

# Run system tests only
bundle exec rails test:system

# Run linter
bundle exec rubocop -c .rubocop.yml

# Load test fixtures into development database for manual testing
bundle exec rails db:fixtures:load

# Start development server (port 3000)
bundle exec rails server
```

## Project Structure

```
app/
  controllers/           # RESTful controllers + API controllers
    accounts_controller.rb       # CRUD for mailboxes/aliases (nested under domains)
    domains_controller.rb        # CRUD for email domains
    dashboards_controller.rb     # Dashboard / root page
    import_export_api_controller.rb  # JSON backup/export/import API
    roundcube_api_controller.rb      # Roundcube password change API
    health_api_controller.rb         # Health check endpoint
  models/
    user.rb              # Devise user (admin), has_many :domains
    domain.rb            # Email domain (local_domain or alias_domain)
    account.rb           # Mailbox/alias/blackhole (nested under domain)
  views/                 # ERB templates, Jbuilder for API JSON
  assets/                # SCSS stylesheets, images
  javascript/            # ES module JavaScript (importmap)
config/
  routes.rb              # All route definitions
  database.yml           # DB connection (dev/test: socket, prod: DATABASE_URL)
  application.rb         # App config + custom env var loading
  initializers/devise.rb # Devise authentication config
db/
  migrate/               # 13 migrations
  schema.rb              # Current schema (3 main tables + ActiveStorage)
test/
  models/                # Unit tests
  controllers/           # Controller tests
  system/                # Browser-based system tests (Capybara)
  fixtures/              # YAML test fixtures (users, domains, accounts)
integrations/
  docker-mailserver-configreload/  # Python sidecar for config export
  roundcube-password-plugin/       # Roundcube integration docs
```

## Architecture & Key Patterns

### Models

Three core models with enum-based type discrimination (not STI):

- **User**: Devise authentication. `has_many :domains`. All users are admins.
- **Domain**: `enum :type, { local_domain: 0, alias_domain: 1 }`. `belongs_to :user`, `has_many :accounts`.
- **Account**: `enum :type, { local_mailbox: 0, alias_address: 1, blackhole_address: 2 }`. `belongs_to :domain`.

Password hashing for accounts uses BCrypt (`before_save` callback). Passwords are validated against the Have I Been Pwned API (pwned gem) with a 10-character minimum.

### Routing

- Web UI routes are standard RESTful resources: `domains` and nested `accounts`
- API routes are under `/api/v1/` with Bearer token auth (`API_TOKEN` env var)
- Root path maps to `dashboards#show`

### Controllers

- Web controllers require Devise sign-in (`before_action :authenticate_user!`)
- API controllers check `Authorization: Bearer <token>` against `Rails.configuration.api_token`
- `ImportExportApiController` handles backup, export, and import (JSON)
- `RoundcubeApiController` handles password changes (plain text response)

## Database

MySQL/MariaDB with utf8mb4 encoding. Three main tables:

- **users**: Devise fields (email, encrypted_password, lockable fields)
- **domains**: domain name, type (enum), user_id FK, catchall settings, alias target
- **accounts**: email, crypt (password hash), domain_id FK, type (enum), forward/alias settings

Unique indexes on `users.email`, `domains.domain`, and `accounts.email`.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SECRET_KEY_BASE` | Yes (prod) | Rails encryption key; random fallback in dev |
| `DATABASE_URL` | Yes (prod) | MySQL connection string |
| `API_TOKEN` | No | Bearer token for API endpoints |
| `CONFIGRELOAD_WEBHOOK` | No | URL to trigger mail server config reload |
| `MAILSERVER_HOSTNAME` | No | Mail server FQDN (default: system hostname) |
| `WEBMAIL_HOSTNAME` | No | Webmail hostname (default: MAILSERVER_HOSTNAME) |
| `SMTP_HOSTNAME` | No | SMTP hostname for docs display |
| `IMAP_HOSTNAME` | No | IMAP hostname for docs display |
| `POP3_HOSTNAME` | No | POP3 hostname for docs display |
| `MANAGESIEVE_HOSTNAME` | No | ManageSieve hostname for docs display |
| `MX_RECORD` | No | Custom MX record template |
| `SPF_RECORD` | No | Custom SPF record template |

## Code Style & Linting

Rubocop configuration (`.rubocop.yml`):

- **Max line length**: 120 characters
- **Max method length**: 20 lines
- **Max ABC complexity**: 20
- **Max assertions per test**: 6
- **Plugins**: rubocop-rails, rubocop-minitest
- **Style/Documentation**: disabled (no mandatory class docs)
- **Excluded**: `bin/`, `db/schema.rb`, `vendor/`

All code files use `# frozen_string_literal: true` at the top.

## Testing

- **Framework**: Minitest (Rails default)
- **Fixtures**: YAML fixtures in `test/fixtures/` auto-loaded for all tests
- **Parallelization**: Tests run in parallel (`workers: :number_of_processors`)
- **System tests**: Capybara + Selenium WebDriver
- **Test data**: Two users (alice@example.com with password `test`, quentin@example.com with password `test2`), sample domains and accounts

The CI pipeline (`bundle exec rails test:all`) runs all test types followed by Rubocop.

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- **ci.yml**: Runs on push/PR. Sets up Ruby, starts MySQL, runs `rails test:all` + `rubocop`
- **docker.yml**: Builds multi-arch Docker images (amd64/arm64) for the app and configreload sidecar
- **codeql-analysis.yml**: GitHub CodeQL security scanning

## Docker

- **Dockerfile**: Multi-stage build (builder + runtime) based on ruby:4.0.1-slim-bookworm
- **docker-compose.yml**: Full stack with mailadmin, configreload sidecar, nginx, log volume init
- **entrypoint.sh**: Runs `rails db:migrate` then starts Puma

## Conventions for Contributors

- Follow existing RESTful controller patterns for new endpoints
- Use enum types on models rather than STI for type discrimination
- Validate at the model level; controllers stay thin
- Use `nilify_blanks` for optional string fields
- Use `memoist` for memoizing expensive computed associations
- Keep test fixtures in sync when adding new model fields
- API endpoints use Bearer token auth; web endpoints use Devise
- Breadcrumb navigation via `breadcrumbs_on_rails` in controllers
- Run `bundle exec rubocop -c .rubocop.yml` before committing to catch style issues
- Run `bundle exec rails test:all` to verify nothing is broken
