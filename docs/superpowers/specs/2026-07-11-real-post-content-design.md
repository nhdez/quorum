# Real Post Content — Design

**Date:** 2026-07-11
**Status:** Approved

## Context

This is sub-project 1 of 3 toward a "Fallacy Detection Module" feature the
user wants next (spec pasted in conversation). That module needs (a) real
post content to scan and (b) LLM call infrastructure — neither exists yet.
This spec covers (a) only. LLM infra is sub-project 2. Fallacy detection
itself is sub-project 3. Each gets its own design/plan/implementation pass.

Today, `ForumThread` and `ThreadReply` have no body/content column at all —
a gap flagged repeatedly since the very first Forum Index build. Forum
Index/View/Thread View currently render entirely from hardcoded sample data
in their controllers, not the real `ForumCategory`/`Forum`/`ForumThread`/
`ThreadReply` records that `db/seeds.rb` already populates. The `lexxy` gem
(a rich-text editor built on Action Text, added earlier by the user) is
bundled but unused.

## Goals

- Give `ForumThread` and `ThreadReply` real rich-text bodies (Action Text +
  Lexxy) and real authors.
- Switch Forum Index, Forum View, and Thread View from hardcoded sample data
  to real ActiveRecord data, with real routing by slug.
- Real "New Thread" and "Post Reply" forms, authenticated.

## Non-goals

- Editing existing posts (create-only this pass).
- Image/file attachments (text/rich-text only; Action Text install is still
  required as a dependency of rich text storage, attachments just aren't
  exposed in the UI).
- The political bias scanner, fallacy detection, subforums, view-count
  displays beyond a simple counter, moderator/senior-member rank tiers,
  "contested" thread badges — none of these have a real backing concept and
  are not faked here.
- LLM infrastructure (separate sub-project).

## 1. Schema & models

Migration:
- `forum_threads.user_id` (uuid, FK to `users`, not null)
- `thread_replies.user_id` (uuid, FK to `users`, not null)
- `forum_threads.views_count` (integer, default 0, not null)
- `bin/rails action_text:install` (also sets up Active Storage tables,
  required by Action Text even though attachments aren't exposed in the UI)

Models:
- `ForumThread belongs_to :user`, `has_rich_text :body`, validates presence
  of `title` and `body`
- `ThreadReply belongs_to :user`, `has_rich_text :body`, validates presence
  of `body`
- `User has_many :forum_threads`, `has_many :thread_replies`

Real-data simplifications (things the current stub UI shows with no real
backing concept — dropped or simplified rather than faked):
- "Contested" bias-split badge — dropped (belongs to the separate, still-
  fake bias scanner).
- Group/rank colors (admin/mod/senior member) — simplified to admin (via
  the real `:admin` Rolify role) vs. everyone else. No moderator or
  post-count-based rank tiers exist, so they aren't invented.
- 📌/🔥 thread markers — real: 📌 if `is_sticky`, 🔥 if reply count is 20 or
  more, else blank. (20 is an arbitrary starting threshold, easy to tune
  later.)

## 2. Real data & routing

- **Forum Index** (`ForumsController#index`): `@categories` from real
  `ForumCategory` → `Forum` associations; `@latest_posts` from real latest
  threads/replies site-wide; `@stats` from real counts (`ForumThread.count`,
  reply count, `User.count`, newest member). `BiasMeter` and `WhosOnline`
  are untouched — still stubbed, out of scope (separate systems).
- **Forum View** (`ForumsController#show`): `Forum.friendly.find(params[:id])`.
  Thread list from `forum.forum_threads.order(created_at: :desc)`, paginated
  with `Pagy` at 20 threads per page (already a gem dependency, unused until
  now) instead of the fabricated page-number array. Sub-forums section
  dropped — no subforum concept exists in the schema (`Forum` has no
  parent/child self-reference).
- **Thread View** (`ForumThreadsController#show`):
  `forum.forum_threads.friendly.find(params[:id])`. Increments
  `views_count` unconditionally on every real page view — no per-session/
  per-user dedup, so refreshing inflates the count. That's a known,
  deliberate simplification (it's a display counter, not a security- or
  billing-relevant metric); revisit if it matters later. Posts are the real
  first-post-plus-replies for that thread, paginated with `Pagy` at 20 posts
  per page (same fabricated-pagination-component-becomes-real treatment as
  Forum View). Affiliation vote bar stays decorative/stubbed — unrelated to
  post content.
- Forum Index → Forum View → Thread View links become real everywhere,
  instead of only working for one hardcoded demo forum/thread.
- Not touched this pass: Affiliations, AI Flag Log, Admin, User Profile —
  none depend on post content.

## 3. Posting UI

- **New Thread** (Forum View): title + Lexxy rich-text body, submits to
  `POST /forums/:forum_id/threads` (`:new`/`:create` added to the existing
  nested `threads` resource). Gated behind `authenticate_user!`. The
  current dead "+ New Thread" button becomes a real link to this form.
- **Post Reply** (Thread View): body only, submits to
  `POST /forums/:forum_id/threads/:id/replies` (new nested `replies`
  resource, `ThreadRepliesController#create`). The existing
  `ReplyBoxComponent` (currently a non-submitting static form) becomes real.
  Gated the same way.
- Both: inline validation errors, redirect back to the thread on success.

## Testing

Model tests for the new validations/associations. Controller/integration
tests for: real Forum Index rendering real categories/stats, Forum View
resolving by slug and paginating, Thread View resolving by slug and
incrementing views, New Thread and Post Reply both requiring auth and
persisting real records, redirect-to-login for guests attempting either.
Component tests for any component whose prop shape changes as part of the
real-data switch.
