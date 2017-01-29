require 'spec_helper'

describe 'PATCH /api/users/:id/reset_password' do
  before :all do
    @u1 = create :user
  end

  it 'does not update a not logged in user' do
    patch "api/v1.0/users/#{@u1.id}/reset_password", :new_password => 'new_secret', :new_password_confirmation => 'new_secret'
    expect(last_response.status).to eq(403)
    expect(response_body[:error_type]).to eq('forbidden')
  end

  it 'does update a user password' do
    login_as(@u1)
    patch "api/v1.0/users/#{@u1.id}/reset_password", :new_password => 'new_secret', :new_password_confirmation => 'new_secret'
    expect(response_body[:email]).to eq(@u1.email)
    @u1.reload
    expect(@u1.password).to eq(Digest::SHA2.hexdigest('new_secret'))
  end

  it 'does not update if password confirm is wrong' do
    login_as(@u1)
    patch "api/v1.0/users/#{@u1.id}/reset_password", :new_password => 'new_secret', :new_password_confirmation => 'new_wrong_secret'
    expect(last_response.status).to eq(400)
    expect(response_body[:errors][:new_password_confirmation]).to be_truthy
  end
end