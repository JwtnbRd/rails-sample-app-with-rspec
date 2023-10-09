require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SessionsHelper, type: :helper do
  describe "testing if helper methods in sessions_helper works properly" do 
    let(:user) { FactoryBot.create(:user) }

    context "helpers for login" do
      it "sets logged in user as current_user" do
        log_in user 
        expect(current_user).to eq user
      end

      it "returns true when user logged in" do
        log_in user
        expect(logged_in?).to be_truthy
      end
    end

    context "helpers for logout" do
      it "turns current_user nil when session is cleared" do 
        log_in user
        expect {
          session[:user_id] = nil
          session[:session_token] = nil
        }.to change{ current_user }.from(user).to(nil) 
      end

      it "makes user who has remember_token be logged out" do
        remember user
        expect {
          forget user
        }.to change { current_user }.from(user).to(nil) 
      end
    end

    context "helpers for remember me" do
      it "also generates current_user with remember method" do
        remember user
        expect(current_user).to eq user
      end

      it "also makes user to log in with remember method" do
        remember user
        expect(logged_in?).to be_truthy
      end
    end

    context "current_user helper" do
      it "returns nil when user's remember digest is wrong" do
        user.update_attribute(:remember_digest, User.digest(User.new_token))
        expect(current_user).to eq nil
      end
    end
  end
end
