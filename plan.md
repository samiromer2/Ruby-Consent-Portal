# Consent Portal: Project Plan

Where the project is now, and the steps to turn it into a complete Rails app. Work through the phases in order: each one builds on the previous one. Every task ends with a commit, and `main` stays green in CI.

## Where we are (Oct 15, 2026)

**Done**
- Citizens, services and consents with validations, associations and a unique index
- Revoke action, `active` scope, expiry job (`ExpireStaleConsentsJob`)
- Concurrent index migration
- Simple design: nav bar, cards, badges, dropdowns in the consent form
- 29 unit/controller/job tests, 1 system test, Playwright smoke test
- CI green: RuboCop, Brakeman, bundler-audit, importmap audit, tests, system tests
- README, Dependabot

**Known loose ends** (found while reviewing the code)
- `users` and `sessions` tables and the `bcrypt` gem exist, but there are no models or code using them (left over from the removed auth generator)
- `consent_params` allows `revoked_at` and `granted_at`, so anyone can **un-revoke** a consent or backdate it through the edit form
- The expiry job never runs on its own: there's no `config/recurring.yml` entry and Solid Queue isn't set up (no queue schema, no production adapter)
- `image_processing` is in the Gemfile but nothing uses it
- Small style issues: `perform(*args)` with unused args, odd indentation in `consents_controller.rb`
- `main` has no branch protection, so a PR can be merged while CI is red

---

## Phase 0: Clean up (≈ 1 hour)

Goal: no loose ends before building new features.

- [x] Protect consent history: remove `:granted_at` and `:revoked_at` from `consent_params` and from the form. Revoking only happens through the Revoke button. Add a test proving `PATCH /consents/:id` can't change `revoked_at`.
- [x] Decide what to do with `users`/`sessions`: keep them for Phase 1. The tables and `bcrypt` stay so the authentication generator can reuse them.
- [x] Remove `image_processing` from the Gemfile.
- [ ] Tidy `ExpireStaleConsentsJob#perform` and the controller indentation.
- [ ] Turn on branch protection for `main` on GitHub: require the 5 CI checks to pass.

Done when: CI green, no unused gems or tables without a plan.

## Phase 1: Authentication (≈ 3 hours)

Goal: people must sign in, and each user is linked to a citizen.

- [x] Run `bin/rails generate authentication` again (it reuses the existing tables) and read every generated file.
- [x] Link `User` to `Citizen` (`has_one :citizen` / `belongs_to :user`).
- [x] Add a sign-up page (the generator only does sign-in).
- [x] Show the signed-in user and a Sign out button in the nav bar.
- [x] Update every controller test and the system test to sign in first (`sign_in_as` helper).
- [x] Add rate limiting to sign-in (`rate_limit` is built into Rails 8).

Done when: every page except sign-in and sign-up redirects to sign-in when logged out, and all tests pass.

Learning: `has_secure_password`, sessions and cookies, `before_action`, `Current` attributes.

## Phase 2: Authorization and roles (≈ 3 hours)

Goal: citizens only see and change their own consents; admins manage services.

- [x] Add a `role` to users (`citizen`, `admin`) with a Rails `enum`.
- [x] Add Pundit, with policies for `Consent`, `Service` and `Citizen`.
- [x] Citizens: see only their own consents, grant and revoke only their own.
- [x] Admins: create/edit/delete services, see all consents, set `verified` on citizens (the only place that's allowed).
- [x] Scope the consent form: a citizen picks only a service, the citizen is `Current.user.citizen`.
- [x] Policy tests, plus a controller test proving a citizen gets 403/redirect on someone else's consent.

Done when: one citizen can't see or touch another citizen's data, proven by tests.

Learning: authorization vs authentication, policy objects, `enum`, scoping queries.

## Phase 3: Audit log (≈ 2 hours)

Goal: a permanent record of who granted or revoked each consent, and when.

- [x] New model `ConsentEvent` (`consent_id`, `user_id`, `action`: granted/revoked/expired, `created_at`), never edited or deleted.
- [x] Record events from the controller and from `ExpireStaleConsentsJob` (actor = system).
- [x] Show a timeline of events on the consent page.
- [x] Tests: granting, revoking and expiring each write exactly one event.
- [x] Close the gaps found in review: a revoked consent can't be revoked again (it overwrote `revoked_at` and wrote a second event), and consents can't be edited at all (changing the service left no event).

Done when: every change to a consent leaves an event, including ones made by the job.

Learning: append-only tables, model callbacks vs explicit service objects (try a small `Consents::Revoke` service object here).

## Phase 4: Background jobs for real (≈ 1.5 hours)

Goal: the expiry job runs every night on its own.

- [x] Install Solid Queue properly (`bin/rails solid_queue:install`), set the production adapter.
- [x] Add the job to `config/recurring.yml` to run nightly.
- [x] Run it in development with `bin/jobs` and watch it work.
- [x] Send the citizen an email when a consent expires (Action Mailer, preview in `test/mailers/previews`).

Done when: `bin/jobs` picks up the recurring job, and the expiry email shows in the mailer preview.

Learning: Active Job adapters, Solid Queue, recurring jobs, Action Mailer.

## Phase 5: Better UI (≈ 3 hours)

Goal: the app feels like a product, not a scaffold.

- [x] Citizen dashboard as the home page: "My consents", with Active/Revoked tabs.
- [x] Admin dashboard: counts of citizens, services, active and revoked consents.
- [x] Filter and search on the consents list (by status, by service).
- [x] Pagination (Pagy gem).
- [x] Revoke without a full page reload (Turbo Streams).
- [x] Remove scaffold leftovers (the generic "Editing …" pages, JSON views not used).

Done when: a citizen can manage consents from one page, and the admin has an overview.

Learning: Turbo Frames and Streams, partials, query objects for filtering.

## Phase 6: JSON API (≈ 2 hours)

Goal: other systems can read and revoke consents.

- [x] `namespace :api do namespace :v1` with `consents#index`, `#show` and `#revoke`.
- [x] Token authentication for API clients (`has_secure_token`).
- [x] Request tests for each endpoint, including 401 without a token.
- [x] Document the endpoints in the README.

Learning: API namespacing and versioning, `ActionController::API`, request specs.

## Phase 7: Deploy (≈ 2 hours)

Goal: a live URL to share.

- [x] Pick a host: Kamal (`config/deploy.yml`). The server address is still a placeholder.
- [x] Production database schemas for cache, queue, and cable, `RAILS_MASTER_KEY`, and Solid Queue inside Puma.
- [x] Seed data (`db/seeds.rb`) with a demo admin and citizen.
- [ ] Add the live link to the README. Demo logins are documented. Publishing the URL needs a real host.

Done when: the app runs at a public URL and CI still passes.

## Phase 8: Extras (pick any)

- [ ] Run the Playwright smoke test in CI against a started server
- [ ] Bullet gem to catch N+1 queries in development
- [ ] SimpleCov for test coverage
- [ ] Try RSpec + FactoryBot on one model, to compare with Minitest
- [ ] Sign in with OIDC (Keycloak or Google) instead of passwords
- [ ] Error tracking (Honeybadger / Sentry)

---

## How we work

1. One task at a time, on a branch: `git switch -c phase-0/protect-consent-history`.
2. Write or update the test first when it makes sense.
3. Run `bin/rails test`, `bin/rails test:system` and `bin/rubocop` before committing.
4. Push, open a PR, merge when CI is green.
5. Tick the box in this file.
