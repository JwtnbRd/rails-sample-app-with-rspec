require 'rails_helper'

RSpec.describe "UsersLogins", type: :system do
  before do
    driven_by(:rack_test) 
  end

  def full_title(string)
    base_title = "Ruby on Rails Tutorial Sample App"
    return "#{string} | #{base_title}"
  end

  let(:user) { FactoryBot.create(:user, :activated) }
  let(:title) { page.find('title', visible: false) }

  describe "login test" do
    it "allows user to login with valid email and password" do
      # ログインのワークフローをサポートモジュールに切り出し
      log_in_with_remember_me(user)

      expect(page).to have_current_path user_path(user)
      expect(page).to have_css "img.gravatar"
      expect(page).to have_selector "h1", text: user.name
      expect(title.native.children.text).to eq full_title(user.name)
      expect(page).to_not have_link("Log in", href: login_path)
      expect(page).to have_link("Log out", href: logout_path)
      expect(page).to have_link("Profile", href: user_path(user))
      expect(page).to have_content user.microposts.count.to_s
      # ページネーション関係はマイクロポスト０だと無理？
      # ファクトリで、マイクロポストをある程度持ったユーザーを作る必要がある？
      # マイクロポストUIのシステムスペックで書いた
    end

    it "doesn't allow user to login with invalid email" do
      get edit_account_activation_path(user.activation_token, email: user.email)

      visit login_path
      fill_in "Email", with: " "
      fill_in "Password", with: user.password
      click_button "Log in"
      
      expect(page).to have_current_path login_path
      expect(page).to have_content "Invalid email/password combination!"

      visit root_path
      expect(page).to_not have_content "Invalid email/password combination!"
    end

    it "doesn't allow user to login with invalid password" do
      get edit_account_activation_path(user.activation_token, email: user.email)

      visit login_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "invalid"
      click_button "Log in"
      
      expect(page).to have_current_path login_path
      expect(page).to have_content "Invalid email/password combination!"

      visit root_path
      expect(page).to_not have_content "Invalid email/password combination!"
    end
  end

  describe "logout test" do
    it "allows user to log out properly" do
      get edit_account_activation_path(user.activation_token, email: user.email)

      visit login_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      check "Remember me on this computer"
      click_button "Log in"

      click_link "Log out"

      expect(page).to have_current_path root_path
      expect(page).to have_link("Log in", href: login_path)
      expect(page).to have_link("Sign up now!", href: signup_path)
      expect(page).to_not have_link("Log out", href: logout_path)
      expect(page).to_not have_link("Profile", href: user_path(user))
    end

    it "should still work after logout in second window" do
      delete logout_path
      expect(response).to redirect_to root_path
    end

    # 統合テストの中でも、ユーザーのログイン状態に注目するものや、
    # remember me のクリックの結果、永続cookieの状態や,ユーザのremember tokenの状態を確認するという類のものは
    # 　ここに書くべきではない
  end
end
