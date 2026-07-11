class FallacyFlagsController < ApplicationController
  before_action :authenticate_user!

  def dismiss
    flag = FallacyFlag.find(params[:id])

    if flag.flaggable.user == current_user
      flag.update!(dismissed_by_author: true)
      redirect_back fallback_location: root_path, notice: "Flag dismissed."
    else
      redirect_back fallback_location: root_path, alert: "You can't dismiss that flag."
    end
  end
end
