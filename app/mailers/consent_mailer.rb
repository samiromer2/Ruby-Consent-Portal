class ConsentMailer < ApplicationMailer
  def expired(consent)
    @consent = consent

    mail subject: "Your consent for #{consent.service.name} has expired", to: consent.citizen.email
  end
end
