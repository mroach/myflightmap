class UserPolicy < ApplicationPolicy
  def index?
    @user && @user.admin?
  end

  def show?
    true
  end
end
