class AffiliationsController < ApplicationController
  before_action :authenticate_user!, only: %i[create join]

  NEW_COLORS = [ "#6b4fa0", "#a0524f", "#4f8aa0", "#7a9a4f", "#a0824f" ].freeze

  def index
    @nav_current = :affiliations
    @factions = Faction.where(is_active: true).order(:created_at)
    @leaderboard = {
      most_active: { name: "Progressive Alliance", color: "#6b4fa0", stat: "1,204 posts this week across all boards" },
      most_balanced: { name: "Centrist Coalition", color: "#4f8aa0", stat: "Most even split of AI-flagged posts on both sides of an issue" }
    }
  end

  def create
    faction = Faction.new(
      name: faction_params[:name],
      description: faction_params[:description].presence || "A newly founded community faction.",
      color: NEW_COLORS[Faction.count % NEW_COLORS.length],
      is_active: true
    )

    if faction.save
      redirect_to affiliations_path, notice: "#{faction.name} has been created."
    else
      redirect_to affiliations_path, alert: faction.errors.full_messages.to_sentence
    end
  end

  def join
    faction = Faction.find(params[:id])
    current_user.update(faction: current_user.faction_id == faction.id ? nil : faction)
    redirect_to affiliations_path
  end

  private

  def faction_params
    params.require(:faction).permit(:name, :description)
  end
end
