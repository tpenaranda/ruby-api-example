require 'spec_helper'

describe 'PUT /api/users/:id' do
  before :all do
    @u1 = create :user
    @u2 = create :user
  end

  it 'does not update a not logged in user' do
    put "api/v1.0/users/#{@u1.id}", :password => 'new_secret'
    expect(last_response.status).to eq(403)
    expect(response_body[:error_type]).to eq('forbidden')
  end

  it 'does update a user' do
    login_as(@u1)
    put "api/v1.0/users/#{@u1.id}", :password => 'new_secret'
    expect(last_response.status).to eq(200)
    expect(response_body[:email]).to eq(@u1.email)
  end

  it 'does ask for a password' do
    login_as(@u1)
    put "api/v1.0/users/#{@u1.id}"
    expect(last_response.status).to eq(400)
    expect(response_body[:error_type]).to eq('validation')
  end

  it 'does not update another user than the one logged in' do
    login_as(@u1)
    put "api/v1.0/users/#{@u2.id}", :password => 'new_secret'
    expect(last_response.status).to eq(403)
    expect(response_body[:error_type]).to eq('forbidden')
  end
end