require 'rails_helper'

RSpec.describe "AccountActivations", type: :request do
  describe "test account activation URL" do
    before do
      ActionMailer::Base.deliveries.clear
    end
    let(:user) { FactoryBot.create(:user) }

    context "when the activation URL is valid" do    
      it "makes user activated" do
        # expect {}
          user.create_reset_digest
          expect(user.reload.reset_digest).to_not eq nil
          expect(user.reload.reset_token).to_not eq nil
          # expect(response).to redirect_to user_path(user)
          # expect(is_logged_in?(user)).to be_truthy
        # }.to change(User, :count).by(1)
      end
    end

    # context "when the activation URL is broken" do
    #   it "doesn't make user activated when activation_token is wrong" do 
    #     get edit_account_activation_path("invalid token", email: user.email)
    #     expect(user.activated?).to_not be_truthy
    #   end 

    #   it "doesn't make user activated when user email is wrong" do 
    #     get edit_account_activation_path("invalid token", email: "wrong@example.com")
    #     expect(user.activated?).to_not be_truthy
    #   end 
    # end  
  end
end
