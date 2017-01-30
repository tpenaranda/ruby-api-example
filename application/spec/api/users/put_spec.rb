require 'spec_helper'

describe 'PUT /api/users/:id' do
  before :each do
    @u1 = create :user
  end

  it 'does not update a not logged in user' do
    put "api/v1.0/users/#{@u1.id}", :first_name => 'new_first_name'
    expect(last_response.status).to eq(403)
    expect(response_body[:error_type]).to eq('forbidden')
  end

  it 'does update a user first_name' do
    user_before = @u1.dup
    login_as(@u1)
    put "api/v1.0/users/#{@u1.id}", :first_name => 'new_first_name'
    expect(last_response.status).to eq(200)
    @u1.reload
    expect(@u1.first_name).to eq('new_first_name')
    expect(@u1.last_name).to eq(user_before.last_name)
    expect(@u1.email).to eq(user_before.email)
    expect(@u1.password).to eq(user_before.password)
  end

  it 'does update a user last_name' do
    user_before = @u1.dup
    login_as(@u1)
    put "api/v1.0/users/#{@u1.id}", :last_name => 'new_last_name'
    expect(last_response.status).to eq(200)
    @u1.reload
    expect(@u1.first_name).to eq(user_before.first_name)
    expect(@u1.last_name).to eq('new_last_name')
    expect(@u1.email).to eq(user_before.email)
    expect(@u1.password).to eq(user_before.password)
  end

  it 'does update a user email' do
    user_before = @u1.dup
    login_as(@u1)
    put "api/v1.0/users/#{@u1.id}", :email => 'new_mail@test.com'
    expect(last_response.status).to eq(200)
    @u1.reload
    expect(@u1.first_name).to eq(user_before.first_name)
    expect(@u1.last_name).to eq(user_before.last_name)
    expect(@u1.email).to eq('new_mail@test.com')
    expect(@u1.password).to eq(user_before.password)
  end

  it 'does not update the user password at this endpoint' do
    user_before = @u1.dup
    login_as(@u1)
    put "api/v1.0/users/#{@u1.id}", :password => 'new_password'
    expect(last_response.status).to eq(200)
    @u1.reload
    expect(@u1.first_name).to eq(user_before.first_name)
    expect(@u1.last_name).to eq(user_before.last_name)
    expect(@u1.email).to eq(user_before.email)
    expect(@u1.password).to eq(user_before.password)
  end

  it 'does not update another user than the one logged in' do
    login_as(@u1)
    u2 = create :user
    put "api/v1.0/users/#{u2.id}", :password => 'new_secret'
    expect(last_response.status).to eq(403)
    expect(response_body[:error_type]).to eq('forbidden')
  end
end