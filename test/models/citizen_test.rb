require "test_helper"

class CitizenTest < ActiveSupport::TestCase
  test "rejects an invalid email" do
    citizen = Citizen.new(user: users(:one), name: "Test", email: "not-an-email")
    assert_not citizen.valid?
    assert_includes citizen.errors[:email], "is invalid"
  end

  test "normalizes email" do
    user = User.create!(email_address: "normalize@example.com", password: "password")
    citizen = Citizen.create!(user: user, name: "Test", email: "  TEST@Example.COM ")
    assert_equal "test@example.com", citizen.email
  end

  test "email is unique regardless of case" do
    user = User.create!(email_address: "copy@example.com", password: "password")
    duplicate = Citizen.new(user: user, name: "Copy", email: "ALICE@example.com")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end
end
