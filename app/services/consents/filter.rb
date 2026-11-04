module Consents
  # Narrows a consent scope by status, service, and a name search.
  class Filter
    def initialize(scope, params)
      @scope = scope
      @params = params
    end

    def call
      apply_search(apply_service(apply_status(@scope))).order(granted_at: :desc)
    end

    private
      def apply_status(scope)
        case @params[:status]
        when "active" then scope.active
        when "revoked" then scope.where.not(revoked_at: nil)
        else scope
        end
      end

      def apply_service(scope)
        return scope if @params[:service_id].blank?

        scope.where(service_id: @params[:service_id])
      end

      def apply_search(scope)
        query = @params[:q].to_s.strip
        return scope if query.blank?

        like = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
        scope.joins(:citizen, :service).where(
          "citizens.name ILIKE :q OR services.name ILIKE :q",
          q: like
        )
      end
  end
end
