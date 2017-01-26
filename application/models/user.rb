require 'lib/abilities'

class Api
  module Models
    class User < Sequel::Model(:users)
      include AbilityList::Helpers

      def abilities
        @abilities ||= Abilities.new(self)
      end

      def full_name
        "#{first_name} #{last_name}"
      end
    end
  end
end
