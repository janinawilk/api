require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validation' do
    it 'should validate presence' do
      expect(build :user).to be_valid
      user = build :user, uid: '', login: '', provider: ''
      user.save
      expect(user.errors.messages[:uid]).to include("can't be blank")
      expect(user.errors.messages[:login]).to include("can't be blank")
      expect(user.errors.messages[:provider]).to include("can't be blank")
    end
  end
end
