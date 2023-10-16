require 'rails_helper'

RSpec.describe "Followings", type: :system do
  # support/capybara.rbに切り出したので不要
  # before do
  #   driven_by(:rack_test)
  # end

  let(:user) { FactoryBot.create(:user, :activated) }
  let(:other_user) { FactoryBot.create(:user, :activated) }
  # create_listでFactoryBotから複数のインスタンスを一気に作成、”以下〜ここまで”の部分は参考にしたシナリオ
  # create_listとtraitを合わせて使う場合の語順に注意。create_list(<作成したいファクトリ名>, <作成するインスタンス数>, *<トレイトやオーバーライドしたい項目>)の順
    let(:other_users) { FactoryBot.create_list(:user, 20, :activated) }
    
    before do 
      other_users[0..9].each do |other_user|
        user.active_relationships.create!(followed_id: other_user.id)
        user.passive_relationships.create!(follower_id: other_user.id)
      end
      log_in_as user
    end
    
    # followersとfollowingの数がちゃんと表示されているかを調べるテスト
    scenario "The number of following and follower is collect" do 
      click_on "following"
      expect(user.following.count).to eq 10
      user.following.each do |u|
        expect(page).to have_link u.name, href: user_path(u)
      end

      click_on "followers"
      expect(user.following.count).to eq 10
      user.followers.each do |u|
        expect(page).to have_link u.name, href: user_path(u)
      end
    end

    # [Follow]/[Unfollow]のボタンのテスト
    scenario "when user clicks on unfollow, the number of following increases by -1" do 
      visit user_path(other_users.first)
      expect do 
        click_on "Unfollow"
        expect(page).not_to have_link "Unfollow"
        # 次の行を入れる意味はAjaxの処理待ちのためとのこと。なしでもいけるっぽいが…
        visit current_path
      end.to change(user.following, :count).by(-1)
    end

    scenario "When user clicks on Follow, the number of followigin increases by 1" do 
      visit user_path(other_users.last)
      expect do 
        click_on "Follow"
        expect(page).to_not have_link "Follow"
        visit current_path
      end.to change(user.following, :count).by(1)
    end
  # ここまで

  describe "testing following and followers page UI" do 
    context "when a logged in user follows another user" do
      it "allows user to follow other user and displays following user properly in following_user_path" do 
        log_in_as user
        visit user_path(other_user)
        expect {
          click_button "Follow"
          expect(page).to have_selector "strong#followers", text: "1"
        }.to change(user.reload.following, :count).by(1)

        visit user_path(user)
        expect(page).to have_selector "strong#following", text: "1"
        click_link "1 following"
        expect(page).to have_current_path following_user_path(user)
        user.following.each do |following_user| 
          expect(page).to have_selector "a[href='#{user_path(following_user)}']", text: following_user.name
        end
      end
    end

    context "when another user follows a user" do 
      it "allows user to be followed by another user and displays followers properly in followers_user_path" do
        log_in_as other_user
        visit user_path(user)
        expect {
          click_button "Follow"
        }.to change(user.reload.followers, :count).by(1)
        click_link "Log out"

        log_in_as user
        visit user_path(user)
        expect(page).to have_selector "strong#followers", text: "1"
        click_link "1 followers"
        expect(page).to have_current_path followers_user_path(user)
        user.followers.each do |follower|
          expect(page).to have_selector "a[href='#{user_path(follower)}']", text: follower.name
        end
      end

      context "when a user unfollows another user" do
        it "allows user to unfollow another user" do
          log_in_as user
          visit user_path(other_user)
          expect {
            click_button "Follow"
            expect(page).to have_selector "strong#followers", text: "1"
          }.to change(user.reload.following, :count).by(1)

          expect {
            click_button "Unfollow"
            expect(page).to have_selector "strong#followers", text: "0"
          }.to change(user.reload.following, :count).by(-1)
        end

        it "allows user to be unfollowed by other user" do
          log_in_as other_user
          visit user_path(user)
          expect {
            click_button "Follow"
          }.to change(user.reload.followers, :count).by(1)
          click_link "Log out"
  
          log_in_as user
          visit user_path(user)
          expect(page).to have_selector "strong#followers", text: "1"
          click_link "Log out"

          log_in_as other_user
          visit user_path(user)
          expect {
            click_button "Unfollow"
            expect(page).to have_selector "strong#followers", text: "0"
          }.to change(user.reload.followers, :count).by(-1)
          click_link "Log out"

          log_in_as user
          visit user_path(user)
          expect(page).to have_selector "strong#followers", text: "0"
        end
      end
    end
  end
end
