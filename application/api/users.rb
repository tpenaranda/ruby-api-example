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
      user = Models::User.find(email: params[:email])

      return api_response(error_type: 'bad_request') unless user
      return api_response(error_type: 'forbidden') if user.password != params[:password].strip

      payload = { user_id: user.id }

      { data: JWT.encode(payload, HMAC_SECRET, 'HS256') }
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
      #Send email confirmation
      user = Models::User.create(params)
      present(user, with: API::Entities::User)
    end

    desc 'Update a user'
    params do
      requires :id, type: Integer, desc: 'User ID'
      requires :password, type: String, desc: 'Password', coerce_with: Digest::SHA2.method(:hexdigest)
    end
    put ':id' do
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
    end

    desc 'Update a user password'
    params do
      requires :id, type: Integer, desc: 'User ID'
      requires :new_password, type: String, desc: 'New password', coerce_with: Digest::SHA2.method(:hexdigest)
      requires :confirm_password, type: String, desc: 'Password confirm', coerce_with: Digest::SHA2.method(:hexdigest)
    end
    patch ':id/reset_password' do
      authenticate!
      if not current_user or params[:id] != current_user.id
        return api_response(error_type: 'forbidden')
      elsif params[:new_password] != params[:confirm_password]
        return api_response(error_type: 'bad_request')
      end
      user = Models::User.find(id: params[:id]).update(password: params[:new_password])
      present(user, with: API::Entities::User)
      #Send password updated email
    end

  end
end
