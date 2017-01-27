require 'spec_helper'

describe 'PATCH /api/users/:id/reset_password' do
  before :all do
    @u1 = create :user
  end

  it 'should not update a not logged in user' do
    patch "api/v1.0/users/#{@u1.id}/reset_password", :new_password => 'new_secret', :confirm_password => 'new_secret'
    expect(last_response.status).to eq(403)
    expect(response_body[:error_type]).to eq('forbidden')
  end

  it 'should update a user password' do
    login_as(@u1)
    patch "api/v1.0/users/#{@u1.id}/reset_password", :new_password => 'new_secret', :confirm_password => 'new_secret'
    expect(response_body[:id]).to eq(@u1.id)
    @u1.reload
    expect(@u1.password).to eq(Digest::SHA2.hexdigest('new_secret'))
  end

  it 'should not update if password confirm is wrong' do
    login_as(@u1)
    patch "api/v1.0/users/#{@u1.id}/reset_password", :new_password => 'new_secret', :confirm_password => 'new_wrong_secret'
    expect(last_response.status).to eq(400)
    expect(response_body[:error_type]).to eq('bad_request')
  end
end