module ConsentListing
  extend ActiveSupport::Concern

  private
    def load_consent_page
      scope = Consents::Filter.new(policy_scope(Consent), params).call
      @pagy, @consents = pagy(:offset, scope.includes(:citizen, :service), raise_range_error: true)
      @services = policy_scope(Service).order(:name)
    end
end
