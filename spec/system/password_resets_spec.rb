require 'rails_helper'

RSpec.describe "PasswordResets", type: :system do
  before do
    driven_by(:rack_test)
    ActionMailer::Base.deliveries.clear
  end

  let(:user) { FactoryBot.create(:user, :activated) }
  let(:user_with_activated) { FactoryBot.create(:user, :activated) }


  describe "test static part and form in password reset path" do
    scenario "anyone can access password reset path" do 
      visit login_path
      click_link "forgot password"
      expect(page).to have_content "Forgot password"
      expect(page).to have_current_path password_resets_new_path
    end
    
    scenario "user typed invalid email in the form" do
      visit login_path
      click_link "forgot password"
      fill_in "Email", with: " "
      click_button "Submit"
      expect(page).to have_content "Email address not found"
    end
  end

  describe "test password reset email" do
    scenario "user got an email and set reset_digest when typed valid email" do
      visit login_path
      click_link "forgot password"
      expect(user.reset_digest).to be nil
      expect {
        fill_in "Email", with: user.email
        click_button "Submit"
        expect(page).to have_current_path root_url
        expect(user.reload.reset_digest).to_not eq nil
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe "test URL for password reset" do 
    context "user should be redirected to root path with invalid infomation" do
      scenario "reset with wrong email" do
        visit login_path
        click_link "forgot password"
        expect(user_with_activated.reset_digest).to be nil
        fill_in "Email", with: user.email
        click_button "Submit"
        expect(page).to have_current_path root_path


        # user.reset_tokenがどうやってもnilのままなので、これ以上は無理

      end 
    end
  end
end
