class Api
  module Auth
    extend ActiveSupport::Concern

    included do |base|
      helpers HelperMethods
    end

    module HelperMethods
      def authenticate!
        token = request.headers['Authorization']
        if token and !current_user
          token.slice! 'Bearer '
          decoded_token = JWT.decode token, HMAC_SECRET, true, { :algorithm => 'HS256' }
          @current_user = Models::User.find(id: decoded_token.first['user_id'])
        else
          @current_user = nil
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
