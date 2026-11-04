class CitizenPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.citizen
        scope.where(id: user.citizen.id)
      else
        scope.none
      end
    end
  end

  def show?
    user.admin? || record == user.citizen
  end

  def update?
    show?
  end

  def destroy?
    user.admin?
  end
end
