class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protected

  # Builds a « 1 2 3 … N » page list for Ui::PaginationComponent.
  def pagination_pages(current:, last:)
    [
      { label: "«", href: "#" },
      { label: "1", href: "#", current: current == 1 },
      { label: "2", href: "#", current: current == 2 },
      { label: "3", href: "#", current: current == 3 },
      { label: "…" },
      { label: last.to_s, href: "#", current: current == last },
      { label: "»", href: "#" }
    ]
  end
end
