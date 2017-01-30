require 'spec_helper'

describe 'POST /api/users/login' do
  before :all do
    @u1 = create :user
  end

  it 'does login a user' do
    post "api/v1.0/users/login", :password => 'secret', :email => @u1.email
    payload = { user_id: @u1.id }
    expect(response_body[:data]).to eq(JWT.encode(payload, HMAC_SECRET, 'HS256'))
  end

  it 'does not login a wrong password' do
    post "api/v1.0/users/login", :password => 'wrongsecret', :email => @u1.email
    expect(response_body[:error_type]).to eq('forbidden')
  end

  it 'does require a password' do
    post "api/v1.0/users/login", :email => @u1.email
    expect(response_body[:error_type]).to eq('validation')
  end

  it 'does require an email' do
    post "api/v1.0/users/login", :password => 'secret'
    expect(response_body[:error_type]).to eq('validation')
  end
end

describe 'POST /api/users' do
  it 'does create a user' do
    post "api/v1.0/users", {
        :password => 'new_secret',
        :email => Faker::Internet.email,
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name
    }
    expect(response_body[:email]).to eq(Api::Models::User.last.email)
  end

  it 'does send a email after a new user is created' do
    Mail::TestMailer.deliveries.clear
    post "api/v1.0/users", {
        :password => 'new_secret',
        :email => Faker::Internet.email,
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name
    }
    expect(Mail::TestMailer.deliveries.size).to eq(1)
  end

  it 'does not create a user if password is missing' do
    post "api/v1.0/users", {
      :email => Faker::Internet.email,
      :first_name => Faker::Name.first_name,
      :last_name => Faker::Name.last_name
    }
    expect(last_response.status).to eq(400)
    expect(response_body[:error_type]).to eq('validation')
    expect(response_body[:errors][:password]).to be_truthy
    expect(response_body[:errors].size).to be(1)
  end

  it 'does not create a user if email is missing' do
    post "api/v1.0/users", {
      :password => 'new_secret',
      :first_name => Faker::Name.first_name,
      :last_name => Faker::Name.last_name
    }
    expect(last_response.status).to eq(400)
    expect(response_body[:error_type]).to eq('validation')
    expect(response_body[:errors][:email]).to be_truthy
    expect(response_body[:errors].size).to be(1)
  end

  it 'does not create a user if first_name is missing' do
    post "api/v1.0/users", {
      :password => 'new_secret',
      :email => Faker::Internet.email,
      :last_name => Faker::Name.last_name
    }
    expect(last_response.status).to eq(400)
    expect(response_body[:error_type]).to eq('validation')
    expect(response_body[:errors][:first_name]).to be_truthy
    expect(response_body[:errors].size).to be(1)
  end

  it 'does not create a user if last_name is missing' do
    post "api/v1.0/users", {
      :password => 'new_secret',
      :email => Faker::Internet.email,
      :first_name => Faker::Name.first_name
    }
    expect(last_response.status).to eq(400)
    expect(response_body[:error_type]).to eq('validation')
    expect(response_body[:errors][:last_name]).to be_truthy
    expect(response_body[:errors].size).to be(1)
  end
end