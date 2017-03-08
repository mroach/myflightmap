class TripPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if not user
        scope.where(is_public: true)
      elsif user.admin?
        scope.all
      else
        scope.where(
          Trip.arel_table[:user_id].eq(user.id)
            .or(Trip.arel_table[:is_public].eq(true))
        )
      end
    end
  end

  def update?
    user && (user.admin? || record.user == user)
  end

  def destroy?
    update?
  end
end
