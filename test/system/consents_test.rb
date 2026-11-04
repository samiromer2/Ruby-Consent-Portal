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
    assert_text "My consents"

    visit consent_url(consent)
    assert_selector ".badge-active", text: "Active"
    assert_text "No history yet."

    # Selenium's click does not activate this submit button under the current headless Chrome.
    find_button("Revoke consent").execute_script("this.form.requestSubmit(this)")

    assert_text "Consent revoked."
    assert_selector ".badge-revoked", text: "Revoked"
    assert_text "Revoked by #{user.email_address}"
    assert_no_button "Revoke consent"
    assert_not_nil consent.reload.revoked_at
  end
end
