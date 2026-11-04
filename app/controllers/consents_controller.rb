class ConsentsController < ApplicationController
  before_action :set_consent, only: %i[ show edit update destroy revoke ]

  # GET /consents or /consents.json
  def index
    @consents = policy_scope(Consent).includes(:citizen, :service).order(granted_at: :desc)
  end

  # GET /consents/1 or /consents/1.json
  def show
  end

  # GET /consents/new
  def new
    @consent = Consent.new(citizen: Current.user.citizen)
    authorize @consent
  end

  # GET /consents/1/edit
  def edit
  end

  # POST /consents or /consents.json
  def create
    @consent = Consent.new(consent_params)
    @consent.citizen = Current.user.citizen
    authorize @consent

    respond_to do |format|
      if @consent.save
        format.html { redirect_to @consent, notice: "Consent was successfully created." }
        format.json { render :show, status: :created, location: @consent }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @consent.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /consents/1 or /consents/1.json
  def update
    respond_to do |format|
      if @consent.update(consent_params)
        format.html { redirect_to @consent, notice: "Consent was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @consent }
      else
        format.html { render :edit, status: :unprocessable_content }
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
  end

  def revoke
    @consent.revoke!
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
