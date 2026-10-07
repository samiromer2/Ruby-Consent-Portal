class CitizensController < ApplicationController
  before_action :set_citizen, only: %i[ show edit update destroy ]

  # GET /citizens or /citizens.json
  def index
    @citizens = Citizen.all
  end

  # GET /citizens/1 or /citizens/1.json
  def show
  end

  # GET /citizens/new
  def new
    @citizen = Citizen.new
  end

  # GET /citizens/1/edit
  def edit
  end

  # POST /citizens or /citizens.json
  def create
    @citizen = Citizen.new(citizen_params)

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
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_citizen
      @citizen = Citizen.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def citizen_params
      params.expect(citizen: [ :name, :email ])
    end
end
