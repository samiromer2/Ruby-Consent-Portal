# Consent Portal

A small Rails app where **citizens** give **consent** to government **services** and can revoke it later.

I built it to learn Rails conventions, coming from Laravel. It covers the core of a consent-management product: data integrity in PostgreSQL, a custom revoke action, a background job, safe migrations, and tests at every level.

## Tech stack

- Ruby 4.0.6, Rails 8.1
- PostgreSQL
- Hotwire (Turbo, Stimulus) via importmap
- Minitest with fixtures, Capybara and Selenium for system tests
- GitHub Actions CI: RuboCop, Brakeman, bundler-audit, importmap audit, unit tests and system tests

## Features

- **Citizens, services and consents.** A consent links one citizen to one service (`has_many :through`).
- **One consent per citizen per service.** Enforced twice: a model validation gives a friendly error, and a unique index in PostgreSQL guarantees it, even if two requests arrive at the same moment.
- **Revoke instead of delete.** `PATCH /consents/:id/revoke` sets `revoked_at`, so there is a record of when consent was withdrawn. `Consent.active` returns only consents that haven't been revoked.
- **Automatic expiry.** `ExpireStaleConsentsJob` revokes active consents older than one year. It uses `find_each` to process records in batches.
- **Secure by default.**
  - Strong parameters don't allow `verified` on citizens, so users can't mark their own identity as verified.
  - Emails are normalized (trimmed and lowercased) and must be unique regardless of case.
- **No N+1 queries.** The consents list eager-loads citizens and services with `includes`.
- **Zero-downtime migration.** The `revoked_at` index is built with `algorithm: :concurrently`, so it doesn't lock writes on a large table.

## Getting started

Requirements: Ruby 4.0.6, PostgreSQL running locally, and Google Chrome for the system tests.

```bash
git clone https://github.com/samiromer2/Ruby-Consent-Portal.git
cd Ruby-Consent-Portal
bin/setup
```

`bin/setup` installs the gems, creates and migrates the database, and starts the server. Then open http://localhost:3000.

To start the server again later:

```bash
bin/rails server
```

## Running the tests

```bash
bin/rails test           # model, controller, integration and job tests
bin/rails test:system    # browser tests in headless Chrome
```

| Kind | Where | What it covers |
|---|---|---|
| Model | `test/models` | Validations, email normalization, the `active` scope, `revoke!` |
| Controller | `test/controllers` | CRUD actions and the revoke action |
| Job | `test/jobs` | Expiry revokes old consents and leaves recent ones alone |
| System | `test/system` | A user clicks "Revoke consent" and sees the Revoked badge |

### End-to-end smoke test (Playwright, Python)

`script/playwright/consent_flow.py` drives the running app in Chromium. It creates a citizen and a service, grants consent, checks that a duplicate is blocked, revokes the consent, then deletes its test data.

```bash
cd script/playwright
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt && playwright install chromium
python consent_flow.py --headed --slow-mo 500
```

Run it while `bin/rails server` is running. Use `--keep` to keep the test data and `--base-url` to point it at another server. Screenshots are saved in `script/playwright/screenshots/`.

## Quality checks

```bash
bin/rubocop               # code style
bin/brakeman              # static security scan
bin/bundler-audit         # known vulnerabilities in gems
bin/importmap audit       # known vulnerabilities in JavaScript packages
```

CI runs all of these, plus both test suites, on every push and pull request (`.github/workflows/ci.yml`).

## Background job

Run the expiry job by hand from the console:

```bash
bin/rails runner "ExpireStaleConsentsJob.perform_now"
```

It isn't scheduled yet. In production it would run nightly as a Solid Queue recurring job, configured in `config/recurring.yml`.

## Data model

```
Citizen ──< Consent >── Service

citizens   name, email (unique), verified
services   name, description
consents   citizen_id, service_id (unique together), granted_at, revoked_at
```

## What I'd add next

- **Authentication** through an identity provider (OIDC, for example Keycloak), so the app trusts the provider's ID token instead of storing passwords.
- **Authorization** with Pundit, so a citizen can only see and revoke their own consents.
- **An audit log** recording who granted or revoked each consent, and when.
- **Scheduling** for the expiry job as a nightly recurring job.
