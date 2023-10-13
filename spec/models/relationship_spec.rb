require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:relationship) { FactoryBot.create(:relationship) }
  # Relationshipモデルがfollower, followedというエイリアスでUserモデルと関連づけられていることを検証
  describe "check Relationship model belongs to User class as :follower and :followed" do
    it "follower belongs to User class" do
      expect(relationship.follower.class).to eq User
    end

    it "followed belongs to User class" do
      expect(relationship.followed.class).to eq User
    end
  end
  
  # Relationshipモデルのバリデーションテスト
  describe "check the validation of Relationship model" do 
    it "is valid with associated follower user and followed user" do
      expect(relationship).to be_valid
    end

    it "is invalid without an associated follower user" do
      relationship.follower = nil
      expect(relationship).to_not be_valid
    end

    it "is invalid without an associated followed user" do
      relationship.followed = nil
      expect(relationship).to_not be_valid
    end
  end
end