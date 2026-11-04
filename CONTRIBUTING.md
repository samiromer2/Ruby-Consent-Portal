# Contributing

Thanks for helping. New to Ruby or Rails? That's fine. This project was its author's first Rails app too. Ask anything in the issue.

## Pick an issue

- Start with [good first issues](https://github.com/samiromer2/Ruby-Consent-Portal/labels/good%20first%20issue), or browse [help wanted](https://github.com/samiromer2/Ruby-Consent-Portal/labels/help%20wanted).
- Comment on the issue that you're working on it, so two people don't do the same work.
- Each issue has a **Done when** line. That's the goal for the PR.
- Have a different idea? Open an issue first, so we can agree on it before you write code.

## Set up

Follow [Getting started](README.md#getting-started) in the README: Ruby 4.0.6, PostgreSQL, and Chrome for the system tests.

```bash
bin/setup
bin/rails db:seed
```

## Make the change

1. Fork the repo and create a branch: `git switch -c short-description`.
2. Write or update a test first when it makes sense. For rules about what must *not* happen (who can't see what, what can't change), a test is required.
3. Keep the PR to one issue.

## Before you open the PR

Run the same checks CI runs:

```bash
bin/rails test
bin/rails test:system
bin/rubocop
bin/brakeman
bin/bundler-audit
```

## Open the PR

- Link the issue (`Closes #123`).
- Say what changed and how you tested it. Add screenshots for UI changes.
- CI must pass all 6 checks before the PR can be merged.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
