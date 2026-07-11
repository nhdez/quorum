module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authenticate_user!
    before_action :authorize_admin!

    private

    def authorize_admin!
      authorize :admin, :access?, policy_class: AdminPolicy
    end
  end
end
