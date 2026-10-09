require "test_helper"

class ExpireStaleConsentsJobTest < ActiveJob::TestCase
  test "revokes consents older than a year and leaves recent ones alone" do
    ExpireStaleConsentsJob.perform_now

    assert_not_nil consents(:old).reload.revoked_at
    assert_nil consents(:one).reload.revoked_at
  end
end
