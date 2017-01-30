require 'ostruct'

class Api
  resource :users do
    params do
      includes :basic_search
    end

    desc 'Login an user'
    params do
      requires :email, type: String, desc: 'Email address'
      requires :password, type: String, desc: 'Password', coerce_with: Digest::SHA2.method(:hexdigest)
    end
    post 'login' do
      begin
        user = Models::User.find(email: params[:email])
        if user.password == params[:password].strip
          payload = { user_id: user.id }
          { data: JWT.encode(payload, HMAC_SECRET, 'HS256') }
        else
          api_response(error_type: 'forbidden')
        end
      rescue
        api_response(error_type: 'bad_request')
      end
    end

    desc 'Return the users list'
    get do
      users = Models::User.all()
      present(users, with: API::Entities::User)
    end

    desc 'Create a user'
    params do
      requires :first_name, type: String, desc: 'First name'
      requires :last_name, type: String, desc: 'Last Name'
      requires :email, type: String, desc: 'Email address'
      requires :password, type: String, desc: 'Password', coerce_with: Digest::SHA2.method(:hexdigest)
      optional :born_on, type: Date, desc: 'Date of birth'
    end
    post do
      begin
        validator = UserCreateValidator.new(params).validate
        if validator.success?
          user = Models::User.create(params)
          UserMailer.perform_async(user.email, 'You were successfully registered.')
          present(user, with: API::Entities::User)
        else
          { 'errors' => validator.errors }
        end
      rescue
        api_response(error_type: 'bad_request')
      end
    end

    desc 'Update a user'
    params do
      requires :id, type: Integer, desc: 'User ID'
      requires :password, type: String, desc: 'Password', coerce_with: Digest::SHA2.method(:hexdigest)
    end
    put ':id' do
      validator = UserUpdateValidator.new(params).validate
      if validator.success?
        begin
          authenticate!
          user_to_update = Models::User.find(id: params[:id])
          raise unless user_to_update
          return api_response(error_type: 'forbidden') unless current_user.can?(:edit, user_to_update)
          user = Models::User.find(id: params[:id]).update(password: params[:password])
        rescue
          return api_response(error_type: 'bad_request')
        end
        present(user, with: API::Entities::User)
      else
        { 'errors' => validator.errors }
      end
    end

    desc 'Update a user password'
    params do
      requires :id, type: Integer, desc: 'User ID'
      requires :new_password, type: String, desc: 'New password'
      requires :new_password_confirmation, type: String, desc: 'Password confirm'
    end
    patch ':id/reset_password' do
      begin
        authenticate!
        if current_user and current_user.can?(:edit, Models::User.find(id: params[:id]))
          validator = UserPasswordUpdateValidator.new(OpenStruct.new(params)).validate
          if validator.success?
            new_password_sum = Digest::SHA2.hexdigest(params[:new_password])
            user = Models::User.find(id: params[:id]).update(password: new_password_sum)
            UserMailer.perform_async(user.email, 'Password successfully updated.')
            present(user, with: API::Entities::User)
          else
            status 400
            { 'errors' => validator.errors }
          end
        else
          api_response(error_type: 'forbidden')
        end
      rescue
        api_response(error_type: 'bad_request')
      end
    end
  end
end
