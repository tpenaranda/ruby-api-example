require 'lib/abilities'
require 'lib/user_roles'

class Api
  module Models
    class User < Sequel::Model(:user)
      include AbilityList::Helpers
      include ApiHelpers::UserRoles

      many_to_one :company, class_name: 'Api::Models::Company', key: :Company_ID
      many_to_one :office, class_name: 'Api::Models::Office', key: :Office_ID
      many_to_many :doctors, class_name: 'Api::Models::Doctor',
                             join_table: :rep_doctor,
                             left_key: :User_ID,
                             right_key: :Doctor_ID
      many_to_one :address, class_name: 'Api::Models::Address',
                            key: :Personal_Address_ID
      nested_attributes :address

      def before_validation
        # set some default values before validating and creating a user for the first time
        unless id
          self.Login_Name = self.Email
          self.Total_Login_Count = 0
          self.Status = 1
        end
        super
      end

      def premium_access?
        in_group?(:premium_rep) || in_group?(:trial_rep)
      end

      def abilities
        @abilities ||= Abilities.new(self)
      end

      def full_name
        "#{self.First_Name} #{self.Last_Name}"
      end

      def membership_type_id
        case self.Membership_Type
        when 'Trial'
          1
        when 'Limited'
          2
        when 'Premium'
          3
        else
          nil
        end
      end

      def in_office?(office_id)
        return true if self.Office_ID == office_id
        SEQUEL_DB[:user_office].where(User_ID: id, Office_ID: office_id).any?
      end
    end
  end
end
