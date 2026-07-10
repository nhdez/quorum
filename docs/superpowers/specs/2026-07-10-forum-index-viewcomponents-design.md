# Forum Index — ViewComponent design

**Date:** 2026-07-10
**Status:** Approved

## Context

`theme/theme.zip` (gitignored) contains a set of "design handoff" HTML mockups
produced by Claude Design for 9 pages of a political forum site ("The Agora
Forums"): AI Flag Log, Administration, Affiliations, Forum Index, Forum View,
Login, Register, Thread View, User Profile. Each mockup is a self-unpacking
bundle whose real payload is an inline mustache-ish template (`{{ }}`,
`sc-for`, `sc-if`) plus a JS `renderVals()` function that supplies sample
data, and a `THEMES` object with three palettes (`classic`, `dark`, `warm`)
that is byte-identical across all 9 files.

The `view_component` gem (4.12.0) is already in the Gemfile but completely
unused — no `app/components` directory exists yet. There is no CSS framework;
styling is plain Propshaft CSS. `ForumsController#index` is the untouched
Rails scaffold stub.

This spec covers **only the Forum Index page**. The masthead/nav/footer/theme
system is shared chrome that every later page (Login, Thread View, etc.) will
reuse, so it is built now as part of this pass, but no other page's content
is in scope here — those get their own spec/plan cycles.

## Goals

- Turn the Forum Index mockup into real, reusable ViewComponents.
- Render real data from `ForumCategory` → `Forum` → `ForumThread` →
  `ThreadReply` wherever the schema already supports it.
- Stand up the shared page chrome (masthead, nav, announcement bar, footer)
  and the light/dark/warm theme system, since all future pages depend on it.
- Leave clearly-isolated stubs for data that has no backing feature yet
  (political bias index, who's-online presence), so wiring them up later
  touches one method, not the components.

## Non-goals

- Any page other than Forum Index (Login, Thread View, Affiliations, etc.)
  are future missions.
- Building the actual bias-scoring/Faction-affiliation feature, or real
  user-presence tracking. These get stubbed data sources now.
- Post/thread counter caches or other perf work — plain `.count`/association
  queries are fine at current scale.

## Schema change

Add author associations, since neither exists today:

- `forum_threads.user_id` (uuid, FK to `users`, not null)
- `thread_replies.user_id` (uuid, FK to `users`, not null)
- `ForumThread belongs_to :user`, `ThreadReply belongs_to :user`
- `User has_many :forum_threads`, `User has_many :thread_replies`

Dev DB is empty, so this is a plain new migration — no backfill needed.

## Component tree

```
app/components/
  application_component.rb                     # base class < ViewComponent::Base
  ui/
    masthead_component.{rb,html.erb,css}
    nav_bar_component.{rb,html.erb,css}
    announcement_bar_component.{rb,html.erb,css}
    footer_component.{rb,html.erb,css}
    theme_toggle_component.{rb,html.erb,css}
  forums/
    bias_meter_component.{rb,html.erb,css}      # meter + 30-day sparkline
    category_panel_component.{rb,html.erb,css}  # one ForumCategory + its forums
    forum_row_component.{rb,html.erb,css}        # single forum row within a category
    latest_posts_component.{rb,html.erb,css}
    whos_online_component.{rb,html.erb,css}
    stats_panel_component.{rb,html.erb,css}

app/views/layouts/
  forum.html.erb            # Masthead + NavBar + AnnouncementBar + yield + Footer

app/views/forums/
  index.html.erb            # renders BiasMeter/CategoryPanel(s)/LatestPosts/WhosOnline/StatsPanel
```

`Ui::*` components are page-agnostic chrome, reused by every future page.
`Forums::*` components are specific to forum-index content. Components take
plain Ruby values (not ActiveRecord objects directly, except where trivial)
so they don't know or care whether their data came from the DB or a stub —
e.g. `BiasMeterComponent.new(value:, label:, history:)`.

## Data sourcing

**Real (ActiveRecord):**

- `ForumCategory.order(:index_order)`, each rendered by `CategoryPanelComponent`
- Per category, `Forum.order(:index_order)` rendered by `ForumRowComponent`
- Per forum: `threads_count` = `forum.forum_threads.count`; `posts_count` =
  replies summed across its threads
- "Last post" per forum = latest `ForumThread`/`ThreadReply` by `created_at`,
  with its real `user`. A forum with zero threads renders an explicit empty
  state ("No posts yet") — no fake data.
- `LatestPostsComponent` = real latest threads/replies site-wide, newest
  first, capped at 15
- `StatsPanelComponent` — `ForumThread.count`, reply count, `User.count`,
  and "newest member" (`User.order(:created_at).last`) are all real

**Stubbed (isolated behind one `ForumsController` method each):**

- `BiasMeterComponent` — `ForumsController#bias_meter_data` returns a
  hardcoded value/label/history for now. No `Faction` wiring yet.
- `WhosOnlineComponent` — `ForumsController#online_users_data` returns a
  small hardcoded sample list. No real presence tracking yet.

## Theming

The three `THEMES` palettes (`classic`/`dark`/`warm`) become CSS custom
properties in one stylesheet, scoped by `[data-theme="..."]` on `<html>`.
Default is `classic`. A `Ui::ThemeToggleComponent` renders the switcher; a
small Stimulus controller sets `data-theme` on `<html>` immediately (no
flash) and persists the choice in a cookie. `ApplicationController` reads
that cookie and sets `data-theme` on the server-rendered `<html>` too, so
there's no flash of the wrong theme on first paint.

## Branding

Masthead copy is changed from the mockup's "The Agora Forums" to "Quorum"
(title + tagline); rest of the visual design (layout, colors, structure)
stays as designed.

## Testing

Minitest (project default, no RSpec) + `ViewComponent::TestHelpers`. One
test per component under `test/components/`, asserting on key content/
structure for representative props — not pixel-perfect HTML matching.
`ForumsControllerTest` gets a real-data smoke test (categories/forums
render) and an empty-state test (no categories yet).

## Dev workflow

`ViewComponent::Preview` classes are added alongside each component
(visitable at `/rails/view_components` in development), each with a couple
of representative states (e.g. empty forum vs. forum with posts). This lets
components be eyeballed in isolation without seeding the dev database,
mirroring the role the original Claude "preview" mockups played.
