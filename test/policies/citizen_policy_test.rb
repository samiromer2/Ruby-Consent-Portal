require "test_helper"

class CitizenPolicyTest < ActiveSupport::TestCase
  test "a citizen can see only their own record" do
    resolved = CitizenPolicy::Scope.new(users(:one), Citizen.all).resolve

    assert_includes resolved, citizens(:one)
    assert_not_includes resolved, citizens(:two)
    assert CitizenPolicy.new(users(:one), citizens(:one)).show?
    assert_not CitizenPolicy.new(users(:one), citizens(:two)).show?
  end

  test "only an admin can destroy a citizen" do
    assert_not CitizenPolicy.new(users(:one), citizens(:one)).destroy?
    assert CitizenPolicy.new(users(:admin), citizens(:two)).destroy?
  end
end
