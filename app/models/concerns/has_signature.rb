# Restricted-markdown forum signatures, with an image moderation queue.
#
# Signatures render through Redcarpet with filter_html on (strips any raw
# HTML the user typed) and only a handful of extensions enabled (:underline,
# :quote — bold/italic/blockquote are core Markdown, no extension needed).
# Core Markdown always parses ATX headings ("# ...") and Redcarpet has no
# toggle to turn that off, so the real enforcement of "no headings, no
# tables" happens in the second step: the rendered HTML is passed through
# Rails' allowlist sanitizer, keeping only the tags this feature actually
# wants (strong/em/u/blockquote/img/p/br) — anything else, including
# headings and tables, is stripped regardless of what Redcarpet produced.
#
# Images are capped at MAX_IMAGES and their rendered size is capped via CSS
# wherever a signature is displayed (see the signature-body utility classes
# used in PostComponent / AboutMeComponent) rather than at render time here,
# since the constraint is about on-page size, not source file size.
module HasSignature
  extend ActiveSupport::Concern

  MAX_IMAGES = 3
  ALLOWED_TAGS = %w[strong em u blockquote img p br].freeze
  ALLOWED_ATTRIBUTES = %w[src alt title].freeze
  IMAGE_MARKDOWN_PATTERN = /!\[[^\]]*\]\([^)]*\)/

  included do
    validate :signature_image_count_within_limit
    before_save :flag_signature_for_moderation_if_changed
  end

  # Sanitized HTML for display, or nil if there's nothing to show (blank,
  # or awaiting moderation and the viewer isn't allowed to see it yet).
  def rendered_signature(viewer: nil)
    return nil if signature.blank?
    return nil if signature_pending_review? && viewer != self && !viewer&.has_role?(:admin) && !viewer&.has_role?(:moderator)

    renderer = Redcarpet::Render::HTML.new(filter_html: true, safe_links_only: true)
    markdown = Redcarpet::Markdown.new(renderer, no_intra_emphasis: true, underline: true, quote: true)
    html = markdown.render(Emoji.replace_shortcodes(signature))

    ActionController::Base.helpers.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end

  def signature_image_count
    signature.to_s.scan(IMAGE_MARKDOWN_PATTERN).size
  end

  private

  def signature_image_count_within_limit
    errors.add(:signature, "can only contain up to #{MAX_IMAGES} images") if signature_image_count > MAX_IMAGES
  end

  def flag_signature_for_moderation_if_changed
    return unless signature_changed?

    self.signature_pending_review = signature_image_count.positive?
  end
end
