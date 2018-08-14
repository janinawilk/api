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

    it 'should validate uniqueness' do
      user1 = create :user
      user2 = build :user, uid: user1.uid
      expect(user2.valid?).to be_falsey
      expect(user2.errors.messages[:uid]).to include('has already been taken')
      user2.uid = '99'
      # binding.pry
      user2.save
      expect(user2.valid?).to be_truthy
    end
  end
end
