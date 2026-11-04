require "test_helper"

class Api::V1::ConsentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @consent = consents(:one)
    @headers = { Authorization: "Bearer #{users(:one).api_token}" }
  end

  test "index requires a token" do
    get api_v1_consents_url, as: :json
    assert_response :unauthorized
    assert_equal "Unauthorized", response.parsed_body["error"]
  end

  test "index returns the citizen's consents" do
    get api_v1_consents_url, headers: @headers, as: :json
    assert_response :success

    names = response.parsed_body.fetch("consents").map { |consent| consent.dig("citizen", "name") }
    assert_includes names, citizens(:one).name
    assert_not_includes names, citizens(:two).name
  end

  test "index returns every consent for an admin" do
    get api_v1_consents_url, headers: { Authorization: "Bearer #{users(:admin).api_token}" }, as: :json
    assert_response :success

    names = response.parsed_body.fetch("consents").map { |consent| consent.dig("citizen", "name") }
    assert_includes names, citizens(:one).name
    assert_includes names, citizens(:two).name
  end

  test "show returns one consent" do
    get api_v1_consent_url(@consent), headers: @headers, as: :json
    assert_response :success
    assert_equal @consent.id, response.parsed_body["id"]
    assert_equal "active", response.parsed_body["status"]
    assert_equal services(:one).name, response.parsed_body.dig("service", "name")
  end

  test "show forbids another citizen's consent" do
    get api_v1_consent_url(consents(:revoked)), headers: @headers, as: :json
    assert_response :forbidden
  end

  test "show is not found for a missing consent" do
    get api_v1_consent_url(id: 0), headers: @headers, as: :json
    assert_response :not_found
  end

  test "revoke requires a token" do
    patch revoke_api_v1_consent_url(@consent), as: :json
    assert_response :unauthorized
    assert_nil @consent.reload.revoked_at
  end

  test "revoke withdraws the citizen's consent" do
    patch revoke_api_v1_consent_url(@consent), headers: @headers, as: :json
    assert_response :success
    assert_equal "revoked", response.parsed_body["status"]
    assert_not_nil @consent.reload.revoked_at
    assert @consent.consent_events.exists?(action: "revoked", user: users(:one))
  end

  test "revoke forbids an admin from withdrawing someone else's consent" do
    patch revoke_api_v1_consent_url(@consent), headers: { Authorization: "Bearer #{users(:admin).api_token}" }, as: :json
    assert_response :forbidden
    assert_nil @consent.reload.revoked_at
  end

  test "revoke rejects a token that does not match" do
    patch revoke_api_v1_consent_url(@consent), headers: { Authorization: "Bearer not-a-token" }, as: :json
    assert_response :unauthorized
  end
end
