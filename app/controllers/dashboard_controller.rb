class DashboardController < ApplicationController
  include ConsentListing

  def show
    authorize :dashboard, :show?

    if Current.user.admin?
      @citizen_count = policy_scope(Citizen).count
      @service_count = policy_scope(Service).count
      @active_consent_count = policy_scope(Consent).active.count
      @revoked_consent_count = policy_scope(Consent).where.not(revoked_at: nil).count
      render :admin
    else
      params[:status] = "active" if params[:status].blank?
      load_consent_page
      render "consents/index"
    end
  rescue Pagy::OverflowError
    redirect_to root_path(request.query_parameters.merge(page: 1))
  end
end
