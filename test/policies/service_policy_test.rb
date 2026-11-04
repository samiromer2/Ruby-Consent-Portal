require "test_helper"

class ServicePolicyTest < ActiveSupport::TestCase
  setup do
    @service = services(:one)
  end

  test "a citizen can see a service but cannot change it" do
    policy = ServicePolicy.new(users(:one), @service)

    assert policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "an admin can change a service" do
    policy = ServicePolicy.new(users(:admin), @service)

    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end
end
