module ConsentListing
  extend ActiveSupport::Concern

  private
    def load_consent_page
      scope = Consents::Filter.new(policy_scope(Consent), params).call
      @pagy, @consents = pagy(scope.includes(:citizen, :service))
      @services = policy_scope(Service).order(:name)
    end
end
