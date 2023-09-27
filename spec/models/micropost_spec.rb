require 'rails_helper'

RSpec.describe Micropost, type: :model do
  before do 
    @user = FactoryBot.create(:user)
    @micropost = FactoryBot.create(:micropost)
    @micropost.user = @user
  end

  it "is valid with content and related user_id" do 
    expect(@micropost).to be_valid
  end

  it "is invalid without any related user" do 
    @micropost.user = nil
    expect(@micropost).to_not be_valid
  end

  it "is invalid without a content" do 
    @micropost.content = nil
    expect(@micropost).to_not be_valid
  end

  it "allows its content with at most 140 characters" do 
    @micropost.content = "a" * 141
    expect(@micropost).to_not be_valid
  end

  it "is ordered most recent post firstly" do
    most_recent_post = FactoryBot.create(:micropost, :most_recent)
    expect(most_recent_post).to eq Micropost.first
  end
end
