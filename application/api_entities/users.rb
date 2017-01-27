module API
  module Entities
    class User < Grape::Entity
      format_with(:iso_timestamp) { |dt| dt.iso8601 }
      root 'data'
      expose :email, documentation: { type: "String", desc: "Email address." }
      expose :first_name, documentation: { type: "String", desc: "First Name." }
      expose :last_name, documentation: { type: "String", desc: "Last Name." }
      expose :born_on, documentation: { type: "String", desc: "Date of birth." }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end