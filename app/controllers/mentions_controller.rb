# Backs the @mention autocomplete prompt in Lexxy editors (see
# app/views/mentions/index.html.erb, rendered as <lexxy-prompt-item>
# elements Lexxy fetches via remote-filtering).
class MentionsController < ApplicationController
  before_action :authenticate_user!

  MINIMUM_QUERY_LENGTH = 3

  def index
    query = params[:filter].to_s.strip

    @users = if query.length >= MINIMUM_QUERY_LENGTH
      sanitized = ActiveRecord::Base.sanitize_sql_like(query)
      # Match only the local part of the email (== display_name, since
      # there's no separate username column) — not the full email string,
      # which would let a long-enough query probe past the "@" and confirm
      # full email addresses/domains rather than just searching names.
      User.where("split_part(email, '@', 1) ILIKE ?", "#{sanitized}%").limit(10)
    else
      User.none
    end

    render layout: false
  end
end
