require 'rails_helper'

RSpec.describe Token, type: :model do
  describe 'validations' do
    let (:user) { create :user}
    let (:token) { build :token}
    let (:other_token) { build :other_token}

    it 'should validate presence' do
      token.token = nil
      expect(token.valid?).to be_falsey
      expect(token.errors.messages[:token]).to include("can't be blank")
    end

    it 'should validate uniqeness' do
      other_token.token = token.token
      other_token.save
      expect(token.valid?).to be_falsey
      expect(token.errors.messages[:token]).to include("has already been taken")
    end

    it 'should have token present after initialization' do
      expect(token.token).to be_present
      expect(token).to be_valid
    end
  end
end
