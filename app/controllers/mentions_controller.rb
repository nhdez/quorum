# Backs the @mention autocomplete prompt in Lexxy editors (see
# app/views/mentions/index.html.erb, rendered as <lexxy-prompt-item>
# elements Lexxy fetches via remote-filtering).
class MentionsController < ApplicationController
  before_action :authenticate_user!

  MINIMUM_QUERY_LENGTH = 3

  def index
    query = params[:filter].to_s.strip

    @users = if query.length >= MINIMUM_QUERY_LENGTH
      User.where("email ILIKE ?", "#{query}%").limit(10)
    else
      User.none
    end

    render layout: false
  end
end
