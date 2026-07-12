# CLAUDE.md

Guidance for Claude Code when working in this repository. See [README.md](README.md)
for the feature/stack overview and setup instructions.

## Stack

Rails ~> 8.1.3, PostgreSQL, UUID primary keys everywhere. ViewComponent + Tailwind v4
for UI. Devise + Pundit + Rolify for auth/roles. FriendlyId, Ransack, Pagy. Action Text
(Lexxy) + Redcarpet for rich content. RuboCop (rubocop-rails-omakase) and Brakeman are
both clean — treat any new offense as a bug to fix, not a baseline to accept.

## Conventions

- **Admin singleton-settings pattern**: for a single global settings row, use
  `SomeSetting < ApplicationRecord` with `def self.instance; first_or_create!; end`,
  an `Admin::SomeSettingController < Admin::BaseController` with just `edit`/`update`,
  wired into `Admin::SidebarComponent::LINKS`. Existing examples: `AiSetting`,
  `BiasBotSetting`, `SiteSetting`, `RulesSetting`, `SmtpSetting`, `StorageSetting`,
  `PostSetting`.
- **Admin-manageable catalogs**: for a flat, admin-editable list of detection/category
  records (as opposed to a single settings row), follow `FallacyDefinition` /
  `BiasCategory`: `key, display_name, short_description, detection_prompt_fragment,
  enabled` columns, seeded idempotently from `db/seeds/<name>.rb` via
  `find_or_initialize_by(key:).assign_attributes(...).save!` (never overwrite
  `enabled` on reseed, so admin toggles survive), loaded from `db/seeds.rb`.
- **Data-shape migrations**: when a migration needs to read/transform real data (not
  just alter schema), define a scoped AR class inline in the migration file itself
  (e.g. `class MigrationFoo < ActiveRecord::Base; self.table_name = "foos"; end`)
  rather than depending on the app's real model classes, which may change shape later.
- **Markdown rendering**: two-layer defense — `Redcarpet::Render::HTML.new(filter_html:
  true, safe_links_only: true)` at render time, then
  `ActionController::Base.helpers.sanitize(html, tags:, attributes:)` as a second
  allowlist pass. See `HasSignature` (tight allowlist, no headings/tables) vs.
  `RulesSetting#rendered_content` (fuller allowlist for admin-authored content). Note
  the `:underline` Redcarpet extension is enabled, so single-underscore `_text_`
  renders as `<u>`, not `<em>` — that's expected, not a bug.
- **Ransack**: `ransackable_attributes`/`ransackable_associations` must be explicitly
  defined as class methods (allowlist) on any model passed to `.ransack`, or it raises
  at call time. `Model.ransack(bad_attr_cont: "x")` silently drops the unauthorized
  condition; only `ransack!` raises (`Ransack::InvalidSearchError`).

## Working practices

- Verify third-party library APIs against real installed gem source/docs before
  writing code against them — do not rely on training-data recall for gem APIs.
- Verify features end-to-end against the running dev server (disposable admin user via
  `bin/rails runner`, real `curl` session with proper CSRF handling) in addition to the
  permanent test suite. `bin/rails restart` (Puma `tmp_restart` plugin) is required
  after editing `config/credentials.yml.enc` or schema before live-server verification
  — those are memoized at boot and a running server will not pick up changes.
- Disposable verification scripts must never destructively overwrite real
  shared/singleton state (e.g. `SiteSetting.instance`) with assumed defaults; capture
  and restore real pre-existing values, and prefer creating+destroying throwaway child
  records instead.
- Run the test suite, RuboCop, and Brakeman before considering a feature done.
- Do not commit or push unless explicitly asked.
