require 'rails_helper'

RSpec.describe "FollowingsWithJs", type: :system do
  before do
    driven_by(:selenium_chrome)
  end

  let(:user) { FactoryBot.create(:user, :activated) }
  let(:other_user) { FactoryBot.create(:user, :activated) }

  describe "testing following and followers page UI" do 
    scenario "when a logged in user follows another user, it allows user to follow other user", js: true do 
        log_in_as user
        visit user_path(other_user)
        expect {
          click_button "Follow"
          expect(page).to have_selector "strong#followers", text: "1"
          expect(page).to have_css "form[action='/relationships/#{Relationship.last.id}']"
          expect(page).to have_css "input[value='Unfollow']"
        }.to change(user.reload.following, :count).by(1)
    end

    scenario "when a user unfollows another user, it allows the user to unfollow other user", js: true do 
      log_in_as user
      visit user_path(other_user)
      expect {
        click_button "Follow"
        expect(page).to have_selector "strong#followers", text: "1"
      }.to change(user.reload.following, :count).by(1)

      expect {
        click_button "Unfollow"
        expect(page).to have_selector "strong#followers", text: "0"
        expect(page).to have_css "form[action='/relationships']"
        expect(page).to have_css "input[value='Follow']"
      }.to change(user.reload.following, :count).by(-1)
    end
  end
end

