require "test_helper"

class CitizensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @citizen = citizens(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get citizens_url
    assert_response :success
  end

  test "should get index of only the signed-in citizen" do
    get citizens_url
    assert_response :success
    assert_match "Alice", response.body
    assert_no_match "Bob", response.body
  end

  test "cannot open another citizen" do
    get citizen_url(citizens(:two))
    assert_redirected_to root_url
  end

  test "cannot verify themselves" do
    sign_in_as(users(:two))
    patch citizen_url(citizens(:two)), params: {
      citizen: { name: "Bob Singh", email: "bob@example.com", verified: true }
    }

    assert_redirected_to citizen_url(citizens(:two))
    assert_not citizens(:two).reload.verified
  end

  test "admin can verify a citizen" do
    sign_in_as(users(:admin))
    patch citizen_url(citizens(:two)), params: {
      citizen: { name: "Bob Singh", email: "bob@example.com", verified: true }
    }

    assert citizens(:two).reload.verified
  end

  test "should show citizen" do
    get citizen_url(@citizen)
    assert_response :success
  end

  test "should get edit" do
    get edit_citizen_url(@citizen)
    assert_response :success
  end

  test "should update citizen" do
    patch citizen_url(@citizen), params: { citizen: { email: @citizen.email, name: @citizen.name } }
    assert_redirected_to citizen_url(@citizen)
  end

  test "should destroy citizen" do
    sign_in_as(users(:admin))

    assert_difference("Citizen.count", -1) do
      delete citizen_url(citizens(:two))
    end

    assert_redirected_to citizens_url
  end

  test "citizen cannot destroy their record" do
    assert_no_difference("Citizen.count") do
      delete citizen_url(@citizen)
    end

    assert_redirected_to root_url
  end
end
