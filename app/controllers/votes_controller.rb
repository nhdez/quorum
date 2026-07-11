class VotesController < ApplicationController
  before_action :authenticate_user!

  VOTABLE_TYPES = %w[ForumThread ThreadReply].freeze

  def toggle
    votable = votable_type.constantize.find(params[:votable_id])

    existing = votable.votes.find_by(user: current_user)
    if existing
      existing.destroy
    else
      votable.votes.create!(user: current_user)
    end

    redirect_back fallback_location: root_path
  end

  private

  def votable_type
    params[:votable_type].to_s.in?(VOTABLE_TYPES) ? params[:votable_type] : raise(ActionController::BadRequest)
  end
end
