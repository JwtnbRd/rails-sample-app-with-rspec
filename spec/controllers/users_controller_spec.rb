require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "#new" do 
    it "responds successfully" do 
      get :new
      expect(response).to be_successful
    end
  end

 
    context "as logged-in user" do
      before do
        @user = FactoryBot.create(:user)
      end

      it "allows logged-in user to access to edit" do
        log_in_as(@user)
        get :edit, params: { id: @user.id }
        expect(response).to be_successful
      end

      it "allows user to log in" do
        log_in_as @user
        expect(is_logged_in? @user).to eq true
      end
    end

    context "as a non-logged-in user" do 
      it "returns a :see_other response" do 
        get :index
        expect(response).to have_http_status(:see_other)
      end

      it "redirects signup_path" do 
        get :index
        expect(response).to redirect_to login_path
      end
    end
end
