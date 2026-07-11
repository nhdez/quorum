# LLM Service Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the app a way to store an Anthropic API key + model choice at runtime (admin-managed, encrypted) and a reusable `Ai::Client` service that turns a prompt into validated structured JSON. This is prerequisite groundwork for the (not-yet-built) Fallacy Detection Module.

**Architecture:** A singleton `AiSetting` ActiveRecord model (encrypted `api_key`, curated `model_id`) backs a small `Ai::Client` service object that wraps the official `anthropic` gem and Claude's structured-outputs feature. An `Admin::AiSettingsController` exposes an edit/update/test-connection UI reusing the existing admin layout and Pundit `AdminPolicy`.

**Tech Stack:** Rails 8.1.3, `anthropic` gem (official Ruby SDK), Active Record Encryption, Minitest + fixtures.

## Global Constraints

- No real Anthropic API calls anywhere in the test suite — every test that exercises `Ai::Client` injects a stub double via `anthropic_client:`.
- `model_id` must always be one of `AiSetting::AVAILABLE_MODELS` — never free text.
- A blank `api_key` is the "not configured" state — no separate `enabled` flag.
- Follow existing conventions exactly: UUID primary keys, `Admin::BaseController` (`authenticate_user!` + `authorize_admin!` + `layout "admin"`), fixtures-based Minitest (no FactoryBot), Tailwind utility classes matching the existing admin panels (see `Admin::BiasBotSettingsComponent` for reference styling).

---

### Task 1: Add the `anthropic` gem

**Files:**
- Modify: `Gemfile`

**Interfaces:**
- Produces: the `anthropic` gem, available to all later tasks as `Anthropic::Client`, `Anthropic::Errors::APIError`.

- [ ] **Step 1: Add the gem**

Add this line to `Gemfile` right after `gem "friendly_id"`:

```ruby
gem "anthropic"
```

- [ ] **Step 2: Install**

Run: `bundle install`
Expected: resolves and installs `anthropic` (and its dependencies) with no errors; `Gemfile.lock` gains an `anthropic` entry.

- [ ] **Step 3: Commit**

```bash
git add Gemfile Gemfile.lock
git commit -m "chore: add anthropic gem for LLM service infrastructure"
```

---

### Task 2: Active Record Encryption keys

**Files:**
- Modify: `config/credentials.yml.enc` (via the script below — do not hand-edit)
- Create (temporary, deleted at the end of this task): `tmp/write_encryption_credentials.rb`

**Interfaces:**
- Produces: `active_record_encryption.primary_key` / `deterministic_key` / `key_derivation_salt` entries in Rails credentials, required before `encrypts` works on any model.

- [ ] **Step 1: Generate the keys**

Run: `bin/rails db:encryption:init`
Expected output (values will differ each run):

```
Add this entry to the credentials of the target environment:

active_record_encryption:
  primary_key: <random string>
  deterministic_key: <random string>
  key_derivation_salt: <random string>
```

Copy the three generated values — they're needed in the next step.

- [ ] **Step 2: Write a one-off script to append them to credentials**

Create `tmp/write_encryption_credentials.rb`:

```ruby
enc = ActiveSupport::EncryptedConfiguration.new(
  config_path: Rails.root.join("config/credentials.yml.enc"),
  key_path: Rails.root.join("config/master.key"),
  env_key: "RAILS_MASTER_KEY",
  raise_if_missing_key: true
)

current = enc.read
addition = <<~YAML

  active_record_encryption:
    primary_key: #{ENV.fetch("AR_ENC_PRIMARY_KEY")}
    deterministic_key: #{ENV.fetch("AR_ENC_DETERMINISTIC_KEY")}
    key_derivation_salt: #{ENV.fetch("AR_ENC_KEY_DERIVATION_SALT")}
YAML

enc.write(current + addition)
puts "credentials updated"
```

- [ ] **Step 3: Run it with the values from Step 1**

Run (substituting the three real values captured in Step 1):

```bash
AR_ENC_PRIMARY_KEY="<primary_key from step 1>" \
AR_ENC_DETERMINISTIC_KEY="<deterministic_key from step 1>" \
AR_ENC_KEY_DERIVATION_SALT="<key_derivation_salt from step 1>" \
bin/rails runner tmp/write_encryption_credentials.rb
```

Expected: prints `credentials updated`.

- [ ] **Step 4: Verify and clean up**

Run: `EDITOR="cat" bin/rails credentials:show | grep -A3 active_record_encryption`
Expected: shows the three keys written in Step 3.

Delete the temporary script:

```bash
rm tmp/write_encryption_credentials.rb
```

- [ ] **Step 5: Commit**

```bash
git add config/credentials.yml.enc
git commit -m "chore: add Active Record Encryption keys"
```

---

### Task 3: `AiSetting` model

**Files:**
- Create: `db/migrate/20260711130000_create_ai_settings.rb`
- Create: `app/models/ai_setting.rb`
- Test: `test/models/ai_setting_test.rb`

**Interfaces:**
- Produces: `AiSetting.instance` (singleton fetch-or-create), `AiSetting::AVAILABLE_MODELS` (Hash of model_id => display label), `#configured?` (Boolean), encrypted `#api_key`, validated `#model_id`.

- [ ] **Step 1: Write the failing test**

Create `test/models/ai_setting_test.rb`:

```ruby
require "test_helper"

class AiSettingTest < ActiveSupport::TestCase
  test "instance returns the same row on repeat calls" do
    first = AiSetting.instance
    second = AiSetting.instance

    assert_equal first.id, second.id
  end

  test "instance defaults model_id to the first available model" do
    setting = AiSetting.instance

    assert_equal AiSetting::AVAILABLE_MODELS.keys.first, setting.model_id
  end

  test "configured? is false when api_key is blank" do
    setting = AiSetting.new(api_key: nil)

    assert_not setting.configured?
  end

  test "configured? is true when api_key is present" do
    setting = AiSetting.new(api_key: "sk-ant-test")

    assert setting.configured?
  end

  test "encrypts api_key at rest" do
    setting = AiSetting.instance
    setting.update!(api_key: "sk-ant-secret")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT api_key FROM ai_settings WHERE id = '#{setting.id}'"
    )

    assert_not_equal "sk-ant-secret", raw
    assert_equal "sk-ant-secret", setting.reload.api_key
  end

  test "rejects a model_id outside the curated list" do
    setting = AiSetting.new(model_id: "gpt-4")

    assert_not setting.valid?
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/models/ai_setting_test.rb`
Expected: FAIL — `uninitialized constant AiSetting` (model and table don't exist yet).

- [ ] **Step 3: Write the migration**

Create `db/migrate/20260711130000_create_ai_settings.rb`:

```ruby
class CreateAiSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_settings, id: :uuid do |t|
      t.string :api_key
      t.string :model_id, null: false, default: "claude-opus-4-8"

      t.timestamps
    end
  end
end
```

- [ ] **Step 4: Run the migration**

Run: `bin/rails db:migrate`
Expected: `CreateAiSettings: migrated`. Also run `bin/rails db:test:prepare` (or `RAILS_ENV=test bin/rails db:migrate`) so the test database has the new table.

- [ ] **Step 5: Write the model**

Create `app/models/ai_setting.rb`:

```ruby
class AiSetting < ApplicationRecord
  AVAILABLE_MODELS = {
    "claude-opus-4-8" => "Claude Opus 4.8 (most capable)",
    "claude-sonnet-5" => "Claude Sonnet 5 (balanced)",
    "claude-haiku-4-5" => "Claude Haiku 4.5 (fastest/cheapest)"
  }.freeze

  encrypts :api_key

  validates :model_id, inclusion: { in: AVAILABLE_MODELS.keys }

  def self.instance
    first_or_create!
  end

  def configured?
    api_key.present?
  end
end
```

- [ ] **Step 6: Run test to verify it passes**

Run: `bin/rails test test/models/ai_setting_test.rb`
Expected: PASS (6 tests, 0 failures).

- [ ] **Step 7: Commit**

```bash
git add db/migrate/20260711130000_create_ai_settings.rb db/schema.rb app/models/ai_setting.rb test/models/ai_setting_test.rb
git commit -m "feat: add AiSetting model for admin-managed LLM credentials"
```

---

### Task 4: `Ai::Client` service wrapper

**Files:**
- Create: `app/services/ai/error.rb`
- Create: `app/services/ai/not_configured_error.rb`
- Create: `app/services/ai/request_error.rb`
- Create: `app/services/ai/client.rb`
- Test: `test/services/ai/client_test.rb`

**Interfaces:**
- Consumes: `AiSetting.instance` (Task 3), `AiSetting::AVAILABLE_MODELS`.
- Produces: `Ai::Client.new(anthropic_client: nil).structured_completion(system:, prompt:, schema:, max_tokens: 1024)` → `Hash`. Raises `Ai::NotConfiguredError` or `Ai::RequestError`. This is the method future callers (fallacy detection, bias scanner) will use.

- [ ] **Step 1: Write the failing tests**

Create `test/services/ai/client_test.rb`:

```ruby
require "test_helper"

module Ai
  class ClientTest < ActiveSupport::TestCase
    class FakeTextBlock
      attr_reader :type, :text

      def initialize(text)
        @type = :text
        @text = text
      end
    end

    class FakeMessage
      attr_reader :content

      def initialize(text)
        @content = [ FakeTextBlock.new(text) ]
      end
    end

    class FakeMessagesResource
      def initialize(response:, error: nil)
        @response = response
        @error = error
      end

      def create(**)
        raise @error if @error

        @response
      end
    end

    class FakeAnthropicClient
      attr_reader :messages

      def initialize(response: nil, error: nil)
        @messages = FakeMessagesResource.new(response: response, error: error)
      end
    end

    test "raises NotConfiguredError when no api_key is saved" do
      AiSetting.instance.update!(api_key: nil)

      error = assert_raises(Ai::NotConfiguredError) do
        Ai::Client.new.structured_completion(
          system: "sys", prompt: "hi", schema: { type: "object" }
        )
      end

      assert_match(/API key/, error.message)
    end

    test "parses a structured JSON response into a Hash" do
      AiSetting.instance.update!(api_key: "sk-ant-test")
      fake_message = FakeMessage.new('{"fallacy_detected": true}')
      fake_client = FakeAnthropicClient.new(response: fake_message)

      result = Ai::Client.new(anthropic_client: fake_client).structured_completion(
        system: "sys", prompt: "hi", schema: { type: "object" }
      )

      assert_equal({ "fallacy_detected" => true }, result)
    end

    test "wraps an Anthropic API error into RequestError" do
      AiSetting.instance.update!(api_key: "sk-ant-test")
      api_error = Anthropic::Errors::APIError.new(
        url: URI("https://api.anthropic.com/v1/messages"),
        status: 429,
        body: nil,
        request: nil,
        response: nil,
        message: "rate limited"
      )
      fake_client = FakeAnthropicClient.new(error: api_error)

      error = assert_raises(Ai::RequestError) do
        Ai::Client.new(anthropic_client: fake_client).structured_completion(
          system: "sys", prompt: "hi", schema: { type: "object" }
        )
      end

      assert_match(/rate limited/, error.message)
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/services/ai/client_test.rb`
Expected: FAIL — `uninitialized constant Ai::Client`.

- [ ] **Step 3: Write the error classes**

Create `app/services/ai/error.rb`:

```ruby
module Ai
  class Error < StandardError; end
end
```

Create `app/services/ai/not_configured_error.rb`:

```ruby
module Ai
  class NotConfiguredError < Error; end
end
```

Create `app/services/ai/request_error.rb`:

```ruby
module Ai
  class RequestError < Error; end
end
```

- [ ] **Step 4: Write the client**

Create `app/services/ai/client.rb`:

```ruby
module Ai
  class Client
    def initialize(anthropic_client: nil)
      @injected_client = anthropic_client
    end

    def structured_completion(system:, prompt:, schema:, max_tokens: 1024)
      setting = AiSetting.instance
      raise NotConfiguredError, "No Anthropic API key configured" unless setting.configured?

      response = client_for(setting).messages.create(
        model: setting.model_id,
        max_tokens: max_tokens,
        system: system,
        messages: [ { role: "user", content: prompt } ],
        output_config: { format: { type: "json_schema", schema: schema } }
      )

      text_block = response.content.find { |block| block.type == :text }
      JSON.parse(text_block.text)
    rescue Anthropic::Errors::APIError => e
      raise RequestError, e.message
    end

    private

    def client_for(setting)
      @injected_client || Anthropic::Client.new(api_key: setting.api_key)
    end
  end
end
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bin/rails test test/services/ai/client_test.rb`
Expected: PASS (3 tests, 0 failures).

- [ ] **Step 6: Commit**

```bash
git add app/services/ai/ test/services/ai/
git commit -m "feat: add Ai::Client structured-completion service wrapper"
```

---

### Task 5: Admin AI Settings UI

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/admin/ai_settings_controller.rb`
- Create: `app/views/admin/ai_settings/edit.html.erb`
- Test: `test/controllers/admin/ai_settings_controller_test.rb`

**Interfaces:**
- Consumes: `AiSetting` (Task 3), `Ai::Client` + `Ai::NotConfiguredError` + `Ai::RequestError` (Task 4), `Admin::BaseController` (existing).
- Produces: `edit_admin_ai_settings_path`, `admin_ai_settings_path` (PATCH), `test_admin_ai_settings_path` (POST) — used by Task 6's nav link.

- [ ] **Step 1: Write the failing tests**

Create `test/controllers/admin/ai_settings_controller_test.rb`:

```ruby
require "test_helper"

module Admin
  class AiSettingsControllerTest < ActionDispatch::IntegrationTest
    def sign_in_as_admin
      admin = User.create!(email: "aiadmin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
      admin.add_role(:admin)
      post user_session_path, params: { user: { email: admin.email, password: "password123" } }
      admin
    end

    test "redirects guests to the login page" do
      get edit_admin_ai_settings_url
      assert_redirected_to new_user_session_path
    end

    test "shows the current model selection" do
      sign_in_as_admin
      AiSetting.instance.update!(model_id: "claude-sonnet-5")

      get edit_admin_ai_settings_url

      assert_response :success
      assert_select "option[selected][value=?]", "claude-sonnet-5"
    end

    test "updates the model and api_key" do
      sign_in_as_admin

      patch admin_ai_settings_url, params: { ai_setting: { api_key: "sk-ant-newkey", model_id: "claude-haiku-4-5" } }

      assert_redirected_to edit_admin_ai_settings_path
      setting = AiSetting.instance
      assert_equal "claude-haiku-4-5", setting.model_id
      assert_equal "sk-ant-newkey", setting.api_key
    end

    test "a blank api_key on update preserves the existing key" do
      sign_in_as_admin
      AiSetting.instance.update!(api_key: "sk-ant-existing")

      patch admin_ai_settings_url, params: { ai_setting: { api_key: "", model_id: "claude-haiku-4-5" } }

      assert_equal "sk-ant-existing", AiSetting.instance.api_key
      assert_equal "claude-haiku-4-5", AiSetting.instance.model_id
    end

    class FakeSuccessClient
      def structured_completion(**)
        { "ok" => true }
      end
    end

    class FakeFailureClient
      def structured_completion(**)
        raise Ai::RequestError, "invalid x-api-key"
      end
    end

    test "test connection reports success" do
      sign_in_as_admin
      AiSetting.instance.update!(api_key: "sk-ant-existing")

      Ai::Client.stub(:new, FakeSuccessClient.new) do
        post test_admin_ai_settings_url
      end

      assert_redirected_to edit_admin_ai_settings_path
      assert_match(/Connected/, flash[:notice])
    end

    test "test connection reports failure" do
      sign_in_as_admin
      AiSetting.instance.update!(api_key: "sk-ant-existing")

      Ai::Client.stub(:new, FakeFailureClient.new) do
        post test_admin_ai_settings_url
      end

      assert_redirected_to edit_admin_ai_settings_path
      assert_match(/invalid x-api-key/, flash[:alert])
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/controllers/admin/ai_settings_controller_test.rb`
Expected: FAIL — routing error (`edit_admin_ai_settings_url` undefined).

- [ ] **Step 3: Add routes**

In `config/routes.rb`, replace:

```ruby
  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resources :pending_registrations, only: %i[destroy] do
      member { patch :confirm }
    end
  end
```

with:

```ruby
  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resource :ai_settings, only: %i[edit update] do
      post :test, on: :collection
    end
    resources :pending_registrations, only: %i[destroy] do
      member { patch :confirm }
    end
  end
```

- [ ] **Step 4: Write the controller**

Create `app/controllers/admin/ai_settings_controller.rb`:

```ruby
module Admin
  class AiSettingsController < BaseController
    before_action :set_admin_nav
    before_action :set_ai_setting

    def edit
    end

    def update
      attrs = ai_setting_params
      attrs = attrs.except(:api_key) if attrs[:api_key].blank?

      if @ai_setting.update(attrs)
        redirect_to edit_admin_ai_settings_path, notice: "AI settings saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def test
      Ai::Client.new.structured_completion(
        system: "You respond only with the requested JSON.",
        prompt: 'Reply with {"ok": true}.',
        schema: { type: "object", properties: { ok: { type: "boolean" } }, required: [ "ok" ], additionalProperties: false },
        max_tokens: 64
      )
      redirect_to edit_admin_ai_settings_path, notice: "Connected — model responded successfully."
    rescue Ai::NotConfiguredError
      redirect_to edit_admin_ai_settings_path, alert: "No API key configured yet."
    rescue Ai::RequestError => e
      redirect_to edit_admin_ai_settings_path, alert: "Connection failed: #{e.message}"
    end

    private

    def set_admin_nav
      @admin_nav_current = :settings
    end

    def set_ai_setting
      @ai_setting = AiSetting.instance
    end

    def ai_setting_params
      params.require(:ai_setting).permit(:api_key, :model_id)
    end
  end
end
```

- [ ] **Step 5: Write the view**

Create `app/views/admin/ai_settings/edit.html.erb`:

```erb
<%= render Ui::PanelComponent.new(title: "AI Settings") do %>
  <div class="p-4">
    <%= form_with model: @ai_setting, url: admin_ai_settings_path, method: :patch, local: true do |f| %>
      <div class="mb-3.5">
        <label class="block text-[11px] font-bold text-muted mb-1.5" for="ai_setting_api_key">ANTHROPIC API KEY</label>
        <%= f.password_field :api_key, placeholder: @ai_setting.configured? ? "•••••••••••••••• (unchanged)" : "sk-ant-...", class: "w-full px-2.5 py-1.5 border border-line rounded-[3px] text-xs" %>
      </div>

      <div class="mb-3.5">
        <label class="block text-[11px] font-bold text-muted mb-1.5" for="ai_setting_model_id">MODEL</label>
        <%= f.select :model_id, AiSetting::AVAILABLE_MODELS.map { |id, label| [ label, id ] }, {}, class: "w-full px-2.5 py-1.5 border border-line rounded-[3px] text-xs" %>
      </div>

      <div class="flex gap-2.5">
        <%= f.submit "Save", class: "px-4.5 py-2 border border-register-line rounded-[3px] bg-register text-white text-xs font-bold cursor-pointer [font-family:inherit] hover:opacity-90" %>
        <%= button_to "Test Connection", test_admin_ai_settings_path, method: :post, class: "px-4.5 py-2 border border-line rounded-[3px] bg-row text-ink text-xs font-bold cursor-pointer [font-family:inherit] hover:bg-row-alt" %>
      </div>
    <% end %>
  </div>
<% end %>
```

- [ ] **Step 6: Run test to verify it passes**

Run: `bin/rails test test/controllers/admin/ai_settings_controller_test.rb`
Expected: PASS (6 tests, 0 failures).

- [ ] **Step 7: Commit**

```bash
git add config/routes.rb app/controllers/admin/ai_settings_controller.rb app/views/admin/ai_settings/ test/controllers/admin/ai_settings_controller_test.rb
git commit -m "feat: add admin AI settings page (edit/update/test connection)"
```

---

### Task 6: Wire up the admin sidebar nav

**Files:**
- Modify: `app/components/admin/sidebar_component.rb`
- Modify: `app/components/admin/sidebar_component.html.erb`
- Modify: `test/components/admin/sidebar_component_test.rb`

**Interfaces:**
- Consumes: `edit_admin_ai_settings_path`, `admin_dashboard_path` (Task 5, existing).

- [ ] **Step 1: Write the failing test**

Modify `test/components/admin/sidebar_component_test.rb` to:

```ruby
require "test_helper"

module Admin
  class SidebarComponentTest < ViewComponent::TestCase
    test "renders every sidebar link" do
      render_inline(SidebarComponent.new)

      Admin::SidebarComponent::LINKS.each do |link|
        assert_text link[:label]
      end
    end

    test "renders real links for pages that exist" do
      render_inline(SidebarComponent.new)

      assert_selector "a[href='#{Rails.application.routes.url_helpers.admin_dashboard_path}']", text: "Dashboard"
      assert_selector "a[href='#{Rails.application.routes.url_helpers.edit_admin_ai_settings_path}']", text: "Settings"
    end

    test "leaves not-yet-built sections as non-links" do
      render_inline(SidebarComponent.new)

      assert_selector "div", text: "Members"
      assert_no_selector "a", text: "Members"
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/components/admin/sidebar_component_test.rb`
Expected: FAIL on the two new tests — no `<a>` tags exist yet.

- [ ] **Step 3: Update the component**

Modify `app/components/admin/sidebar_component.rb`:

```ruby
module Admin
  class SidebarComponent < ApplicationComponent
    LINKS = [
      { key: :dashboard, label: "Dashboard", path: :admin_dashboard_path },
      { key: :members, label: "Members" },
      { key: :boards, label: "Forums & Boards" },
      { key: :reports, label: "Reported Posts" },
      { key: :bias_bot, label: "AI Bias Bot" },
      { key: :affiliations, label: "Affiliations" },
      { key: :announcements, label: "Announcements" },
      { key: :settings, label: "Settings", path: :edit_admin_ai_settings_path }
    ].freeze

    def initialize(current: :dashboard)
      @current = current
    end

    def links
      LINKS
    end

    def active?(link)
      link[:key] == @current
    end
  end
end
```

- [ ] **Step 4: Update the template**

Modify `app/components/admin/sidebar_component.html.erb`:

```erb
<div class="w-[200px] shrink-0 bg-row border-r border-line min-h-[calc(100vh-54px)]">
  <% links.each do |link| %>
    <% active_classes = "py-2.5 px-4 text-xs font-bold text-white bg-panel-to border-l-[3px] border-panel-to" %>
    <% inactive_classes = "py-2.5 px-4 text-xs font-bold text-ink border-l-[3px] border-transparent hover:bg-row-alt" %>
    <% classes = active?(link) ? active_classes : inactive_classes %>
    <% if link[:path] %>
      <%= link_to link[:label], public_send(link[:path]), class: "block #{classes}" %>
    <% else %>
      <div class="<%= classes %>"><%= link[:label] %></div>
    <% end %>
  <% end %>
</div>
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bin/rails test test/components/admin/sidebar_component_test.rb`
Expected: PASS (3 tests, 0 failures).

- [ ] **Step 6: Commit**

```bash
git add app/components/admin/sidebar_component.rb app/components/admin/sidebar_component.html.erb test/components/admin/sidebar_component_test.rb
git commit -m "feat: link Dashboard and Settings in the admin sidebar nav"
```

---

### Task 7: Full verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full test suite**

Run: `bin/rails test`
Expected: 0 failures, 0 errors.

- [ ] **Step 2: Run rubocop**

Run: `bundle exec rubocop app config db test`
Expected: no offenses (or auto-fix with `-a` and re-run).

- [ ] **Step 3: Run brakeman**

Run: `bundle exec brakeman -q`
Expected: 0 security warnings. If the encrypted `api_key` column triggers a warning about mass-assignment, verify `ai_setting_params` only permits `:api_key, :model_id` (already the case) and note it as a false positive if so.

- [ ] **Step 4: Manual smoke check**

Run: `bin/rails runner 'puts AiSetting.instance.inspect; puts AiSetting::AVAILABLE_MODELS'`
Expected: prints a persisted `AiSetting` row with `model_id: "claude-opus-4-8"` and the three available models.
