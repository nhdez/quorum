# Real Post Content Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give `ForumThread`/`ThreadReply` real rich-text bodies and authors, switch Forum Index/View/Thread View from hardcoded sample data to real ActiveRecord data with real slug-based routing, and add real (authenticated) New Thread / Post Reply forms.

**Architecture:** Action Text (`has_rich_text :body`) for post content, edited via the already-installed Lexxy gem. Real author (`belongs_to :user`) on both post-bearing models. Controllers build the exact same hash shapes their ViewComponents already expect (established codebase convention: components take plain Ruby values, never AR objects directly) — so most existing components need zero changes; only the controllers building their data change. `Pagy` (already a Gemfile dependency, unused until now) replaces the fabricated page-number arrays.

**Tech Stack:** Rails 8.1, Action Text + Active Storage, Lexxy (rich text editor), Pagy, existing Devise/Pundit/Rolify auth.

## Global Constraints

- UUID primary keys everywhere (`config.generators.orm :active_record, primary_key_type: :uuid` is already set — new migrations get this automatically, verify each one).
- Components take plain Ruby hashes/values as props, never ActiveRecord objects directly (established convention — keep following it).
- No half-finished/dead UI: don't render controls with no real backing action (established this session — e.g. drop rather than fake).
- Every task ends green: `bin/rails test`, `bin/rubocop`, and a real page load (curl or server) before moving to the next task.
- Dev DB is freely reseedable (`bin/rails db:seed` wipes and rebuilds) — safe to add `not null` columns without a backfill step, then reseed.

---

### Task 1: User display helpers

**Files:**
- Modify: `app/models/user.rb`
- Modify: `app/components/ui/masthead_component.rb`, `app/components/ui/masthead_component.html.erb`
- Modify: `app/components/admin/top_bar_component.html.erb`
- Test: `test/models/user_test.rb`

**Interfaces:**
- Produces: `User#display_name` (String), `User#avatar_color` (String hex), `User#rank_label` (String), `User#rank_color` (String hex), `User#post_count` (Integer). All later tasks that build post/forum-row view data use these.

- [ ] **Step 1: Write the failing tests**

Replace `test/models/user_test.rb`:

```ruby
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "display_name is the email's local part" do
    user = User.new(email: "skeptical_sam@example.com")
    assert_equal "skeptical_sam", user.display_name
  end

  test "rank_label is Administrator for admins, Member otherwise" do
    user = User.create!(email: "ranktest@example.com", password: "password123", password_confirmation: "password123")
    assert_equal "Member", user.rank_label

    user.add_role(:admin)
    assert_equal "Administrator", user.rank_label
  end

  test "rank_color is red for admins, ink for everyone else" do
    user = User.create!(email: "colortest@example.com", password: "password123", password_confirmation: "password123")
    assert_equal "#1c2733", user.rank_color

    user.add_role(:admin)
    assert_equal "#c0392b", user.rank_color
  end

  test "avatar_color is deterministic for the same user" do
    user = User.create!(email: "avatartest@example.com", password: "password123", password_confirmation: "password123")
    assert_equal user.avatar_color, user.reload.avatar_color
  end

  test "post_count sums threads and replies started by the user" do
    user = User.create!(email: "postcounttest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-postcount")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-postcount")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-postcount", user: user)
    ThreadReply.create!(forum_thread: thread, user: user)

    assert_equal 2, user.post_count
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/models/user_test.rb`
Expected: FAIL — `NoMethodError: undefined method 'display_name'` (and friends), plus `ForumThread.create!` fails because `user:` isn't an association yet (that's fine, this test file already anticipates Task 2 — see note below).

Note: the `post_count` test depends on `ForumThread`/`ThreadReply` having a `user` association, which Task 2 adds. Skip running that one test for now (`bin/rails test test/models/user_test.rb -n "/display_name|rank_label|rank_color|avatar_color/"`) and come back to verify it once Task 2 lands.

- [ ] **Step 3: Implement the helpers**

Edit `app/models/user.rb`:

```ruby
class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  belongs_to :faction, optional: true

  AVATAR_COLORS = [ "#2455a4", "#7d97c2", "#1e8449", "#a85050", "#6b7aa8", "#8a8f9a", "#3f6fa0", "#9a8a3f" ].freeze

  def display_name
    email.split("@").first
  end

  def rank_label
    has_role?(:admin) ? "Administrator" : "Member"
  end

  def rank_color
    has_role?(:admin) ? "#c0392b" : "#1c2733"
  end

  def avatar_color
    AVATAR_COLORS[Zlib.crc32(id) % AVATAR_COLORS.length]
  end

  def post_count
    forum_threads.count + thread_replies.count
  end
end
```

`Zlib` is part of Ruby's standard library (already available, no new dependency) and gives a stable, deterministic hash of the UUID string.

- [ ] **Step 4: Run tests to verify the non-dependent ones pass**

Run: `bin/rails test test/models/user_test.rb -n "/display_name|rank_label|rank_color|avatar_color/"`
Expected: PASS (4 tests, `post_count` still pending Task 2)

- [ ] **Step 5: Refactor Masthead and Admin::TopBar to use it**

Edit `app/components/ui/masthead_component.rb` — replace the `display_name` method body:

```ruby
    def display_name
      current_user.display_name
    end
```

Edit `app/components/admin/top_bar_component.html.erb` line 4:

```erb
    <span class="text-[#dbe4f5] text-xs">Logged in as <b><%= current_user.display_name %></b></span>
```

- [ ] **Step 6: Run the full suite to confirm nothing broke**

Run: `bin/rails test`
Expected: all currently-passing tests still pass (the new `post_count` test still errors — expected, fixed in Task 2)

- [ ] **Step 7: Commit**

```bash
git add app/models/user.rb app/components/ui/masthead_component.rb app/components/admin/top_bar_component.html.erb test/models/user_test.rb
git commit -m "Add User display helpers (display_name, rank, avatar_color, post_count)"
```

---

### Task 2: Authorship + views_count migration

**Files:**
- Create: `db/migrate/20260711120000_add_authorship_and_views_to_threads.rb`
- Modify: `app/models/forum_thread.rb`, `app/models/thread_reply.rb`, `app/models/user.rb`
- Modify: `test/fixtures/forum_threads.yml`, `test/fixtures/thread_replies.yml`
- Test: `test/models/forum_thread_test.rb`, `test/models/thread_reply_test.rb`

**Interfaces:**
- Produces: `ForumThread#user`, `ForumThread#views_count` (Integer), `ThreadReply#user`, `User#forum_threads`, `User#thread_replies`.

- [ ] **Step 1: Write the failing tests**

Replace `test/models/forum_thread_test.rb`:

```ruby
require "test_helper"

class ForumThreadTest < ActiveSupport::TestCase
  test "belongs to a user" do
    user = User.create!(email: "threadauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-threadtest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-threadtest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-threadtest", user: user)

    assert_equal user, thread.user
  end

  test "views_count defaults to 0" do
    user = User.create!(email: "viewstest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-viewstest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-viewstest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-viewstest", user: user)

    assert_equal 0, thread.views_count
  end
end
```

Replace `test/models/thread_reply_test.rb`:

```ruby
require "test_helper"

class ThreadReplyTest < ActiveSupport::TestCase
  test "belongs to a user" do
    user = User.create!(email: "replyauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-replytest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-replytest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-replytest", user: user)
    reply = ThreadReply.create!(forum_thread: thread, user: user)

    assert_equal user, reply.user
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/models/forum_thread_test.rb test/models/thread_reply_test.rb`
Expected: FAIL — `ActiveRecord::UnknownAttributeError: unknown attribute 'user' for ForumThread` (and similarly for `ThreadReply`)

- [ ] **Step 3: Write the migration**

Create `db/migrate/20260711120000_add_authorship_and_views_to_threads.rb`:

```ruby
class AddAuthorshipAndViewsToThreads < ActiveRecord::Migration[8.1]
  def change
    add_reference :forum_threads, :user, null: false, foreign_key: true, type: :uuid
    add_column :forum_threads, :views_count, :integer, default: 0, null: false

    add_reference :thread_replies, :user, null: false, foreign_key: true, type: :uuid
  end
end
```

- [ ] **Step 4: Update the models**

Edit `app/models/forum_thread.rb`:

```ruby
class ForumThread < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :forum
  belongs_to :user
  has_many :thread_replies, dependent: :destroy
end
```

(`has_many :thread_replies` didn't exist before — check current file before editing; if it's already there, don't duplicate it.)

Edit `app/models/thread_reply.rb`:

```ruby
class ThreadReply < ApplicationRecord
  belongs_to :forum_thread
  belongs_to :user
end
```

Edit `app/models/user.rb` — add after `belongs_to :faction, optional: true`:

```ruby
  has_many :forum_threads, dependent: :destroy
  has_many :thread_replies, dependent: :destroy
```

- [ ] **Step 5: Update fixtures**

Edit `test/fixtures/forum_threads.yml` — add `user: one` / `user: two` to each entry:

```yaml
one:
  forum: one
  user: one
  title: MyString
  slug: my-string-one
  is_draft: false
  is_sticky: false
  is_visible: false
  can_be_replied_to: false
  includes_poll: false
  expires_at: 2026-07-10 18:11:56

two:
  forum: two
  user: two
  title: MyString
  slug: my-string-two
  is_draft: false
  is_sticky: false
  is_visible: false
  can_be_replied_to: false
  includes_poll: false
  expires_at: 2026-07-10 18:11:56
```

Edit `test/fixtures/thread_replies.yml`:

```yaml
one:
  forum_thread: one
  user: one
  can_be_quoted: false

two:
  forum_thread: two
  user: two
  can_be_quoted: false
```

- [ ] **Step 6: Run the migration**

Run: `bin/rails db:migrate`
Expected: `AddAuthorshipAndViewsToThreads: migrated` — verify with `bin/rails runner 'puts ActiveRecord::Base.connection.columns(:forum_threads).map(&:name)'` that `user_id` and `views_count` appear, and both are the right types (`bin/rails runner 'puts ActiveRecord::Base.connection.columns(:forum_threads).find { |c| c.name == "user_id" }.sql_type'` should print `uuid`, not `bigint`).

- [ ] **Step 7: Run tests to verify they pass**

Run: `bin/rails test test/models/forum_thread_test.rb test/models/thread_reply_test.rb test/models/user_test.rb`
Expected: PASS, all tests including the `post_count` one from Task 1

- [ ] **Step 8: Run the full suite**

Run: `bin/rails test`
Expected: some `ForumsController`/`ForumThreadsController` tests will now fail or error, because `db:seed`-created records elsewhere in fixtures/tests may not account for the new `not null` columns yet, and because Task 2 hasn't touched the controllers that build fake data — this is expected and gets fixed in Tasks 5–7. Confirm the *model* tests (Task 1 and 2's own tests) are green; don't chase controller failures yet.

- [ ] **Step 9: Commit**

```bash
git add db/migrate/20260711120000_add_authorship_and_views_to_threads.rb db/schema.rb app/models/forum_thread.rb app/models/thread_reply.rb app/models/user.rb test/fixtures/forum_threads.yml test/fixtures/thread_replies.yml test/models/forum_thread_test.rb test/models/thread_reply_test.rb
git commit -m "Add authorship (user_id) and views_count to forum_threads/thread_replies"
```

---

### Task 3: Action Text + Lexxy rich text bodies

**Files:**
- Create: two migrations via `bin/rails action_text:install` (Active Storage + Action Text tables)
- Modify: `config/importmap.rb`, `app/javascript/application.js`
- Modify: `app/models/forum_thread.rb`, `app/models/thread_reply.rb`
- Modify: `app/views/layouts/forum.html.erb`
- Test: `test/models/forum_thread_test.rb`, `test/models/thread_reply_test.rb`

**Interfaces:**
- Produces: `ForumThread#body` / `ThreadReply#body` (Action Text rich text, renders as safe HTML via `<%= post.body %>` or `<%= post[:body] %>` once assigned into a hash), both presence-validated.

- [ ] **Step 1: Write the failing tests**

Add to `test/models/forum_thread_test.rb`:

```ruby
  test "requires a title and a body" do
    user = User.create!(email: "validationtest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-validationtest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-validationtest")

    thread = ForumThread.new(forum: forum, user: user, title: "", body: "")
    assert_not thread.valid?
    assert_includes thread.errors[:title], "can't be blank"
    assert_includes thread.errors[:body], "can't be blank"
  end
```

Add to `test/models/thread_reply_test.rb`:

```ruby
  test "requires a body" do
    user = User.create!(email: "replyvalidationtest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-replyvalidationtest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-replyvalidationtest")
    thread = ForumThread.create!(forum: forum, user: user, title: "A thread", slug: "a-thread-replyvalidationtest", body: "content")

    reply = ThreadReply.new(forum_thread: thread, user: user, body: "")
    assert_not reply.valid?
    assert_includes reply.errors[:body], "can't be blank"
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/models/forum_thread_test.rb test/models/thread_reply_test.rb`
Expected: FAIL — `ArgumentError: unknown keyword: :body` (the attribute doesn't exist yet)

- [ ] **Step 3: Install Action Text**

Run: `bin/rails action_text:install`

This generates two migrations (`create_active_storage_tables.active_storage.rb`, `create_action_text_tables.action_text.rb` — both UUID-typed automatically since `primary_key_type: :uuid` is already configured), creates `app/assets/stylesheets/actiontext.css`, and appends to `config/importmap.rb` and `app/javascript/application.js`. It defaults to Trix; the next two steps swap that for Lexxy, which is already in the Gemfile and auto-registers as the Action Text editor once its JS is loaded.

- [ ] **Step 4: Swap Trix for Lexxy in the importmap**

Edit `config/importmap.rb` — the installer appended these two lines:
```ruby
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
```
Change to:
```ruby
pin "lexxy"
pin "@rails/actiontext", to: "actiontext.esm.js"
```
(Keep the `@rails/actiontext` pin — that's Action Text's attachment/content JS, separate from the Trix-vs-Lexxy editor itself.)

- [ ] **Step 5: Swap the import**

Edit `app/javascript/application.js` — the installer appended:
```js
import "trix"
import "@rails/actiontext"
```
Change to:
```js
import "lexxy"
import "@rails/actiontext"
```

- [ ] **Step 6: Add Lexxy's stylesheet to the forum layout**

Edit `app/views/layouts/forum.html.erb` — add after the existing `stylesheet_link_tag :app` line:

```erb
    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "lexxy", "data-turbo-track": "reload" %>
```

- [ ] **Step 7: Add rich text bodies to the models**

Edit `app/models/forum_thread.rb`:

```ruby
class ForumThread < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :forum
  belongs_to :user
  has_many :thread_replies, dependent: :destroy
  has_rich_text :body

  validates :title, presence: true
  validates :body, presence: true
end
```

Edit `app/models/thread_reply.rb`:

```ruby
class ThreadReply < ApplicationRecord
  belongs_to :forum_thread
  belongs_to :user
  has_rich_text :body

  validates :body, presence: true
end
```

- [ ] **Step 8: Run the migrations**

Run: `bin/rails db:migrate`
Expected: both Active Storage and Action Text tables created. Verify: `bin/rails runner 'puts ActiveRecord::Base.connection.columns(:action_text_rich_texts).find { |c| c.name == "id" }.sql_type'` prints `uuid`.

- [ ] **Step 9: Run tests to verify they pass**

Run: `bin/rails test test/models/forum_thread_test.rb test/models/thread_reply_test.rb`
Expected: PASS

- [ ] **Step 10: Rebuild Tailwind and manually verify the editor loads**

Run: `bin/rails tailwindcss:build`

Boot the server (`bin/rails server -p 3099 -d -P tmp/pids/verify.pid`, wait for `/up` to respond), then check that `lexxy.js` and the `lexxy` stylesheet actually resolve (200, not 404) — the editor itself isn't wired into a real form until Task 8, so this step only confirms the asset pipeline is correctly serving Lexxy, not that a working editor renders yet:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3099/assets/lexxy.js 2>&1 || true
```

If that 404s, check the exact digested filename via `bin/rails runner 'include ActionView::Helpers::AssetTagHelper; puts ApplicationController.helpers.javascript_importmap_tags'` and curl the real path it prints instead. Stop the server after (`kill $(cat tmp/pids/verify.pid); rm tmp/pids/verify.pid`).

- [ ] **Step 11: Commit**

```bash
git add db/migrate/*active_storage* db/migrate/*action_text* db/schema.rb config/importmap.rb app/javascript/application.js app/models/forum_thread.rb app/models/thread_reply.rb app/views/layouts/forum.html.erb app/assets/stylesheets/actiontext.css test/models/forum_thread_test.rb test/models/thread_reply_test.rb
git commit -m "Add Action Text rich-text bodies (edited via Lexxy) to threads and replies"
```

---

### Task 4: Real content in db/seeds.rb

**Files:**
- Modify: `db/seeds.rb`

**Interfaces:**
- Consumes: `ForumThread#user`, `#body`, `ThreadReply#user`, `#body` (Task 2 + 3)

- [ ] **Step 1: Update the thread/reply creation block**

Open `db/seeds.rb`. Find this block (inside the `FORUM_STRUCTURE.each_with_index` loop):

```ruby
      rand(forum_data[:threads]).times do
        thread = ForumThread.create!(
          forum: forum,
          title: Faker::Lorem.sentence(word_count: rand(4..10)).chomp("."),
          is_draft: false,
          is_sticky: rand < 0.05,
          is_visible: true,
          can_be_replied_to: true,
          includes_poll: rand < 0.1,
          created_at: Faker::Time.backward(days: 180)
        )

        reply_time_span = (Time.current - thread.created_at).to_i
        rand(forum_data[:replies]).times do
          ThreadReply.create!(
            forum_thread: thread,
            can_be_quoted: true,
            created_at: thread.created_at + rand(0..reply_time_span)
          )
        end
      end
```

Replace it with:

```ruby
      rand(forum_data[:threads]).times do
        thread = ForumThread.create!(
          forum: forum,
          user: users.sample,
          title: Faker::Lorem.sentence(word_count: rand(4..10)).chomp("."),
          body: Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n"),
          is_draft: false,
          is_sticky: rand < 0.05,
          is_visible: true,
          can_be_replied_to: true,
          includes_poll: rand < 0.1,
          views_count: rand(0..500),
          created_at: Faker::Time.backward(days: 180)
        )

        reply_time_span = (Time.current - thread.created_at).to_i
        rand(forum_data[:replies]).times do
          ThreadReply.create!(
            forum_thread: thread,
            user: users.sample,
            body: Faker::Lorem.paragraph(sentence_count: rand(1..4)),
            can_be_quoted: true,
            created_at: thread.created_at + rand(0..reply_time_span)
          )
        end
      end
```

- [ ] **Step 2: Run it**

Run: `bin/rails db:seed`
Expected: completes with the same summary line as before, no errors. Spot-check: `bin/rails runner 'puts ForumThread.first.body.to_plain_text'` prints real Faker-generated paragraph text.

- [ ] **Step 3: Commit**

```bash
git add db/seeds.rb
git commit -m "Seed real authors and rich-text bodies for threads and replies"
```

---

### Task 5: Forum Index real data

**Files:**
- Modify: `app/controllers/forums_controller.rb`
- Modify: `app/controllers/ai_flags_controller.rb`, `app/controllers/users_controller.rb` (both lose their dependency on the `GROUP_COLORS` constant this task removes from `ForumsController` — see Step 4)
- Test: `test/controllers/forums_controller_test.rb`

**Interfaces:**
- Consumes: `User#display_name`, `#rank_color`, `#avatar_color` (Task 1); `Forum#forum_threads`, `ForumThread#user`, `#views_count` (Task 2)
- Produces: no new interfaces — `@categories`, `@latest_posts`, `@stats` keep the exact hash shapes `Forums::CategoryPanelComponent`/`Forums::ForumRowComponent`/`Forums::LatestPostsComponent`/`Forums::StatsPanelComponent` already consume (unchanged components).

- [ ] **Step 1: Write the failing test**

Replace the two data-related tests in `test/controllers/forums_controller_test.rb` (keep `"should get index"`, `"should get show"` etc. as-is, only replace `"renders the forum categories"`):

```ruby
  test "renders real forum categories and stats" do
    user = User.create!(email: "indextest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Real Category", slug: "real-category-indextest", index_order: 0)
    forum = Forum.create!(forum_category: category, title: "Real Forum", slug: "real-forum-indextest", index_order: 0)
    ForumThread.create!(forum: forum, user: user, title: "Real Thread", slug: "real-thread-indextest", body: "content")

    get root_url

    assert_match "Real Category", response.body
    assert_match "Real Forum", response.body
    assert_match "Real Thread", response.body
    assert_match User.count.to_s, response.body
  end
```

Remove the old `"renders the forum categories"` test that asserted on `"Politics &amp; Current Events"` / `"Announcements &amp; News"` — those were hardcoded stub strings that won't exist once `#index` queries real data.

- [ ] **Step 2: Run the test to verify it fails**

Run: `bin/rails test test/controllers/forums_controller_test.rb`
Expected: FAIL — "Real Category" not found in response body (still rendering hardcoded stub data)

- [ ] **Step 3: Rewrite `ForumsController#index`**

Replace the entire `app/controllers/forums_controller.rb` file:

```ruby
class ForumsController < ApplicationController
  ICON_COLORS = [ "#3f9142", "#a85050", "#8a8f9a", "#3f6fa0", "#9a8a3f" ].freeze

  def index
    @nav_current = :forums
    @announcement = "Forum-wide election-year posting guidelines are now in effect — please review the updated Rules of Conduct before posting."
    @bias_value = 38
    @posts_analyzed = "3,482"
    @bias_history = [ 44, 41, 47, 52, 49, 55, 58, 53, 46, 42, 39, 44, 48, 51 ]

    @categories = ForumCategory.order(:index_order).map do |category|
      {
        name: category.title,
        forums: category.forums.order(:index_order).map { |forum| forum_row_data(forum) }
      }
    end

    @latest_posts = latest_posts_data(limit: 15)

    @online_users = [
      { name: "Admin", group_color: "#c0392b" },
      { name: "ModeratorMike", group_color: "#1e8449" },
      { name: "PoliticalJunkie88", group_color: "#2455a4" },
      { name: "popcorn_kev", group_color: "#333333" },
      { name: "newbie_nancy", group_color: "#333333" },
      { name: "greyhawk_1979", group_color: "#333333" },
      { name: "SunTzuFan", group_color: "#2455a4" },
      { name: "quietobserver", group_color: "#333333" }
    ]
    @online_summary = "There are 47 users online: 12 members, 3 hidden, 32 guests."

    @stats = {
      threads: ForumThread.count.to_s,
      posts: (ForumThread.count + ThreadReply.count).to_s,
      members: User.count.to_s,
      newest_member: User.order(created_at: :desc).first&.display_name || "—"
    }
  end

  def show
    @nav_current = :forums
    @forum = Forum.friendly.find(params[:id])

    @breadcrumb = [
      { label: "Quorum", href: root_path },
      { label: @forum.forum_category.title },
      { label: @forum.title, current: true }
    ]

    @pagy, threads = pagy(@forum.forum_threads.order(created_at: :desc), items: 20)
    @threads = threads.map { |thread| thread_row_data(thread) }
    @pages = pagy_page_links(@pagy, path: ->(page) { forum_path(@forum, page: page) })
  end

  private

  def forum_row_data(forum)
    threads_count = forum.forum_threads.count
    posts_count = threads_count + ThreadReply.joins(:forum_thread).where(forum_threads: { forum_id: forum.id }).count

    {
      name: forum.title,
      desc: forum.description,
      icon_color: ICON_COLORS[forum.index_order.to_i % ICON_COLORS.length],
      subforums: nil,
      lean: nil,
      threads: threads_count.to_s,
      posts: posts_count.to_s,
      path: forum_path(forum),
      last_post: last_post_data(forum)
    }
  end

  def last_post_data(forum)
    latest_thread = forum.forum_threads.order(created_at: :desc).first
    latest_reply = ThreadReply.joins(:forum_thread).where(forum_threads: { forum_id: forum.id }).order(created_at: :desc).first
    latest = [ latest_thread, latest_reply ].compact.max_by(&:created_at)
    return nil unless latest

    thread = latest.is_a?(ThreadReply) ? latest.forum_thread : latest
    user = latest.user

    {
      thread: thread.title,
      user: user.display_name,
      user_color: user.rank_color,
      time: helpers.time_ago_in_words(latest.created_at) + " ago",
      avatar_color: user.avatar_color,
      initial: user.display_name.first.upcase,
      path: forum_thread_path(thread.forum, thread)
    }
  end

  def latest_posts_data(limit:)
    threads = ForumThread.order(created_at: :desc).limit(limit).map { |t| { record: t, is_reply: false, title: t.title, thread: t, created_at: t.created_at, user: t.user } }
    replies = ThreadReply.includes(forum_thread: :forum).order(created_at: :desc).limit(limit).map { |r| { record: r, is_reply: true, title: r.forum_thread.title, thread: r.forum_thread, created_at: r.created_at, user: r.user } }

    (threads + replies).sort_by { |p| -p[:created_at].to_f }.first(limit).map do |p|
      {
        prefix: p[:is_reply] ? "RE:" : "",
        title: p[:title],
        user: p[:user].display_name,
        user_color: p[:user].rank_color,
        time: helpers.time_ago_in_words(p[:created_at]) + " ago",
        path: forum_thread_path(p[:thread].forum, p[:thread])
      }
    end
  end

  def thread_row_data(thread)
    replies_count = thread.thread_replies.count
    last = thread.thread_replies.order(created_at: :desc).first || thread

    {
      marker: thread.is_sticky? ? "📌" : (replies_count >= 20 ? "🔥" : nil),
      slug: thread.slug,
      title: thread.title,
      contested: false,
      author: thread.user.display_name,
      author_color: thread.user.rank_color,
      replies: replies_count.to_s,
      views: thread.views_count.to_s,
      last_post: {
        user: last.user.display_name,
        user_color: last.user.rank_color,
        time: helpers.time_ago_in_words(last.created_at) + " ago",
        avatar_color: last.user.avatar_color,
        initial: last.user.display_name.first.upcase
      }
    }
  end
end
```

Note: `#show` here is a placeholder pending Task 6, which adds `pagy`/`pagy_page_links` (not defined yet) and finishes the Forum View real-data switch. This task's `#show` rewrite is included now because `thread_row_data` and `forum_row_data` are shared; Task 6 will only need to add the `Pagy::Backend` include and `pagy_page_links` helper.

- [ ] **Step 4: Fix the two other controllers that depend on the constant just removed**

`AiFlagsController` and `UsersController` (both out of scope for this feature — AI Flag Log and User Profile don't depend on post content) currently declare `GROUP_COLORS = ForumsController::GROUP_COLORS`, which just broke since `ForumsController` no longer defines that constant. Confirm the breakage first:

```bash
grep -rn "ForumsController::GROUP_COLORS" app/
```

Expected output: two matches, `app/controllers/ai_flags_controller.rb:2` and `app/controllers/users_controller.rb:2`.

Edit `app/controllers/ai_flags_controller.rb` line 2 — change:

```ruby
  GROUP_COLORS = ForumsController::GROUP_COLORS
```

to:

```ruby
  GROUP_COLORS = { admin: "#c0392b", mod: "#1e8449", senior: "#2455a4", member: "#333333" }.freeze
```

Edit `app/controllers/users_controller.rb` line 2 — same change:

```ruby
  GROUP_COLORS = { admin: "#c0392b", mod: "#1e8449", senior: "#2455a4", member: "#333333" }.freeze
```

Run: `bin/rails test test/controllers/ai_flags_controller_test.rb test/controllers/users_controller_test.rb`
Expected: PASS (these controllers' own tests were passing before Task 5 and should be unaffected by this fix — it only restores what Task 5 broke)

- [ ] **Step 5: Run the test — expect it to still fail on `#show`**

Run: `bin/rails test test/controllers/forums_controller_test.rb`
Expected: the new `"renders real forum categories and stats"` test (which only hits `#index`) should PASS. `"should get show"` will ERROR — `NoMethodError: undefined method 'pagy'` — that's expected, fixed in Task 6. Confirm specifically:

```bash
bin/rails test test/controllers/forums_controller_test.rb -n "/index|categories/"
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/controllers/forums_controller.rb app/controllers/ai_flags_controller.rb app/controllers/users_controller.rb test/controllers/forums_controller_test.rb
git commit -m "Switch Forum Index to real ActiveRecord data"
```

---

### Task 6: Pagy + Forum View real data

> **Execution note:** the installed `pagy` gem (43.6.0) turned out to be a
> complete architectural rewrite of the version this plan assumed —
> `Pagy::Backend`/`.series` don't exist; the new API centers on
> `Pagy::Offset.new(count:, page:)` plus a separate opinionated HTML-nav
> helper system that doesn't hand back a plain array to consume. Rather than
> learn that surface under time pressure, `ApplicationController` got a
> ~20-line hand-rolled `paginate`/`page_links` pair instead (plain
> LIMIT/OFFSET, same `{label:, href:, current:}` shape `Ui::PaginationComponent`
> already expects). The `pagy`/`pagy_page_links` method names below are
> stale — read `paginate`/`page_links` wherever they appear in this task
> and Task 7.

**Files:**
- Modify: `app/controllers/application_controller.rb`
- Modify: `app/controllers/forums_controller.rb` (already partially done in Task 5 — this task adds the missing pieces)
- Modify: `config/routes.rb`
- Modify: `app/components/forums/forum_header_component.rb`, `app/components/forums/forum_header_component.html.erb`
- Modify: `app/views/forums/show.html.erb`
- Test: `test/controllers/forums_controller_test.rb`, `test/components/forums/forum_header_component_test.rb`

**Interfaces:**
- Produces: `ApplicationController#pagy` (from `Pagy::Backend`), `ApplicationController#pagy_page_links(pagy, path:)` → Array of `{label:, href:, current:}` hashes (same shape `Ui::PaginationComponent` already expects — no component change needed there). Also produces the `new`/`create` routes for `forum_threads` (route only — actions land in Task 7, view in Task 8).
- Consumes: `Forums::ForumHeaderComponent` gains a `new_thread_path:` and `current_user:` prop

- [ ] **Step 1: Write the failing tests**

Replace the `"should get show"` and `"renders the forum's threads"` tests in `test/controllers/forums_controller_test.rb`:

```ruby
  test "should get show" do
    category = ForumCategory.create!(title: "Show Cat", slug: "show-cat-controllertest")
    forum = Forum.create!(forum_category: category, title: "Show Forum", slug: "show-forum-controllertest")

    get forum_url(forum)
    assert_response :success
  end

  test "renders the forum's real threads" do
    user = User.create!(email: "showthreadtest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Show Cat 2", slug: "show-cat-2-controllertest")
    forum = Forum.create!(forum_category: category, title: "Show Forum 2", slug: "show-forum-2-controllertest")
    ForumThread.create!(forum: forum, user: user, title: "Real Thread Title", slug: "real-thread-title-controllertest", body: "content")

    get forum_url(forum)

    assert_match "Real Thread Title", response.body
    assert_match user.display_name, response.body
  end
```

Delete the old `"should get show"`/`"renders the forum's threads"` tests that used `forum_url(id: "politics-current-events")` — that hardcoded demo forum no longer exists.

Add to `test/components/forums/forum_header_component_test.rb` (new test, keep the existing ones):

```ruby
    test "links + New Thread to the real path when signed in" do
      user = User.create!(email: "headertest@example.com", password: "password123", password_confirmation: "password123")
      render_inline(ForumHeaderComponent.new(title: "T", description: "D", new_thread_path: "/forums/x/threads/new", current_user: user))

      assert_selector "a[href='/forums/x/threads/new']", text: "+ New Thread"
    end

    test "shows a login prompt when signed out" do
      render_inline(ForumHeaderComponent.new(title: "T", description: "D", new_thread_path: "/forums/x/threads/new", current_user: nil))

      assert_selector "a", text: "Log in to post"
    end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/controllers/forums_controller_test.rb test/components/forums/forum_header_component_test.rb`
Expected: FAIL — `NoMethodError: undefined method 'pagy'` on the controller tests, `ArgumentError: unknown keyword: :new_thread_path` on the component tests

- [ ] **Step 3: Add Pagy to ApplicationController**

Edit `app/controllers/application_controller.rb` — replace the whole file:

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  layout "forum"

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def user_not_authorized
    redirect_to root_path, alert: "You are not authorized to do that."
  end

  # Builds a « 1 2 3 … N » page list for Ui::PaginationComponent from a real Pagy object.
  def pagy_page_links(pagy, path:)
    links = []
    links << { label: "«", href: path.call(pagy.prev) } if pagy.prev
    pagy.series.each do |item|
      case item
      when Integer then links << { label: item.to_s, href: path.call(item) }
      when String then links << { label: item, current: true }
      when :gap then links << { label: "…" }
      end
    end
    links << { label: "»", href: path.call(pagy.next) } if pagy.next
    links
  end
end
```

This replaces the old `pagination_pages(current:, last:)` helper entirely — it's no longer called anywhere after this task and Task 7.

- [ ] **Step 4: Update `Forums::ForumHeaderComponent`**

Replace `app/components/forums/forum_header_component.rb`:

```ruby
module Forums
  class ForumHeaderComponent < ApplicationComponent
    def initialize(title:, description:, subforums: [], new_thread_path: nil, current_user: nil)
      @title = title
      @description = description
      @subforums = subforums
      @new_thread_path = new_thread_path
      @current_user = current_user
    end

    attr_reader :title, :description, :subforums, :new_thread_path, :current_user
  end
end
```

Replace `app/components/forums/forum_header_component.html.erb`:

```erb
<div class="border border-line rounded-[4px] mb-3.5 bg-row overflow-hidden shadow-sm">
  <div class="bg-linear-to-b from-panel-from to-panel-to px-4 py-3 text-panel-heading flex justify-between items-center flex-wrap gap-2.5">
    <div>
      <div class="font-bold text-base"><%= title %></div>
      <div class="text-[11px] opacity-90 mt-0.5"><%= description %></div>
    </div>
    <% if current_user %>
      <%= link_to "+ New Thread", new_thread_path, class: "px-3.5 py-1.5 border border-register-line rounded-[3px] bg-register text-white text-xs font-bold [font-family:inherit] whitespace-nowrap hover:opacity-90" %>
    <% else %>
      <%= link_to "Log in to post", new_user_session_path, class: "px-3.5 py-1.5 border border-line rounded-[3px] bg-row-alt text-ink text-xs font-bold [font-family:inherit] whitespace-nowrap hover:bg-line" %>
    <% end %>
  </div>

  <% if subforums.present? %>
    <div class="px-4 py-2 text-[11px] text-muted border-b border-line">
      Sub-boards:
      <% subforums.each_with_index do |name, i| %>
        <a href="#" class="text-link ml-1 hover:underline"><%= name %></a><%= "," if i < subforums.length - 1 %>
      <% end %>
    </div>
  <% end %>
</div>
```

- [ ] **Step 5: Add the New Thread route early**

`Forums::ForumHeaderComponent`'s "+ New Thread" link (below) needs `new_forum_thread_path` to exist. The controller action behind it isn't implemented until Task 7 and its view not until Task 8, but the *route* only needs to exist for the path helper to generate a URL — nothing in this task's tests actually visits that URL, so this is safe to add now rather than forward-reference a route that doesn't exist yet.

Edit `config/routes.rb` — change:

```ruby
  resources :forums, only: %i[index show] do
    resources :threads, only: %i[show], controller: "forum_threads"
  end
```

to:

```ruby
  resources :forums, only: %i[index show] do
    resources :threads, only: %i[show new create], controller: "forum_threads"
  end
```

(Task 8 will find this already done and doesn't need to repeat it.)

- [ ] **Step 6: Update the Forum View template**

Replace `app/views/forums/show.html.erb`:

```erb
<%= render Ui::BreadcrumbComponent.new(items: @breadcrumb) %>

<%= render Forums::ForumHeaderComponent.new(title: @forum.title, description: @forum.description, new_thread_path: new_forum_thread_path(@forum), current_user: current_user) %>

<%= render Forums::ThreadListComponent.new(threads: @threads, thread_path: ->(thread_data) { forum_thread_path(@forum, thread_data[:slug]) }) %>

<%= render Ui::PaginationComponent.new(pages: @pages) %>
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `bin/rails test test/controllers/forums_controller_test.rb test/components/forums/forum_header_component_test.rb`
Expected: PASS

- [ ] **Step 8: Run the full suite**

Run: `bin/rails test`
Expected: `ForumThreadsController` tests still fail/error (Task 7 fixes those) — everything else passes.

- [ ] **Step 9: Commit**

```bash
git add app/controllers/application_controller.rb app/controllers/forums_controller.rb app/components/forums/forum_header_component.rb app/components/forums/forum_header_component.html.erb app/views/forums/show.html.erb test/controllers/forums_controller_test.rb test/components/forums/forum_header_component_test.rb
git commit -m "Add real Pagy pagination and wire Forum View to real thread data"
```

---

### Task 7: Thread View real data

**Files:**
- Modify: `app/controllers/forum_threads_controller.rb`
- Modify: `app/components/threads/post_component.html.erb`
- Modify: `app/views/forum_threads/show.html.erb`
- Test: `test/controllers/forum_threads_controller_test.rb`, `test/components/threads/post_component_test.rb`

**Interfaces:**
- Consumes: `User#display_name`, `#rank_label`, `#rank_color`, `#avatar_color`, `#post_count` (Task 1); `ForumThread#body`, `#views_count`, `ThreadReply#body` (Tasks 2–3); `ApplicationController#pagy`, `#pagy_page_links` (Task 6)

- [ ] **Step 1: Write the failing tests**

Replace `test/controllers/forum_threads_controller_test.rb`:

```ruby
require "test_helper"

class ForumThreadsControllerTest < ActionDispatch::IntegrationTest
  def create_thread_with_reply
    author = User.create!(email: "threadviewauthor@example.com", password: "password123", password_confirmation: "password123")
    replier = User.create!(email: "threadviewreplier@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "TV Cat", slug: "tv-cat-threadviewtest")
    forum = Forum.create!(forum_category: category, title: "TV Forum", slug: "tv-forum-threadviewtest")
    thread = ForumThread.create!(forum: forum, user: author, title: "Real Thread View Title", slug: "real-thread-view-title", body: "The original post body.")
    ThreadReply.create!(forum_thread: thread, user: replier, body: "A real reply body.")
    [ forum, thread ]
  end

  test "should get show" do
    forum, thread = create_thread_with_reply
    get forum_thread_url(forum, thread)
    assert_response :success
  end

  test "renders the thread's real posts" do
    forum, thread = create_thread_with_reply

    get forum_thread_url(forum, thread)

    assert_match "Real Thread View Title", response.body
    assert_match "The original post body.", response.body
    assert_match "A real reply body.", response.body
    assert_match "threadviewauthor", response.body
    assert_match "threadviewreplier", response.body
  end

  test "increments views_count on each view" do
    forum, thread = create_thread_with_reply

    assert_difference -> { thread.reload.views_count }, 1 do
      get forum_thread_url(forum, thread)
    end
  end
end
```

Replace `test/components/threads/post_component_test.rb` — remove the `reputation` field from `base_post` (it no longer exists) and drop any assertion mentioning it:

```ruby
require "test_helper"

module Threads
  class PostComponentTest < ViewComponent::TestCase
    def base_post
      {
        user: "PoliticalJunkie88", user_color: "#2455a4", rank: "Senior Member",
        avatar_color: "#2455a4", initial: "P", joined: "Mar 2019", post_count: "4,821",
        time: "Today, 08:02 AM", number: "1", highlighted: false,
        affiliation_name: nil, affiliation_color: nil, is_devils_advocate: false,
        ai_flag_reason: nil, signature: nil, body: "Hello world."
      }
    end

    test "renders the author, post body, and post number" do
      render_inline(PostComponent.new(post: base_post))

      assert_text "PoliticalJunkie88"
      assert_text "Hello world."
      assert_text "Post #1"
    end

    test "renders the affiliation badge only when present" do
      render_inline(PostComponent.new(post: base_post.merge(affiliation_name: "Progressive Alliance", affiliation_color: "#6b4fa0")))
      assert_text "Progressive Alliance"

      render_inline(PostComponent.new(post: base_post))
      assert_no_text "Progressive Alliance"
    end

    test "renders the Devil's Advocate badge only when flagged" do
      render_inline(PostComponent.new(post: base_post.merge(is_devils_advocate: true)))
      assert_text "Devil's Advocate"
    end

    test "renders the AI flag notice only when a reason is given" do
      render_inline(PostComponent.new(post: base_post.merge(ai_flag_reason: "Reads like an ad hominem.")))

      assert_text "AI Flag:"
      assert_text "Reads like an ad hominem."
    end

    test "renders the signature only when present" do
      render_inline(PostComponent.new(post: base_post.merge(signature: "Some signature.")))
      assert_text "Some signature."
    end

    test "does not render a reputation line" do
      render_inline(PostComponent.new(post: base_post))
      assert_no_text "Reputation"
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/controllers/forum_threads_controller_test.rb test/components/threads/post_component_test.rb`
Expected: controller tests FAIL (still rendering hardcoded "Midterm predictions thread" stub data); the new `"does not render a reputation line"` component test FAILS (template still has the line)

- [ ] **Step 3: Rewrite `ForumThreadsController`**

Replace `app/controllers/forum_threads_controller.rb`:

```ruby
class ForumThreadsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  AFFILIATIONS = [
    { id: "progressive", name: "Progressive Alliance", color: "#6b4fa0", votes: 214 },
    { id: "liberty", name: "Liberty Caucus", color: "#a0524f", votes: 176 },
    { id: "centrist", name: "Centrist Coalition", color: "#4f8aa0", votes: 98 },
    { id: "independent", name: "Independent", color: "#7a7a7a", votes: 41 }
  ].freeze

  def show
    @nav_current = :forums
    forum = Forum.friendly.find(params[:forum_id])
    thread = forum.forum_threads.friendly.find(params[:id])
    thread.increment!(:views_count)

    @breadcrumb = [
      { label: "Quorum", href: root_path },
      { label: forum.title, href: forum_path(forum) },
      { label: thread.title, current: true }
    ]

    @thread_title = thread.title

    total_votes = AFFILIATIONS.sum { |a| a[:votes] }
    @vote_choices = AFFILIATIONS.map { |a| a.merge(pct: total_votes.positive? ? ((a[:votes].to_f / total_votes) * 100).round : 0) }
    @vote_total = total_votes

    @pagy, replies = pagy(thread.thread_replies.order(:created_at), items: 20)
    @posts = [ post_view_data(thread, number: 1) ] + replies.each_with_index.map { |reply, i| post_view_data(reply, number: i + 2) }
    @pages = pagy_page_links(@pagy, path: ->(page) { forum_thread_path(forum, thread, page: page) })
  end

  def new
    @forum = Forum.friendly.find(params[:forum_id])
    @thread = @forum.forum_threads.build
  end

  def create
    @forum = Forum.friendly.find(params[:forum_id])
    @thread = @forum.forum_threads.build(thread_params)
    @thread.user = current_user

    if @thread.save
      redirect_to forum_thread_path(@forum, @thread), notice: "Thread created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def thread_params
    params.require(:forum_thread).permit(:title, :body)
  end

  def post_view_data(post, number:)
    user = post.user

    {
      user: user.display_name,
      user_color: user.rank_color,
      rank: user.rank_label,
      avatar_color: user.avatar_color,
      initial: user.display_name.first.upcase,
      joined: user.created_at.strftime("%b %Y"),
      post_count: user.post_count.to_s,
      time: post.created_at.strftime("%b %-d, %Y %l:%M %p").squeeze(" "),
      number: number.to_s,
      highlighted: user.has_role?(:admin),
      affiliation_name: user.faction&.name,
      affiliation_color: user.faction&.color,
      is_devils_advocate: false,
      ai_flag_reason: nil,
      signature: nil,
      body: post.body
    }
  end
end
```

(`:new` and `:create` actions are here so this whole controller lands as one coherent unit — they're not routable yet until Task 8 adds the routes, and won't be hit by any test until then either.)

- [ ] **Step 4: Remove the Reputation line from `PostComponent`**

Edit `app/components/threads/post_component.html.erb` — delete this line (currently line 22):

```erb
        <div>Reputation: <%= post[:reputation] %></div>
```

Also update the body rendering to drop `whitespace-pre-line` (real Action Text content has real `<p>` tags now, not literal `\n\n`) and add paragraph spacing. Change:

```erb
    <div class="text-[13px] flex-1 whitespace-pre-line"><%= post[:body] %></div>
```

to:

```erb
    <div class="text-[13px] flex-1 [&_p]:mb-3 [&_p:last-child]:mb-0"><%= post[:body] %></div>
```

- [ ] **Step 5: Update the Thread View template**

Replace `app/views/forum_threads/show.html.erb`:

```erb
<%= render Ui::BreadcrumbComponent.new(items: @breadcrumb) %>

<%= render Threads::TitleBarComponent.new(title: @thread_title) %>
<%= render Threads::VoteBarComponent.new(choices: @vote_choices, total: @vote_total) %>
<%= render Threads::PostListComponent.new(posts: @posts) %>

<%= render Ui::PaginationComponent.new(pages: @pages) %>
```

(No reply box yet — that's Task 9's job, once `Threads::ReplyBoxComponent` actually accepts a `reply_path:`. Dropping it here rather than half-wiring a broken reference.)

- [ ] **Step 6: Promote `forum`/`thread` to instance variables**

`ForumThreadsController#show` (Step 3) uses local variables `forum`/`thread`. Task 9's view needs `@forum`/`@thread` to build the reply form's URL, so promote them now rather than touching this method a third time later:

```ruby
  def show
    @nav_current = :forums
    @forum = Forum.friendly.find(params[:forum_id])
    @thread = @forum.forum_threads.friendly.find(params[:id])
    @thread.increment!(:views_count)

    @breadcrumb = [
      { label: "Quorum", href: root_path },
      { label: @forum.title, href: forum_path(@forum) },
      { label: @thread.title, current: true }
    ]

    @thread_title = @thread.title

    total_votes = AFFILIATIONS.sum { |a| a[:votes] }
    @vote_choices = AFFILIATIONS.map { |a| a.merge(pct: total_votes.positive? ? ((a[:votes].to_f / total_votes) * 100).round : 0) }
    @vote_total = total_votes

    @pagy, replies = pagy(@thread.thread_replies.order(:created_at), items: 20)
    @posts = [ post_view_data(@thread, number: 1) ] + replies.each_with_index.map { |reply, i| post_view_data(reply, number: i + 2) }
    @pages = pagy_page_links(@pagy, path: ->(page) { forum_thread_path(@forum, @thread, page: page) })
  end
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `bin/rails test test/controllers/forum_threads_controller_test.rb test/components/threads/post_component_test.rb`
Expected: PASS

- [ ] **Step 8: Run the full suite**

Run: `bin/rails test`
Expected: all green except any test still referencing the old `ForumsController::GROUP_COLORS` constant (search for it: `grep -rn "GROUP_COLORS" app/ test/`) — `ForumThreadsController` no longer defines `GROUP_COLORS = ForumsController::GROUP_COLORS` since `ForumsController` dropped that constant in Task 5. If anything still references `ForumsController::GROUP_COLORS` or `ForumThreadsController::GROUP_COLORS`, replace those usages with the real per-user values (`user.rank_color`, etc.) they were standing in for, or remove them if dead.

- [ ] **Step 9: Commit**

```bash
git add app/controllers/forum_threads_controller.rb app/components/threads/post_component.html.erb app/views/forum_threads/show.html.erb test/controllers/forum_threads_controller_test.rb test/components/threads/post_component_test.rb
git commit -m "Switch Thread View to real posts, real pagination, and real view counts"
```

---

### Task 8: New Thread form

**Files:**
- Create: `app/views/forum_threads/new.html.erb`
- Test: `test/controllers/forum_threads_controller_test.rb`

**Interfaces:**
- Consumes: `ForumThreadsController#new`/`#create` (Task 7), `ForumThread` validations (Task 3), the `new`/`create` routes (Task 6)

- [ ] **Step 1: Write the failing tests**

Add to `test/controllers/forum_threads_controller_test.rb`:

```ruby
  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
  end

  test "guests are redirected to login when trying to start a new thread" do
    forum, _thread = create_thread_with_reply
    get new_forum_thread_url(forum)
    assert_redirected_to new_user_session_path
  end

  test "a signed-in user can create a real thread" do
    forum, _thread = create_thread_with_reply
    user = User.create!(email: "newthreadcreator@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_difference "ForumThread.count", 1 do
      post forum_threads_url(forum), params: { forum_thread: { title: "A brand new thread", body: "Its opening post." } }
    end

    new_thread = ForumThread.order(:created_at).last
    assert_equal user, new_thread.user
    assert_redirected_to forum_thread_path(forum, new_thread)
  end

  test "creating a thread with a blank title re-renders the form" do
    forum, _thread = create_thread_with_reply
    user = User.create!(email: "badthreadcreator@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_no_difference "ForumThread.count" do
      post forum_threads_url(forum), params: { forum_thread: { title: "", body: "Body without a title." } }
    end

    assert_response :unprocessable_content
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/controllers/forum_threads_controller_test.rb`
Expected: FAIL — `ActionView::MissingTemplate` for `forum_threads/new`. The route and controller actions already exist (added in Task 6 Step 5 and Task 7 Step 3 respectively) — only the view is missing.

- [ ] **Step 3: Write the New Thread view**

Create `app/views/forum_threads/new.html.erb`:

```erb
<%= render Ui::BreadcrumbComponent.new(items: [
  { label: "Quorum", href: root_path },
  { label: @forum.title, href: forum_path(@forum) },
  { label: "New Thread", current: true }
]) %>

<%= render Ui::PanelComponent.new(title: "Start a New Thread") do %>
  <div class="p-5 flex flex-col gap-3.5">
    <%= render "devise/shared/error_messages", resource: @thread %>

    <%= form_with model: @thread, url: forum_threads_path(@forum) do |f| %>
      <div class="mb-3.5">
        <div class="text-[11px] font-bold text-muted mb-1">TITLE</div>
        <%= f.text_field :title, class: "w-full box-border p-2 border border-line rounded-[3px] [font-family:inherit] text-[13px]" %>
      </div>

      <div class="mb-3.5">
        <div class="text-[11px] font-bold text-muted mb-1">BODY</div>
        <%= f.rich_textarea :body %>
      </div>

      <%= f.submit "Create Thread", class: "py-2.5 px-4 border border-register-line rounded-[3px] bg-register text-white text-[13px] font-bold cursor-pointer [font-family:inherit] hover:opacity-90" %>
    <% end %>
  </div>
<% end %>
```

`render "devise/shared/error_messages", resource: @thread` reuses the existing partial from `app/views/devise/shared/_error_messages.html.erb` — it just calls `resource.errors`, so it works for any model, not just Devise resources.

- [ ] **Step 4: Run tests to verify they pass**

Run: `bin/rails test test/controllers/forum_threads_controller_test.rb`
Expected: PASS

- [ ] **Step 5: Manually verify the Lexxy editor actually renders**

Boot the server, sign in as a seeded user (`bin/rails runner 'puts User.first.email'` for a real seeded address, password is `password123` for all seeds), and load `/forums/<any-real-forum-slug>/threads/new`. Confirm via curl that the page 200s and contains a `<trix-editor>` or Lexxy-specific custom element tag (check the actual rendered tag name — Lexxy's `rich_textarea` helper may render a different custom element than Trix's `<trix-editor>`; inspect the response body for whatever tag `f.rich_textarea` actually emits and confirm it's present):

```bash
curl -s http://localhost:3099/forums/<slug>/threads/new | grep -o '<[a-z-]*-editor[^>]*>' | head -3
```

If nothing matches, grep more broadly for `lexxy` or `action-text` in the response body to find the actual element name, and note it — this is a real integration point that needs eyes-on verification, not just an assumption. Stop the server after.

- [ ] **Step 6: Commit**

```bash
git add config/routes.rb app/views/forum_threads/new.html.erb test/controllers/forum_threads_controller_test.rb
git commit -m "Add real New Thread form"
```

---

### Task 9: Post Reply form

> **Execution note:** `f.rich_textarea` only works inside a real Rails view
> (Task 8's New Thread form), not inside a ViewComponent template. Lexxy
> resolves via `ActionText::TagHelper` (with its own tag helper prepended
> onto it) plus `main_app`, neither of which `ViewComponent::Base` includes
> by default. Fixed with two additions to `app/components/application_component.rb`:
> `include ActionText::TagHelper` and `delegate :main_app, to: :helpers`.
> This is a one-time fix — any future component using `f.rich_textarea`
> benefits from it automatically.

**Files:**
- Create: `app/controllers/thread_replies_controller.rb`
- Modify: `app/components/application_component.rb`
- Modify: `config/routes.rb`
- Modify: `app/components/threads/reply_box_component.rb`, `app/components/threads/reply_box_component.html.erb`
- Modify: `app/views/forum_threads/show.html.erb`
- Test: `test/controllers/thread_replies_controller_test.rb`, `test/components/threads/reply_box_component_test.rb`

**Interfaces:**
- Consumes: `@forum`, `@thread` (Task 7)

- [ ] **Step 1: Write the failing tests**

Create `test/controllers/thread_replies_controller_test.rb`:

```ruby
require "test_helper"

class ThreadRepliesControllerTest < ActionDispatch::IntegrationTest
  def create_thread
    author = User.create!(email: "replycontrollerauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Reply Cat", slug: "reply-cat-controllertest")
    forum = Forum.create!(forum_category: category, title: "Reply Forum", slug: "reply-forum-controllertest")
    thread = ForumThread.create!(forum: forum, user: author, title: "Reply Test Thread", slug: "reply-test-thread-controllertest", body: "OP body.")
    [ forum, thread ]
  end

  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
  end

  test "guests are redirected to login" do
    forum, thread = create_thread
    post forum_thread_thread_replies_url(forum, thread), params: { thread_reply: { body: "A reply." } }
    assert_redirected_to new_user_session_path
  end

  test "a signed-in user can post a real reply" do
    forum, thread = create_thread
    user = User.create!(email: "replycontrolleruser@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_difference "ThreadReply.count", 1 do
      post forum_thread_thread_replies_url(forum, thread), params: { thread_reply: { body: "A real reply." } }
    end

    reply = ThreadReply.order(:created_at).last
    assert_equal user, reply.user
    assert_redirected_to forum_thread_path(forum, thread)
  end

  test "posting a blank reply redirects back with an error" do
    forum, thread = create_thread
    user = User.create!(email: "badreplycontrolleruser@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_no_difference "ThreadReply.count" do
      post forum_thread_thread_replies_url(forum, thread), params: { thread_reply: { body: "" } }
    end

    assert_redirected_to forum_thread_path(forum, thread)
    follow_redirect!
    assert_match "can&#39;t be blank", response.body
  end
end
```

Replace `test/components/threads/reply_box_component_test.rb`:

```ruby
require "test_helper"

module Threads
  class ReplyBoxComponentTest < ViewComponent::TestCase
    test "renders a real form posting to the given reply path" do
      render_inline(ReplyBoxComponent.new(reply_path: "/forums/x/threads/y/replies"))

      assert_selector "form[action='/forums/x/threads/y/replies']"
      assert_selector "button", text: "Post Reply"
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/controllers/thread_replies_controller_test.rb test/components/threads/reply_box_component_test.rb`
Expected: FAIL — routing errors (no route for `forum_thread_thread_replies_url`) and `ArgumentError: unknown keyword: :reply_path`

- [ ] **Step 3: Update routes**

Edit `config/routes.rb` — change:

```ruby
  resources :forums, only: %i[index show] do
    resources :threads, only: %i[show new create], controller: "forum_threads"
  end
```

to:

```ruby
  resources :forums, only: %i[index show] do
    resources :threads, only: %i[show new create], controller: "forum_threads" do
      resources :thread_replies, only: %i[create]
    end
  end
```

This produces `forum_thread_thread_replies_path(forum, thread)` — matches the tests above. (It's a slightly clunky path helper name because both the parent and child resources are called "threads"/"thread_replies"; that's fine, it's what Rails generates and it's what the tests assert against.)

- [ ] **Step 4: Write `ThreadRepliesController`**

Create `app/controllers/thread_replies_controller.rb`:

```ruby
class ThreadRepliesController < ApplicationController
  before_action :authenticate_user!

  def create
    forum = Forum.friendly.find(params[:forum_id])
    thread = forum.forum_threads.friendly.find(params[:thread_id])
    reply = thread.thread_replies.build(reply_params)
    reply.user = current_user

    if reply.save
      redirect_to forum_thread_path(forum, thread), notice: "Reply posted."
    else
      redirect_to forum_thread_path(forum, thread), alert: reply.errors.full_messages.to_sentence
    end
  end

  private

  def reply_params
    params.require(:thread_reply).permit(:body)
  end
end
```

- [ ] **Step 5: Update `Threads::ReplyBoxComponent`**

Replace `app/components/threads/reply_box_component.rb`:

```ruby
module Threads
  class ReplyBoxComponent < ApplicationComponent
    def initialize(reply_path:)
      @reply_path = reply_path
    end

    attr_reader :reply_path
  end
end
```

Replace `app/components/threads/reply_box_component.html.erb` — this drops the static B/I/U/link/image toolbar icons since Lexxy's editor provides its own real toolbar (those static spans were decorative filler for the non-functional stub and would now sit above a real editor that already has one):

```erb
<%= render Ui::PanelComponent.new(title: "Post a Reply") do %>
  <div class="p-3.5">
    <%= form_with model: ThreadReply.new, url: reply_path do |f| %>
      <%= f.rich_textarea :body %>
      <div class="flex justify-end mt-2.5">
        <%= f.submit "Post Reply", class: "px-4.5 py-2 border border-register-line rounded-[3px] bg-register text-white text-xs font-bold cursor-pointer [font-family:inherit] hover:opacity-90" %>
      </div>
    <% end %>
  </div>
<% end %>
```

- [ ] **Step 6: Wire it into Thread View**

Edit `app/views/forum_threads/show.html.erb` — replace the whole file:

```erb
<%= render Ui::BreadcrumbComponent.new(items: @breadcrumb) %>

<%= render Threads::TitleBarComponent.new(title: @thread_title) %>
<%= render Threads::VoteBarComponent.new(choices: @vote_choices, total: @vote_total) %>
<%= render Threads::PostListComponent.new(posts: @posts) %>

<%= render Ui::PaginationComponent.new(pages: @pages) %>

<% if current_user %>
  <%= render Threads::ReplyBoxComponent.new(reply_path: forum_thread_thread_replies_path(@forum, @thread)) %>
<% else %>
  <div class="text-xs text-muted my-4"><%= link_to "Log in", new_user_session_path, class: "text-link hover:underline" %> to reply to this thread.</div>
<% end %>
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `bin/rails test test/controllers/thread_replies_controller_test.rb test/components/threads/reply_box_component_test.rb test/controllers/forum_threads_controller_test.rb`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add app/controllers/thread_replies_controller.rb config/routes.rb app/components/threads/reply_box_component.rb app/components/threads/reply_box_component.html.erb app/views/forum_threads/show.html.erb test/controllers/thread_replies_controller_test.rb test/components/threads/reply_box_component_test.rb
git commit -m "Add real Post Reply form"
```

---

### Task 10: Full verification pass

**Files:** none (verification only)

- [ ] **Step 1: Run the full test suite**

Run: `bin/rails test`
Expected: 100% pass, zero errors

- [ ] **Step 2: Rubocop**

Run: `bin/rubocop app/ test/ db/migrate config/routes.rb`
Expected: no offenses (autocorrect anything trivial with `-A`, re-run tests after)

- [ ] **Step 3: Brakeman**

Run: `bin/brakeman -q --no-pager`
Expected: 0 security warnings — pay particular attention to any `MassAssignment` or `SQL` warnings given the new `_params` methods and raw `.where(forum_threads: { forum_id: ... })` queries in `ForumsController`

- [ ] **Step 4: Rebuild Tailwind and reseed**

Run: `bin/rails tailwindcss:build && bin/rails db:seed`
Expected: both complete cleanly

- [ ] **Step 5: Manual end-to-end smoke test**

Boot the server, then in sequence:
1. Load `/` — confirm real category/forum names appear (not "Politics & Current Events" hardcoded text), real stats in the footer-adjacent stats panel.
2. Click into a real forum from the index — confirm the URL is the forum's real slug, thread list shows real titles/reply counts/views.
3. Click into a real thread — confirm the URL is the thread's real slug, `views_count` visibly increments on a second load (check via `bin/rails runner`), OP + replies render with real usernames and real rich-text body content (real paragraphs, not the old em-dash-separated stub prose).
4. Sign in as a seeded user. Visit a forum, click "+ New Thread", submit a real title + body through the Lexxy editor, confirm redirect to the new thread's real page and the content renders.
5. On that thread, use the real reply box to post a reply, confirm it appears in the post list after redirect.
6. Sign out, confirm "+ New Thread" now shows "Log in to post" and the reply box is replaced by a login prompt.

Stop the server after. If any step fails, that's a real bug to fix before considering this plan complete — not a check to wave through.

- [ ] **Step 6: Final commit if step 5 uncovered fixes**

```bash
git add -A
git commit -m "Fix issues found in end-to-end verification"
```

(Skip this step if step 5 found nothing to fix.)
