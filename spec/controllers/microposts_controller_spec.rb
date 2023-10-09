require 'rails_helper'

RSpec.describe MicropostsController, type: :controller do
  #  ユーザーろぐいんをシミュレートするためのカスタムメソッド。どこに書けばいい？
  def log_in_as(user)
    session[:user_id] = user.id
  end
  
  def is_logged_in?(user)
    !session[:user_id].nil?
  end

  describe "#create" do
    context "as authenticated user" do 
      before do
        @user = FactoryBot.create(:user) 
      end

      # it "allows user to create new post" do 
      #   micropost_params = FactoryBot.attributes_for(:micropost)
      #   expect {
      #     post :create, params: { content: micropost_params, user_id: @user.id }
      #   }.to change(@user.microposts, :count).by(1)
      # end
    end
  end
end
