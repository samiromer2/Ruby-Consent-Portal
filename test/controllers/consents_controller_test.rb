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

  test "should create consent for the signed-in citizen" do
    service = Service.create!(name: "New Service")
    assert_difference([ "Consent.count", "ConsentEvent.count" ], 1) do
      post consents_url, params: { consent: { citizen_id: citizens(:two).id, service_id: service.id } }
    end
    consent = Consent.last
    assert_redirected_to consent_url(consent)
    assert_equal users(:one).citizen, consent.citizen

    event = consent.consent_events.sole
    assert event.granted?
    assert_equal users(:one), event.user
  end

  test "index lists only the signed-in citizen's consents" do
    get consents_url
    assert_match citizens(:one).name, response.body
    assert_no_match citizens(:two).name, response.body
  end

  test "admin index lists every consent" do
    sign_in_as(users(:admin))
    get consents_url
    assert_match citizens(:one).name, response.body
    assert_match citizens(:two).name, response.body
  end

  test "cannot open another citizen's consent" do
    get consent_url(consents(:old))
    assert_redirected_to root_url
    assert_equal "You are not allowed to do that.", flash[:alert]
  end

  test "cannot revoke another citizen's consent" do
    consent = consents(:old)
    patch revoke_consent_url(consent)
    assert_redirected_to root_url
    assert_nil consent.reload.revoked_at
  end

  test "should revoke consent" do
    assert_difference("ConsentEvent.count", 1) do
      patch revoke_consent_url(@consent)
    end
    assert_redirected_to consent_url(@consent)
    assert_not_nil @consent.reload.revoked_at

    event = @consent.consent_events.sole
    assert event.revoked?
    assert_equal users(:one), event.user

    follow_redirect!
    assert_match "by #{users(:one).email_address}", response.body
  end

  test "cannot revoke a consent twice" do
    sign_in_as(users(:two))
    consent = consents(:revoked)
    revoked_at = consent.revoked_at

    assert_no_difference("ConsentEvent.count") do
      patch revoke_consent_url(consent)
    end

    assert_redirected_to root_url
    assert_equal revoked_at.to_i, consent.reload.revoked_at.to_i
  end

  test "should show consent" do
    get consent_url(@consent)
    assert_response :success
    assert_match "No history yet.", response.body
  end

  test "consents cannot be edited" do
    sign_in_as(users(:two))
    consent = consents(:revoked)
    service_id = consent.service_id
    granted_at = consent.granted_at
    revoked_at = consent.revoked_at

    patch consent_url(consent), params: {
      consent: { service_id: services(:one).id, granted_at: 5.years.ago, revoked_at: "" }
    }

    assert_response :not_found
    consent.reload
    assert_equal service_id, consent.service_id
    assert_equal granted_at.to_i, consent.granted_at.to_i
    assert_equal revoked_at.to_i, consent.revoked_at.to_i
  end

  test "should destroy consent" do
    assert_difference("Consent.count", -1) do
      delete consent_url(@consent)
    end

    assert_redirected_to consents_url
  end

  test "cannot delete a consent that has history" do
    @consent.consent_events.create!(action: :granted, user: users(:one))

    assert_no_difference([ "Consent.count", "ConsentEvent.count" ]) do
      delete consent_url(@consent)
    end

    assert_redirected_to consent_url(@consent)
    assert_equal "A consent with history cannot be deleted.", flash[:alert]
  end
end
