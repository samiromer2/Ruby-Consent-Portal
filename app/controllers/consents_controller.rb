class ConsentsController < ApplicationController
  include ConsentListing

  before_action :set_consent, only: %i[ show destroy revoke ]

  # GET /consents or /consents.json
  def index
    load_consent_page
  rescue Pagy::OverflowError
    redirect_to consents_path(request.query_parameters.merge(page: 1))
  end

  # GET /consents/1 or /consents/1.json
  def show
    @events = @consent.consent_events.includes(:user).order(:created_at)
  end

  # GET /consents/new
  def new
    @consent = Consent.new(citizen: Current.user.citizen)
    authorize @consent
  end

  # POST /consents or /consents.json
  def create
    @consent = Consent.new(consent_params)
    @consent.citizen = Current.user.citizen
    authorize @consent

    saved = false
    Consent.transaction do
      saved = @consent.save
      raise ActiveRecord::Rollback unless saved

      @consent.consent_events.create!(action: :granted, user: Current.user)
    end

    if saved
      redirect_to @consent, notice: "Consent was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # DELETE /consents/1 or /consents/1.json
  def destroy
    @consent.destroy!
    redirect_to consents_path, notice: "Consent was successfully destroyed.", status: :see_other
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to @consent, alert: "A consent with history cannot be deleted."
  end

  def revoke
    ::Consents::Revoke.call(consent: @consent, user: Current.user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @consent, notice: "Consent revoked." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_consent
      @consent = Consent.find(params.expect(:id))
      authorize @consent
    end

    # The citizen is always the signed-in user. granted_at and revoked_at are history.
    def consent_params
      params.expect(consent: [ :service_id ])
    end
end
