class ConsentsController < ApplicationController
  before_action :set_consent, only: %i[ show destroy revoke ]

  # GET /consents or /consents.json
  def index
    @consents = policy_scope(Consent).includes(:citizen, :service).order(granted_at: :desc)
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

    respond_to do |format|
      if saved
        format.html { redirect_to @consent, notice: "Consent was successfully created." }
        format.json { render :show, status: :created, location: @consent }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @consent.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /consents/1 or /consents/1.json
  def destroy
    @consent.destroy!

    respond_to do |format|
      format.html { redirect_to consents_path, notice: "Consent was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  rescue ActiveRecord::DeleteRestrictionError
    respond_to do |format|
      format.html { redirect_to @consent, alert: "A consent with history cannot be deleted." }
      format.json { head :conflict }
    end
  end

  def revoke
    ::Consents::Revoke.call(consent: @consent, user: Current.user)
    redirect_to @consent, notice: "Consent revoked."
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
