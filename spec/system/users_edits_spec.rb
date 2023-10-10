require 'rails_helper'

RSpec.describe "UsersEdits", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { FactoryBot.create(:user) }

  describe "unsuccessful pattern" do
    it "doesn't allow user to update with an invalid name" do
      log_in_as(user)
      visit edit_user_path(user)

      fill_in "Name", with: ""
      fill_in "Email", with: "foo@invalid"
      fill_in "Password", with: user.password
      fill_in "Confirmation", with: user.password
      click_button "Save changes"
        
      expect(page).to have_content "Name can't be blank"
    end

    it "doesn't allow user to update with an invalid email" do
      log_in_as(user)
      visit edit_user_path(user)

      fill_in "Name", with: "Fake Name"
      fill_in "Email", with: ""
      fill_in "Password", with: user.password
      fill_in "Confirmation", with: user.password
      click_button "Save changes"
        
      expect(page).to have_content "Email can't be blank"
      expect(page).to have_content "Email is invalid"
    end

    it "doesn't allow user to update with an invalid password combination" do
      new_name = "New Fake Name"
      new_email = "newfakeemail@example.com"

      log_in_as(user)
      visit edit_user_path(user)
      fill_in "Name", with: new_name
      fill_in "Email", with: new_email
      fill_in "Password", with: "foobar"
      fill_in "Confirmation", with: ""
      click_button "Save changes"
        
      expect(page).to have_content "Password confirmation doesn't match Password"
      expect(user.reload.name).to_not eq new_name
      expect(user.reload.email).to_not eq new_email
    end

    # フレンドリーフォワーディングもついでにテストしている
    it "doesn't allow user who not logged in to edit" do 
      visit edit_user_path(user)
      expect(page).to have_current_path login_path

      log_in_as(user)
      expect(page).to have_current_path edit_user_path(user)
    end
  end

  describe "successful pattern" do
    it "allows user to update with a blank password" do
      new_name = "New Fake Name"
      new_email = "newfakeemail@example.com"
      
      log_in_as(user)
      visit edit_user_path(user)
      fill_in "Name", with: new_name
      fill_in "Email", with: new_email
      fill_in "Password", with: ""
      fill_in "Confirmation", with: ""
      click_button "Save changes"
      
      expect(user.reload.name).to eq new_name
      expect(user.reload.email).to eq new_email
    end
  end
end
