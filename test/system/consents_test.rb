require "application_system_test_case"

class ConsentsTest < ApplicationSystemTestCase
  test "a user revokes a consent and sees the Revoked badge" do
    consent = consents(:one)

    visit consent_url(consent)
    assert_selector ".badge-active", text: "Active"

    click_on "Revoke consent"

    assert_text "Consent revoked."
    assert_selector ".badge-revoked", text: "Revoked"
    assert_no_button "Revoke consent"
    assert_not_nil consent.reload.revoked_at
  end
end
