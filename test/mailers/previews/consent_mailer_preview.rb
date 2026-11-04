# Preview all emails at http://localhost:3000/rails/mailers/consent_mailer
class ConsentMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/consent_mailer/expired
  def expired
    ConsentMailer.expired(Consent.includes(:citizen, :service).take)
  end
end
