# Forum Index — ViewComponent design

**Date:** 2026-07-10
**Status:** Approved (trimmed to a direct translation pass)

## Context

`theme/theme.zip` (gitignored) contains "design handoff" HTML mockups from
Claude Design for a political forum site. This spec covers translating the
**Forum Index** mockup into ViewComponents — nothing else.

The `view_component` gem (4.12.0) is bundled but unused — no `app/components`
directory exists yet. No CSS framework; plain Propshaft CSS.
`ForumsController#index` is the untouched Rails scaffold stub.

## Goal

Translate the Forum Index mockup's markup into ViewComponents, one component
per visual section, using the same sample data the mockup itself uses
(mirrors its `renderVals()`). No real ActiveRecord wiring, no schema changes,
no theme switcher, no previews — just get the page rendering as components.
Later passes wire real data, other pages, and any theming.

## Component tree

```
app/components/
  application_component.rb                     # base class < ViewComponent::Base
  ui/
    masthead_component.{rb,html.erb}
    nav_bar_component.{rb,html.erb}
    announcement_bar_component.{rb,html.erb}
    footer_component.{rb,html.erb}
  forums/
    bias_meter_component.{rb,html.erb}          # meter + 30-day sparkline
    category_panel_component.{rb,html.erb}      # one category + its forums
    forum_row_component.{rb,html.erb}            # single forum row within a category
    latest_posts_component.{rb,html.erb}
    whos_online_component.{rb,html.erb}
    stats_panel_component.{rb,html.erb}

app/views/layouts/
  forum.html.erb            # Masthead + NavBar + AnnouncementBar + yield + Footer

app/views/forums/
  index.html.erb            # renders BiasMeter/CategoryPanel(s)/LatestPosts/WhosOnline/StatsPanel
```

`Ui::*` is page chrome, reused by future pages. `Forums::*` is Forum-Index
content. Components take plain Ruby values as props (e.g.
`BiasMeterComponent.new(value:, label:, history:)`), not ActiveRecord
objects — so swapping stub data for real data later is a controller-only
change.

## Data

All data is hardcoded in `ForumsController#index`, copied over from the
mockup's `renderVals()` (categories/forums, latest posts, online users,
bias value, stats). "Quorum" replaces "The Agora Forums" as the masthead
branding; rest of the visual design stays as designed. Colors/theme values
are ported as-is (classic palette only, no toggle).

## Testing

Minitest (project default) + `ViewComponent::TestHelpers`. One test per
component under `test/components/`, asserting key content renders for
representative props.

## Deferred (not in this pass)

- Real ActiveRecord data (categories/forums/threads/replies from the DB)
- `forum_threads`/`thread_replies` author (`user_id`) association
- Theme switcher (dark/warm) and CSS custom properties
- ViewComponent::Preview classes
- Any page other than Forum Index
