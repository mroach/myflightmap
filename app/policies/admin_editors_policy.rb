# This policy is meant to be inherited and indicates that the models are
# fine to list and show but only admins can create, edit, and destroy
class AdminEditorsPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user and user.admin?
  end

  def update?
    user and user.admin?
  end

  def edit?
    user and user.admin?
  end

end
