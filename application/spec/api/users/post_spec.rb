require 'spec_helper'

describe 'POST /api/users/login' do
  before :all do
    @u1 = create :user
  end

  it 'should login a user' do
    post "api/v1.0/users/login", :password => 'secret', :email => @u1.email
    payload = { user_id: @u1.id }
    expect(response_body[:data]).to eq(JWT.encode(payload, HMAC_SECRET, 'HS256'))
  end

  it 'should not login a wrong password' do
    post "api/v1.0/users/login", :password => 'wrongsecret', :email => @u1.email
    expect(response_body[:error_type]).to eq('forbidden')
  end

  it 'should require a password' do
    post "api/v1.0/users/login", :email => @u1.email
    expect(response_body[:error_type]).to eq('validation')
  end

  it 'should require an email' do
    post "api/v1.0/users/login", :password => 'secret'
    expect(response_body[:error_type]).to eq('validation')
  end
end

describe 'POST /api/users' do
  it 'should create a user' do
    post "api/v1.0/users",
      :password => 'new_secret',
      :email => Faker::Internet.email,
      :first_name => Faker::Name.first_name,
      :last_name => Faker::Name.last_name
    expect(response_body[:data][:id]).to eq(Api::Models::User.last.id)
  end
end