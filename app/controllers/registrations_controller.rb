class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :skip_authorization
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.build_citizen(name: params[:name], email: @user.email_address)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Account created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def registration_params
      params.expect(user: [ :email_address, :password, :password_confirmation ])
    end
end
