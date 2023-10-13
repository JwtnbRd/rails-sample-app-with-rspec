require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:micropost) { FactoryBot.create(:micropost) }

  it "is valid with content and related user_id" do 
    expect(micropost).to be_valid
  end

  it "is invalid without any related user" do 
    micropost.user = nil
    expect(micropost).to_not be_valid
  end

  it "is invalid without a content" do 
    micropost.content = nil
    expect(micropost).to_not be_valid
  end

  describe "length validation" do 
    context "when it has 141 characters" do 
      it "is invalid" do 
        micropost.content = "a" * 141
        expect(micropost).to_not be_valid
      end
    end

    context "when it has 140 characters" do
      it "is valid" do 
        micropost.content = "a" * 140
        expect(micropost).to be_valid
      end 
    end
  end

  it "is ordered most recent post firstly" do
    5.times do 
      FactoryBot.create(:micropost)
    end
    most_recent_post = FactoryBot.create(:micropost, :most_recent)
    expect(Micropost.first).to eq most_recent_post
  end
end
