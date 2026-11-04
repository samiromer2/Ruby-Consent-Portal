# Consent Portal

A finished Ruby on Rails app for managing consent. A citizen grants a service permission to use their data, and can take that permission back. Withdrawing consent keeps the record of when it was granted and when it was revoked.

Run it locally with the demo accounts below. It is not deployed.

## What it does

- **Accounts.** Sign up, sign in, and sign out. Rails 8 authentication stores sessions in the database. Sign-in is rate limited. Each citizen account is linked to one citizen record.
- **Two roles.** A citizen sees and changes only their own consents. An admin sees every consent, manages services, and can mark a citizen as verified. An admin cannot grant or revoke someone else's consent.
- **One consent per citizen per service.** A model validation returns a friendly error, and a unique index in PostgreSQL enforces it when two requests arrive together.
- **Revoke, don't delete.** `PATCH /consents/:id/revoke` sets `revoked_at`. Consents are not edited. `granted_at` and `revoked_at` are not in the form, so a request cannot bring a revoked consent back.
- **Audit log.** Each grant, revoke, and expiry writes a `ConsentEvent`. Saved events cannot be updated or deleted. A citizen, service, or consent that has history cannot be destroyed.
- **Citizen home and admin dashboard.** Citizens land on My consents, with Active, Revoked, and All tabs, search, a service filter, and pagination. Revoke updates the page without a full reload. Admins land on counts of citizens, services, and consents.
- **Nightly expiry.** `ExpireStaleConsentsJob` revokes active consents older than one year, writes an expired event, and emails the citizen. In production, Solid Queue runs it at 3am (`config/recurring.yml`).
- **JSON API.** Other systems list, read, and revoke consents at `/api/v1` with a bearer token.

## Tech stack

- Ruby 4.0.6, Rails 8.1
- PostgreSQL
- Hotwire (Turbo, Stimulus) via importmap
- Pundit for authorization, Pagy for pagination, Solid Queue for jobs
- Minitest with fixtures, one RSpec example with FactoryBot, Capybara and Selenium for system tests, Playwright for the smoke test
- GitHub Actions: RuboCop, Brakeman, bundler-audit, importmap audit, unit tests, system tests, and the Playwright smoke test

## Getting started

Requirements: Ruby 4.0.6, PostgreSQL running locally, and Google Chrome for the system tests.

```bash
git clone https://github.com/samiromer2/Ruby-Consent-Portal.git
cd Ruby-Consent-Portal
bin/setup
bin/rails db:seed
```

`bin/setup` installs the gems, prepares the database, and starts the server. Open http://localhost:3000.

Start it again later with `bin/rails server`. Run the job worker with `bin/jobs` when you want to watch background work in development.

| Email | Password | What you can do |
|---|---|---|
| `admin@example.com` | `password` | See every consent and manage services |
| `citizen@example.com` | `password` | See and revoke that citizen's consents |

The password is for this local demo.

## Project layout

| File | What it does |
|---|---|
| `app/models/consent.rb` | Uniqueness rule, `active` scope, `revoke!` |
| `app/models/consent_event.rb` | Append-only audit log |
| `app/policies/consent_policy.rb` | Who can see, grant, and revoke a consent |
| `app/services/consents/revoke.rb` | Revoke plus the revoked event |
| `app/controllers/dashboard_controller.rb` | Citizen home and admin counts |
| `app/controllers/api/v1/consents_controller.rb` | Token-authenticated JSON API |
| `app/jobs/expire_stale_consents_job.rb` | Revokes consents older than a year and sends the email |
| `config/recurring.yml` | Nightly schedule for the expiry job |
| `config/routes.rb` | Web routes and `/api/v1` |

`plan.md` is the build log for the phases. The checkboxes there are the record of how the app was built.

## JSON API

Send the user's token as `Authorization: Bearer`. A token is created with the account. Read one from the console:

```bash
bin/rails runner 'puts User.find_by!(email_address: "admin@example.com").api_token'
```

```bash
curl -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/v1/consents
curl -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/v1/consents/1
curl -X PATCH -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/v1/consents/1/revoke
```

| Request | Who | Result |
|---|---|---|
| `GET /api/v1/consents` | Citizen | That citizen's consents |
| `GET /api/v1/consents` | Admin | Every consent |
| `GET /api/v1/consents/:id` | Owner or admin | One consent |
| `PATCH /api/v1/consents/:id/revoke` | Owner of an active consent | Sets `revoked_at` and writes a revoked event |

A missing or unknown token returns `401`. A client who is not allowed to see or revoke that consent returns `403`.

## Data model

```
User ── Citizen ──< Consent >── Service
                     │
                     └──< ConsentEvent
```

```
users           email_address, role (citizen or admin), api_token
citizens        name, email (unique), verified
services        name, description
consents        citizen_id, service_id (unique together), granted_at, revoked_at
consent_events  consent_id, user_id, action (granted, revoked, expired)
```

## Tests

```bash
bin/rails test           # model, controller, integration, and job tests
bin/rails test:system    # browser test in headless Chrome
bundle exec rspec        # one Consent example, using FactoryBot
```

`bin/rails test` writes a coverage report to `coverage/index.html`.

The Playwright smoke test drives a running server: sign in as the admin, create a service, sign up, grant consent, block a duplicate, revoke, and confirm that history cannot be deleted.

```bash
cd script/playwright
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt && playwright install chromium
python consent_flow.py --headed --slow-mo 500
```

Run it while `bin/rails server` is running. `--keep` leaves the test data in place. `--base-url` points it at another server. Screenshots are saved in `script/playwright/screenshots/`.

```bash
bin/rubocop               # code style
bin/brakeman              # static security scan
bin/bundler-audit         # known vulnerabilities in gems
bin/importmap audit       # known vulnerabilities in JavaScript packages
```

CI runs these checks on every push and pull request (`.github/workflows/ci.yml`). `main` requires them before a merge.

## Status

This repository is the completed app, for local use.

Kamal's config is in `config/deploy.yml` and still uses the placeholder host `192.168.0.1`. There is no public site. Sign-in is email and password. Errors are not sent to an external tracker. Those three boundaries are written down in [#20](https://github.com/samiromer2/Ruby-Consent-Portal/issues/20), [#21](https://github.com/samiromer2/Ruby-Consent-Portal/issues/21), and [#22](https://github.com/samiromer2/Ruby-Consent-Portal/issues/22).

## Contributing

Contributions are welcome. The [open issues](https://github.com/samiromer2/Ruby-Consent-Portal/issues) each say what to do and when it's done, and the ones labelled [good first issue](https://github.com/samiromer2/Ruby-Consent-Portal/labels/good%20first%20issue) are a friendly place to start. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to set up, test, and open a PR.

## License

[MIT](LICENSE)
