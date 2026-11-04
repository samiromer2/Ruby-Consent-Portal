require "test_helper"

class ConsentPolicyTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @admin = users(:admin)
    @own = consents(:one)
    @other = consents(:old)
  end

  test "scope is only the citizen's consents" do
    resolved = ConsentPolicy::Scope.new(@alice, Consent.all).resolve

    assert_includes resolved, @own
    assert_not_includes resolved, @other
  end

  test "scope is every consent for an admin" do
    resolved = ConsentPolicy::Scope.new(@admin, Consent.all).resolve

    assert_includes resolved, @own
    assert_includes resolved, @other
  end

  test "a citizen can revoke their own consent" do
    assert ConsentPolicy.new(@alice, @own).revoke?
  end

  test "a revoked consent cannot be revoked again, even by its owner" do
    assert_not ConsentPolicy.new(users(:two), consents(:revoked)).revoke?
  end

  test "nobody can edit a consent" do
    assert_not ConsentPolicy.new(@alice, @own).update?
    assert_not ConsentPolicy.new(@admin, @own).update?
  end

  test "a citizen cannot show or revoke someone else's consent" do
    policy = ConsentPolicy.new(@alice, @other)

    assert_not policy.show?
    assert_not policy.revoke?
  end
end
