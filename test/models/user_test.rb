require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "assigns an api token" do
    user = User.new(email_address: "token@example.com", password: "password", password_confirmation: "password")
    user.valid?

    assert user.api_token.present?
  end
end
