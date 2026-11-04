class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  after_action :verify_authorized, if: -> { action_name != "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private
    def pundit_user
      Current.user
    end

    def user_not_authorized
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You are not allowed to do that." }
        format.json { head :forbidden }
      end
    end
end
