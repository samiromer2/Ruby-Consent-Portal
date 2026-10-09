require "test_helper"

class ConsentTest < ActiveSupport::TestCase
  test "a citizen can consent to a service only once" do
    duplicate = Consent.new(citizen: citizens(:one), service: services(:one))
    assert_not duplicate.valid?
  end

  test "active scope excludes revoked consents" do
    assert_includes Consent.active, consents(:one)
    assert_not_includes Consent.active, consents(:revoked)
  end

  test "revoke! sets revoked_at" do
    consent = consents(:one)
    consent.revoke!
    assert_not consent.active?
  end
end