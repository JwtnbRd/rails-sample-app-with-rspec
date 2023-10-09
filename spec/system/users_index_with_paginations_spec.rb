require 'rails_helper'

RSpec.describe "UsersIndexWithPaginations", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "testing users#index view" do
    let(:user) { FactoryBot.create(:user, :activated) }
    # ---  前提 ---- #
    # user インスタンスをモックで用意する。
    # ログイン機構はDBに存在しているユーザーインスタンスを扱うので、モックでは無理？

    # そのユーザーインスタンスは50個のfollowingユーザーがいる。
    # モックで50個のuserインスタンス配列を作る。
    # そのモックのユーザーのfollowed属性は全てそのユーザーインスタンス

    # その上で、/usersにアクセスした時、最初のページには30個のユーザーインスタンスが並んでいる。
    context "displays 30 users in first users#index page whose user who has 50 followings" do
      scenario "user who has 50 followings logges in and accesses users#index page" do
        n = 0
        following_users = []
        50.times do 
          following_users << double("user", name: "Fake following user #{n}")
          n += 1
        end
        allow(user).to receive(:following).and_return(following_users)
        # expect(user.following.length).to eq 50 

        visit login_path
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        check "Remember me on this computer"
        click_button "Log in"

        puts user.authenticated?(:activation, user.id)
        puts user.activated
        # save_and_open_page

        aggregate_failures do 
          expect(page).to have_content "Example User"
          expect(page).to have_current_path "/users/#{user.id}"
        end

      end
    end

    # さらにページネーションのリンクの数字の個数は４つある状態。
    context "has 4 pages of pagination" do 
    end
  end
end


