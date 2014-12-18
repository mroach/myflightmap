class FlightPolicy < ApplicationPolicy
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
          Flight.arel_table[:user_id].eq(user.id)
            .or(Flight.arel_table[:is_public].eq(true))
        )
      end
    end
  end

  def update?
    user and (user.admin? || record.user == user)
  end

  def destroy?
    update?
  end
end
