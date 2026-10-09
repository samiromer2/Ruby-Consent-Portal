require "test_helper"

class CitizenTest < ActiveSupport::TestCase
  test "rejects an invalid email" do
    citizen = Citizen.new(name: "Test", email: "not-an-email")
    assert_not citizen.valid?
    assert_includes citizen.errors[:email], "is invalid"
  end

  test "normalizes email" do
    citizen = Citizen.create!(name: "Test", email: "  TEST@Example.COM ")
    assert_equal "test@example.com", citizen.email
  end

  test "email is unique regardless of case" do
    duplicate = Citizen.new(name: "Copy", email: "ALICE@example.com")
    assert_not duplicate.valid?
  end
end
