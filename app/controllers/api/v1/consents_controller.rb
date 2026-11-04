module Api
  module V1
    class ConsentsController < BaseController
      before_action :set_consent, only: %i[ show revoke ]

      def index
        @consents = policy_scope(Consent).includes(:citizen, :service).order(granted_at: :desc)
      end

      def show
      end

      def revoke
        ::Consents::Revoke.call(consent: @consent, user: Current.user)
        render :show
      end

      private
        def set_consent
          @consent = Consent.includes(:citizen, :service).find(params[:id])
          authorize @consent
        end
    end
  end
end
