module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action { request.format = :json }
      before_action :authenticate_api_token

      after_action :verify_authorized, if: -> { action_name != "index" && Current.user }
      after_action :verify_policy_scoped, if: -> { action_name == "index" && Current.user }

      rescue_from Pundit::NotAuthorizedError, with: :forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private
        def pundit_user
          Current.user
        end

        def authenticate_api_token
          user = User.find_by(api_token: bearer_token) if bearer_token
          if user
            Current.api_user = user
          else
            render json: { error: "Unauthorized" }, status: :unauthorized
          end
        end

        def bearer_token
          request.authorization&.match(/\ABearer (.+)\z/)&.captures&.first
        end

        def forbidden
          render json: { error: "Forbidden" }, status: :forbidden
        end

        def not_found
          render json: { error: "Not found" }, status: :not_found
        end
    end
  end
end
