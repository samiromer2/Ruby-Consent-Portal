require "test_helper"

class ConsentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @consent = consents(:one)
  end

  test "should get index" do
    get consents_url
    assert_response :success
  end

  test "should get new" do
    get new_consent_url
    assert_response :success
  end

  test "should create consent" do
    assert_difference("Consent.count") do
      post consents_url, params: { consent: { citizen_id: @consent.citizen_id, granted_at: @consent.granted_at, revoked_at: @consent.revoked_at, service_id: @consent.service_id } }
    end

    assert_redirected_to consent_url(Consent.last)
  end

  test "should show consent" do
    get consent_url(@consent)
    assert_response :success
  end

  test "should get edit" do
    get edit_consent_url(@consent)
    assert_response :success
  end

  test "should update consent" do
    patch consent_url(@consent), params: { consent: { citizen_id: @consent.citizen_id, granted_at: @consent.granted_at, revoked_at: @consent.revoked_at, service_id: @consent.service_id } }
    assert_redirected_to consent_url(@consent)
  end

  test "should destroy consent" do
    assert_difference("Consent.count", -1) do
      delete consent_url(@consent)
    end

    assert_redirected_to consents_url
  end
end
