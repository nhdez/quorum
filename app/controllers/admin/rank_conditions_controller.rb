module Admin
  class RankConditionsController < BaseController
    def create
      rank = Rank.find(params[:rank_id])
      condition = rank.rank_conditions.new(rank_condition_params)

      if condition.save
        redirect_to admin_ranks_path, notice: "Condition added to #{rank.name}."
      else
        redirect_to admin_ranks_path, alert: condition.errors.full_messages.to_sentence
      end
    end

    def destroy
      rank = Rank.find(params[:rank_id])
      rank.rank_conditions.find(params[:id]).destroy
      redirect_to admin_ranks_path, notice: "Condition removed."
    end

    private

    def rank_condition_params
      params.require(:rank_condition).permit(:metric, :threshold)
    end
  end
end
