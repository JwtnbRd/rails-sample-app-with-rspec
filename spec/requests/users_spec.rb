require 'rails_helper'

RSpec.describe "Users", type: :request do
    describe "new action" do 
      it "allows users who are not logged-in to access" do
        get signup_path
        expect(response).to have_http_status(200)
      end
    end

    describe "edit action" do
      it "redirects users who are not logged-in to login_path" do
        user = double("user", name: "Fake User")

        get edit_user_path(user)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_url
      end
    end

    context "update action" do
      it "redirects users who are not logged-in to login_path" do
        user = double("user", name: "Fake User")

        patch user_path(user), params: { user: { name: "New Fake Name",
                                                  email: "newfake@example.com" }}
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_url
      end
    end

    context "index action" do 
      it "redirects users who are not logged-in to login_path" do
        get users_path
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_url
      end
    end

    context "destroy action" do 
      it "redirects users who are not logged-in to login_path" do 
        user = double("user", name: "Fake User") 

        expect {
          delete user_path(user)

          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to login_url
        }.to_not change(User, :count)
      end
    end

    context "following action" do
      it "redirects users who are not logged-in to login_path" do
        user = double("user", name: "Fake User") 

        get following_user_path(user)
        expect(response).to redirect_to login_path
      end
    end

    context "followers action" do
      it "redirects users who are not logged-in to login_path" do
        user = double("user", name: "Fake User") 

        get followers_user_path(user)
        expect(response).to redirect_to login_path
      end
    end
  end
