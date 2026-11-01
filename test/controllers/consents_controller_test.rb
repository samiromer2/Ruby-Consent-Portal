require "test_helper"

class ConsentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @consent = consents(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get consents_url
    assert_response :success
  end

  test "redirects to sign in when logged out" do
    sign_out

    [ consents_url, citizens_url, services_url ].each do |url|
      get url
      assert_redirected_to new_session_url
    end
  end

  test "should get new" do
    get new_consent_url
    assert_response :success
  end

  test "should create consent" do
    service = Service.create!(name: "New Service")
    assert_difference("Consent.count") do
      post consents_url, params: { consent: { citizen_id: @consent.citizen_id, service_id: service.id } }
    end
    assert_redirected_to consent_url(Consent.last)
  end

  test "should revoke consent" do
    patch revoke_consent_url(@consent)
    assert_redirected_to consent_url(@consent)
    assert_not_nil @consent.reload.revoked_at
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
    patch consent_url(@consent), params: { consent: { citizen_id: @consent.citizen_id, service_id: @consent.service_id } }
    assert_redirected_to consent_url(@consent)
  end

  test "patch cannot change revoked_at or granted_at" do
    consent = consents(:revoked)
    granted_at = consent.granted_at
    revoked_at = consent.revoked_at

    patch consent_url(consent), params: {
      consent: {
        citizen_id: consent.citizen_id,
        service_id: consent.service_id,
        granted_at: 5.years.ago,
        revoked_at: ""
      }
    }

    assert_redirected_to consent_url(consent)
    consent.reload
    assert_equal granted_at.to_i, consent.granted_at.to_i
    assert_equal revoked_at.to_i, consent.revoked_at.to_i
  end

  test "should destroy consent" do
    assert_difference("Consent.count", -1) do
      delete consent_url(@consent)
    end

    assert_redirected_to consents_url
  end
end
