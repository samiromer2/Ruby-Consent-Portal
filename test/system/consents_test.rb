require "application_system_test_case"

class ConsentsTest < ApplicationSystemTestCase
  test "a user revokes a consent and sees the Revoked badge" do
    user = users(:one)
    consent = consents(:one)

    visit new_session_url
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_text user.email_address

    visit consent_url(consent)
    assert_selector ".badge-active", text: "Active"

    click_on "Revoke consent"

    assert_text "Consent revoked."
    assert_selector ".badge-revoked", text: "Revoked"
    assert_no_button "Revoke consent"
    assert_not_nil consent.reload.revoked_at
  end
end
