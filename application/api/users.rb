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
      { data: Models::User.create(params) }
    end
  end
end
