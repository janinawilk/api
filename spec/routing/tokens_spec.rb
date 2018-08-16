require 'rails_helper'

describe 'token' do
  it 'should root to articles index' do
    expect(post '/login').to route_to('tokens#create')
  end

  it 'should route to tokens delete' do
    expect(delete '/login').to route_to('tokens#destroy')
  end
end
