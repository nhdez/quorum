# LLM Service Infrastructure — Design

**Status:** Approved
**Sub-project:** 2 of 3 (prerequisite work for the Fallacy Detection Module). Sub-project 1 (Real Post Content) is complete. Sub-project 3 (Fallacy Detection Module) builds on top of this.

## Purpose

Provide the shared groundwork both the (future) Fallacy Detection Module and the (future, currently fully-stubbed) political bias scanner need: a way to store an Anthropic API key and model choice at runtime, and a reusable service class that calls Claude and gets validated structured JSON back.

This sub-project does **not** implement fallacy detection or the bias scanner. It only builds the infrastructure they'll both call.

## Provider

Anthropic Claude, via the official `anthropic` Ruby gem. No other provider is wired up.

## Section 1: Data model & credential storage

A new `AiSetting` model, singleton-style — one row, fetched/created via `AiSetting.instance`.

Columns:
- `api_key` — string, encrypted at rest via Active Record Encryption (`encrypts :api_key`).
- `model_id` — string, not null, defaults to `"claude-opus-4-8"`.

Requires generating Active Record Encryption keys (`bin/rails db:encryption:init`) and storing them in Rails credentials. This rides the existing `RAILS_MASTER_KEY`, which Kamal already ships to production (`.kamal/secrets`), so no new deploy secret is needed.

`model_id` is constrained to a curated list (not free text), to avoid an admin saving an invalid/typo'd model ID that silently breaks every call:

```ruby
AVAILABLE_MODELS = {
  "claude-opus-4-8"   => "Claude Opus 4.8 (most capable)",
  "claude-sonnet-5"   => "Claude Sonnet 5 (balanced)",
  "claude-haiku-4-5"  => "Claude Haiku 4.5 (fastest/cheapest)",
}.freeze
```

No `enabled` toggle. A blank `api_key` **is** the disabled state — the service wrapper treats it as "not configured."

## Section 2: Admin UI

New `Admin::AiSettingsController`, following the existing `Admin::BaseController` convention (`authenticate_user!` + `authorize_admin!` via Pundit, `layout "admin"`).

Routes:
- `GET /admin/ai_settings` (`#edit`) — form with a masked/password-style input for the API key and a `model_id` dropdown (from `AiSetting::AVAILABLE_MODELS`).
- `PATCH /admin/ai_settings` (`#update`) — saves. A blank submitted API key field means "leave the existing key unchanged" (so editing the model choice doesn't force re-entering the key).
- `POST /admin/ai_settings/test` (`#test_connection`) — makes one real, minimal API call (small `max_tokens`, trivial prompt) using the currently saved key/model. Redirects back with a flash message: success ("Connected — model responded") or failure (the error message). Plain form-post + redirect-with-flash, consistent with the rest of the admin section.

Added to the existing admin sidebar nav alongside Dashboard / Pending Registrations.

## Section 3: Service wrapper

`Ai::Client`, in `app/services/ai/client.rb`. This is the shared entry point future features call.

```ruby
Ai::Client.new.structured_completion(
  system: "You are a...",
  prompt: "...",
  schema: {
    type: "object",
    properties: { ... },
    required: [...],
    additionalProperties: false,
  },
) # => Hash parsed from the model's JSON response
```

Behavior:
- Reads `api_key` and `model_id` from `AiSetting.instance` **at call time** (not memoized at boot), so an admin rotating the key or switching models takes effect on the next call with no restart.
- Uses Claude's structured outputs (`output_config: { format: { type: "json_schema", schema: } }`) — guarantees a schema-valid JSON response rather than relying on prompt engineering to get parseable output.
- No extended thinking by default. Structured extraction tasks don't need it, and it complicates schema-constrained output. Not exposed as a caller option yet — add it later if a real caller needs it.
- Relies on the SDK's built-in retry behavior (`max_retries: 2`, covers transient 429/5xx) rather than reimplementing retry logic.

Errors, so callers can handle each deliberately:
- `Ai::NotConfiguredError` — raised when `AiSetting.instance.api_key` is blank.
- `Ai::RequestError` — wraps any Anthropic API error that survives the SDK's automatic retries (auth failure, exhausted rate limit, etc.), carrying the original error's message.

Constructor accepts an optional `anthropic_client:` for dependency injection in tests (see Section 4). Defaults to building a real `Anthropic::Client` from `AiSetting.instance` when omitted.

## Section 4: Testing approach

No real Anthropic API calls in the test suite — no network dependency, no cost, no secrets needed in CI.

`Ai::Client.new(anthropic_client: fake)` accepts a test double in place of the real `Anthropic::Client`, so tests stub `.messages.create(...)` directly rather than intercepting HTTP.

Coverage:
- **Model tests** (`AiSetting`): singleton `.instance` behavior (finds-or-creates, returns the same row on repeat calls), `api_key` encryption round-trips.
- **Controller tests** (`Admin::AiSettingsController`): settings form save; blank API key field on update preserves the existing key; `model_id` must be one of `AVAILABLE_MODELS`; `#test_connection` with a stubbed success and a stubbed failure, asserting the flash message in each case.
- **Service tests** (`Ai::Client`): raises `NotConfiguredError` when no key is saved; parses a stubbed structured JSON response into the expected Hash; wraps a stubbed API error into `RequestError`.

## Out of scope (explicitly deferred)

- Fallacy Detection Module itself (sub-project 3).
- Making the political bias scanner real (not requested; `Ai::Client` will be reusable for it later, but no scanner work happens here).
- Extended thinking / effort configuration as a caller-facing option.
- Any UI for viewing AI usage/cost history — not requested.
