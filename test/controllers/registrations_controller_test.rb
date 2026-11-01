require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create signs up a user and a citizen" do
    assert_difference [ "User.count", "Citizen.count" ], 1 do
      post registration_path, params: {
        name: "New Person",
        user: {
          email_address: "new-person@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    user = User.find_by!(email_address: "new-person@example.com")
    assert_equal "New Person", user.citizen.name
    assert_equal user.email_address, user.citizen.email
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create rejects a mismatched password" do
    assert_no_difference [ "User.count", "Citizen.count" ] do
      post registration_path, params: {
        name: "New Person",
        user: {
          email_address: "new-person@example.com",
          password: "password",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_content
  end
end
