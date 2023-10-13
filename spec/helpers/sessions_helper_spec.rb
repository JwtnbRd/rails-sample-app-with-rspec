require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let(:user) { FactoryBot.create(:user) }
  
  describe "#log_in method" do 
    context "when log_in method is called to user instance" do
      it "sets current_user as a user" do
        log_in user 
        expect(current_user).to eq user
      end

      it "makes logged_in? method to return true" do
        log_in user
        expect(logged_in?).to be_truthy
      end
    end
  end

  describe "#log_out method" do 
    # reset_sessionメソッドが使えなかった
    context "when session's data was deleted" do
      it "turns current_user nil" do 
        log_in user
        expect {
          session[:user_id] = nil
          session[:session_token] = nil
        }.to change{ current_user }.from(user).to(nil) 
        expect(logged_in?).to_not eq nil
      end
    end

    context "when remembered user logges out" do  
      it "makes user be forgotten and current_user nil" do
        remember user
        forget user
        aggregate_failures do
          expect(logged_in?).to_not be_truthy
          expect(current_user).to eq nil 
          expect(cookies[:user_id]).to eq nil
          expect(cookies[:remember_token]).to eq nil
        end
      end
    end
  end

  describe "remember method" do
    context "when this method is called" do
      it "generates current_user" do
        remember user
        expect(current_user).to eq user
      end

      it "also makes user to log in" do
        remember user
        expect(logged_in?).to be_truthy
      end
    end
  end

  describe "current_user" do 
    context "when remember digest is wrong" do
      it "returns nil" do
        user.update_attribute(:remember_digest, User.digest(User.new_token))
        expect(current_user).to eq nil
      end
    end
  end
end
