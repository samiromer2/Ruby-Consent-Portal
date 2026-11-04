class ConsentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.citizen
        scope.where(citizen_id: user.citizen.id)
      else
        scope.none
      end
    end
  end

  def show?
    user.admin? || owner?
  end

  def create?
    owner?
  end

  # Consents are never edited: revoke and grant a new one instead.
  # A revoked consent can't be revoked again, so its revoked_at never changes.
  def revoke?
    owner? && record.active?
  end

  def destroy?
    owner?
  end

  private
    def owner?
      user.citizen? && user.citizen.present? && record.citizen_id == user.citizen.id
    end
end
