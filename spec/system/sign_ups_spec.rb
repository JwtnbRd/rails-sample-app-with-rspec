require 'rails_helper'

RSpec.describe "Sign-ups", type: :system do
  before do
    # support/capybara.rbに切り出したので不要
    # driven_by(:rack_test)
    ActionMailer::Base.deliveries.clear
  end

  let(:user) { FactoryBot.build(:user) }
  let(:created_user) { FactoryBot.create(:user) }

  # 新しいユーザーのサインイン時のシミュレーション
  describe "testing the behavior when the new user trying to sign in" do 
    include ActiveJob::TestHelper
    # フォームに有効な情報を入力し、サブミット。-> root_pathに遷移しアカウント有効化のメールが送られたことを知らせる。
    scenario "new user receives acctivation email when submitting its information" do

      visit root_url
      click_link "Sign up now!"

      perform_enqueued_jobs do
        fill_in "Name", with: user.name
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        fill_in "Confirmation", with: user.password
        click_button "Create my account"
        
        expect(page).to have_content "Please check your email to activate your account."
        expect(page).to have_current_path root_url
      end

      mail = ActionMailer::Base.deliveries.last

      aggregate_failures do
        expect(mail.to).to eq [user.email]
        expect(mail.from).to eq ["user@realdomain.com"]
        expect(mail.subject).to eq "Account activation"
        expect(mail.body.encoded).to match(/Sample App/)
        expect(mail.body.encoded).to match(/Hi #{user.name}/)
        expect(mail.body.encoded).to have_selector "a", text: "Activate"
      end
    end

    # フォームに入力したメールアドレスが既に登録されたものだった場合
    scenario "new user signs in with email which has already been taken" do
      user = FactoryBot.create(:user)

      visit root_url
      click_link "Sign up now!"
      fill_in "Name", with: "New User"
      fill_in "Email", with: user.email
      fill_in "Password", with: "foobar"
      fill_in "Confirmation", with: "foobar"
      click_button "Create my account"
        
      expect(page).to have_content "The form contains 1 error."
      expect(page).to have_content "Email has already been taken"
    end

     # フォームに何の値も入力されず、submitされた場合
    scenario "new user signs in with no data" do
      visit root_url
      click_link "Sign up now!"
      fill_in "Name", with: ""
      fill_in "Email", with: ""
      fill_in "Password", with: ""
      fill_in "Confirmation", with: ""
      click_button "Create my account"
        
      expect(page).to have_content "The form contains 4 errors."
    end
  end

  # アカウント有効化時のシミュレーション
  describe "testing the behavior when the user click the link on activation email" do
    include ActiveJob::TestHelper
    # 有効化メールを受け取ったユーザーがアカウント有効化せずにログインしようとした場合
    scenario "new user tried to log in before account activation" do 
      visit root_url
      click_link "Sign up now!"

      # サインアップのためにフォーム入力
      perform_enqueued_jobs do
        fill_in "Name", with: "New User"
        fill_in "Email", with: "new_user@example.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
        click_button "Create my account"
      end

      # ちゃんとメールが送られているかどうかを確認
      mail = ActionMailer::Base.deliveries.last
      expect(mail).to be_truthy

      # メールを確認せずログインを実行しようとするとルートURLに遷移し、メッセージが表示されることを確認
      visit login_path
      fill_in "Email", with: "new_user@example.com"
      fill_in "Password", with: "foobar"
      click_button "Log in"
      expect(page).to have_current_path root_url
      expect(page).to have_content "Account not activated."
    end

    # 有効化メールを受け取ったユーザーがURLをクリックするとアカウントが有効化され、ログインできた状態で、自身のプロフィールページへ遷移している
    scenario "user is redirected to own profile page with logged in and activated when it click URL" do 
      visit edit_account_activation_path(created_user.activation_token, email: created_user.email)
      expect(page).to have_current_path user_path(created_user)
      expect(page).to have_content created_user.name
    end
    # 有効化リンク自体のテスト -> リクエストスペックで書いた
  end
end
