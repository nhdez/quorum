# Toggles the "recommended" flag on a post (ForumThread or ThreadReply) —
# the user-facing feature is called "highlighting" a post; the underlying
# attribute is named recommended to avoid colliding with the unrelated
# post[:highlighted] key already used elsewhere (post-author-is-admin
# styling on PostComponent).
class HighlightsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_highlighter!

  HIGHLIGHTABLE_TYPES = %w[ForumThread ThreadReply].freeze

  def toggle
    post = highlightable_type.constantize.find(params[:highlightable_id])
    post.update!(recommended: !post.recommended?)

    redirect_back fallback_location: root_path
  end

  private

  def authorize_highlighter!
    return if current_user.has_role?(:admin) || current_user.has_role?(:moderator)

    redirect_to root_path, alert: "You are not authorized to do that."
  end

  def highlightable_type
    params[:highlightable_type].to_s.in?(HIGHLIGHTABLE_TYPES) ? params[:highlightable_type] : raise(ActionController::BadRequest)
  end
end
