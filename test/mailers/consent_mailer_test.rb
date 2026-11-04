require "test_helper"

class ConsentMailerTest < ActionMailer::TestCase
  test "expired tells the citizen which service expired" do
    consent = consents(:old)
    email = ConsentMailer.expired(consent)

    assert_equal [ "bob@example.com" ], email.to
    assert_equal "Your consent for Health Card Renewal has expired", email.subject
    assert_match "Bob Singh", email.body.encoded
    assert_match "Health Card Renewal", email.body.encoded
  end
end
