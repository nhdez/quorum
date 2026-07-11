module Admin
  class RanksController < BaseController
    before_action :set_admin_nav

    def index
      @ranks = Rank.ordered.includes(:rank_conditions)
      @new_rank = Rank.new(tier: (Rank.maximum(:tier) || 0) + 1)
    end

    def create
      rank = Rank.new(rank_params)

      if rank.save
        redirect_to admin_ranks_path, notice: "Rank created."
      else
        redirect_to admin_ranks_path, alert: rank.errors.full_messages.to_sentence
      end
    end

    def update
      rank = Rank.find(params[:id])

      if rank.update(rank_params)
        redirect_to admin_ranks_path, notice: "Rank updated."
      else
        redirect_to admin_ranks_path, alert: rank.errors.full_messages.to_sentence
      end
    end

    def destroy
      Rank.find(params[:id]).destroy
      redirect_to admin_ranks_path, notice: "Rank deleted."
    end

    private

    def set_admin_nav
      @admin_nav_current = :ranks
    end

    def rank_params
      params.require(:rank).permit(:name, :tier, :badge_color)
    end
  end
end
