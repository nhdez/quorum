# Quorum

Quorum is a political discussion forum built with Rails. It pairs a classic phpBB-style
board (categories, forums, threads, replies) with an admin-configurable AI moderation
layer that flags logical fallacies and biased language, plus a full admin control panel
for running the community.

## Features

- **Forums & threads** — nested categories/forums/subforums, threaded replies, voting,
  highlights, post signatures (moderated Markdown via Redcarpet + Action Text/Lexxy).
- **Accounts & roles** — Devise auth, Pundit authorization, Rolify roles, an admin-run
  rank system with a configurable conditions engine, and user affiliations/factions.
- **AI moderation** — two independent, admin-configurable detectors built on
  [ruby_llm](https://github.com/crmne/ruby_llm)/Anthropic:
  - **Fallacy Detection** — flags a catalog of logical fallacies, scoped per forum.
  - **AI Bias Bot** — flags a catalog of biased-language categories at an admin-chosen
    sensitivity level, with a per-forum opt-out.
- **Member directory** — searchable/sortable public member list powered by Ransack.
- **Admin panel** — dashboard, forum/board management, ranks, user groups, moderation
  queues, pending-registration review, site settings (name/slogan/footer menu), forum
  rules (Markdown-authored, publicly displayed), SMTP/object-storage settings, and the
  AI settings above.

## Stack

- Ruby 3.4.5, Rails ~> 8.1.3, PostgreSQL
- Hotwire (Turbo + Stimulus), ViewComponent, Tailwind CSS v4
- Devise, Pundit, Rolify, FriendlyId, Ransack, Pagy
- Active Storage, Action Text (Lexxy), Redcarpet (Markdown rendering)
- Solid Queue / Solid Cache / Solid Cable
- Deployed via Kamal (Docker)

## Getting Started

```bash
bin/setup
```

This installs gems, prepares the database (`db/prepare`, which runs pending migrations
and seeds), and starts the dev server. To do it manually instead:

```bash
bundle install
bin/rails db:prepare
bin/dev
```

`bin/dev` runs `Procfile.dev` (Rails server + `tailwindcss:watch`) via Foreman/Overmind.
The app expects Rails credentials to be configured — see `config/credentials.yml.enc`
(`bin/rails credentials:edit`) for the Active Record encryption keys and any AI vendor
API keys, which are otherwise configured live from the admin panel
(`/admin/ai_settings`, `/admin/bias_bot_settings`).

## Testing & Quality

```bash
bin/rails test        # test suite
bin/rubocop            # style (rubocop-rails-omakase)
bin/brakeman            # static security analysis
bin/bundler-audit       # dependency vulnerability audit
```

## Deployment

Kamal-based; see `config/deploy.yml` and the `Dockerfile`. `bin/kamal` wraps the CLI.

## License

Licensed under the [MIT License](LICENSE).
