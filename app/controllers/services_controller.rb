class ServicesController < ApplicationController
  before_action :set_service, only: %i[ show edit update destroy ]

  # GET /services or /services.json
  def index
    @services = policy_scope(Service).order(:name)
  end

  # GET /services/1 or /services/1.json
  def show
  end

  # GET /services/new
  def new
    @service = Service.new
    authorize @service
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services or /services.json
  def create
    @service = Service.new(service_params)
    authorize @service

    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: "Service was successfully created." }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /services/1 or /services/1.json
  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to @service, notice: "Service was successfully updated.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  # DELETE /services/1 or /services/1.json
  def destroy
    @service.destroy!

    respond_to do |format|
      format.html { redirect_to services_path, notice: "Service was successfully destroyed.", status: :see_other }
    end
  rescue ActiveRecord::DeleteRestrictionError
    respond_to do |format|
      format.html { redirect_to @service, alert: "A service with consent history cannot be deleted." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params.expect(:id))
      authorize @service
    end

    # Only allow a list of trusted parameters through.
    def service_params
      params.expect(service: [ :name, :description ])
    end
end
