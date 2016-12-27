class Api
  module Auth
    extend ActiveSupport::Concern

    included do |base|
      helpers HelperMethods
    end

    module HelperMethods
      def authenticate!
        # Library to authenticate user can go here
      end

      def current_user
        @current_user
      end
    end
  end
end
