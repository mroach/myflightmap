class UserPolicy < ApplicationPolicy
  def index?
    @user and @user.admin?
  end

  def show?
    true
  end
end
