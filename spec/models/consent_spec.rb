require "rails_helper"

RSpec.describe Consent do
  it "is active until it is revoked" do
    consent = create(:consent)

    expect(consent).to be_active

    consent.revoke!

    expect(consent.reload).not_to be_active
  end
end
