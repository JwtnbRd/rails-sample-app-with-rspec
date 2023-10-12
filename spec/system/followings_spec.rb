require 'rails_helper'

RSpec.describe "Followings", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { FactoryBot.create(:user, :activated) }
  let(:other_user) { FactoryBot.create(:user, :activated) }

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
