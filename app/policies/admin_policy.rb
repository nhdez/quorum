class AdminPolicy < ApplicationPolicy
  def access?
    user&.has_role?(:admin)
  end
end
