class ApplicationComponent < ViewComponent::Base
  # ViewComponent doesn't automatically pull in ActionText::TagHelper the way
  # normal Rails views do, so f.rich_textarea (Lexxy's editor) fails inside
  # any component template without this. Lexxy's tag helper also reaches for
  # main_app internally (for direct-upload URLs), which needs delegating too.
  include ActionText::TagHelper

  delegate :main_app, to: :helpers
end
