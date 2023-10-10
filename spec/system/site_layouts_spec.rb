require 'rails_helper'

RSpec.describe "SiteLayouts", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { FactoryBot.create(:user) }

  describe "testing layout links in home page view" do
    context "without log in" do
      it "has expected links" do
        visit root_path
        expect(page).to have_current_path root_path
        expect(page).to have_link "Home", href: root_path
        expect(page).to have_link "sample app", href: root_path
        expect(page).to have_link "Help", href: help_path
        expect(page).to have_link "Log in", href: login_path
        expect(page).to have_link "About", href: about_path
        expect(page).to have_link "Contact", href: contact_path
        expect(page).to have_link "News", href: "https://news.railstutorial.org/"

        click_link "Contact"
        expect(page).to have_current_path contact_path
        expect(page).to have_selector "title", text: "Contact | Ruby on Rails Tutorial Sample App", visible: false

        visit root_path
        click_link "About"
        expect(page).to have_current_path about_path
        expect(page).to have_selector "title", text: "About | Ruby on Rails Tutorial Sample App", visible: false

        visit root_path
        click_link "Sign up now!"
        expect(page).to have_current_path signup_path
        expect(page).to have_selector "title", text: "Sign up | Ruby on Rails Tutorial Sample App", visible: false
      
        visit root_path
        click_link "Log in"
        expect(page).to have_current_path login_path
        expect(page).to have_selector "title", text: "Log in | Ruby on Rails Tutorial Sample App", visible: false
      end
    end

    context "with log in" do
      it "has expected links" do
        log_in_as(user)
        visit root_path
        expect(page).to have_current_path root_path
        expect(page).to have_link "Home", href: root_path
        expect(page).to have_link "sample app", href: root_path
        expect(page).to have_link "Help", href: help_path
        expect(page).to have_link "Users", href: users_path
        expect(page).to have_link "Profile", href: user_path(user)
        expect(page).to have_link "Settings", href: edit_user_path(user)
        expect(page).to have_link "About", href: about_path
        expect(page).to have_link "Contact", href: contact_path
        expect(page).to have_link "News", href: "https://news.railstutorial.org/"
      end
    end
  end

  describe "testing layout links in sign up page" do
    it "has expected links" do
      visit signup_path
      expect(page).to have_current_path signup_path
      expect(page).to have_link "Home", href: root_path
      expect(page).to have_link "sample app", href: root_path
      expect(page).to have_link "Help", href: help_path
      expect(page).to have_link "Log in", href: login_path
      expect(page).to have_link "About", href: about_path
      expect(page).to have_link "Contact", href: contact_path
      expect(page).to have_link "News", href: "https://news.railstutorial.org/"
      expect(find('form')['action']).to eq users_path
      label_titles = ["Name", "Email", "Password", "Confirmation"]
      label_titles.each do |title|
        expect(page).to have_selector "label", text: title
      end
    end
  end
end
