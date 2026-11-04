class CitizensController < ApplicationController
  before_action :set_citizen, only: %i[ show edit update destroy ]

  # GET /citizens or /citizens.json
  def index
    @citizens = policy_scope(Citizen).order(:name)
  end

  # GET /citizens/1 or /citizens/1.json
  def show
  end

  # GET /citizens/new
  def new
    @citizen = Citizen.new
    authorize @citizen
  end

  # GET /citizens/1/edit
  def edit
  end

  # POST /citizens or /citizens.json
  def create
    @citizen = Citizen.new(citizen_params)
    authorize @citizen

    respond_to do |format|
      if @citizen.save
        format.html { redirect_to @citizen, notice: "Citizen was successfully created." }
        format.json { render :show, status: :created, location: @citizen }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @citizen.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /citizens/1 or /citizens/1.json
  def update
    respond_to do |format|
      if @citizen.update(citizen_params)
        format.html { redirect_to @citizen, notice: "Citizen was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @citizen }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @citizen.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /citizens/1 or /citizens/1.json
  def destroy
    @citizen.destroy!

    respond_to do |format|
      format.html { redirect_to citizens_path, notice: "Citizen was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  rescue ActiveRecord::DeleteRestrictionError
    respond_to do |format|
      format.html { redirect_to @citizen, alert: "A citizen with consent history cannot be deleted." }
      format.json { head :conflict }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_citizen
      @citizen = Citizen.find(params.expect(:id))
      authorize @citizen
    end

    # verified is an admin decision. A citizen cannot mark themselves verified.
    def citizen_params
      allowed = [ :name, :email ]
      allowed << :verified if Current.user.admin?
      params.expect(citizen: allowed)
    end
end
