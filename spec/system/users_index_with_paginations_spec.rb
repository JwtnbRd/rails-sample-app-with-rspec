require 'rails_helper'

RSpec.describe "UsersIndexWithPaginations", type: :system do
  # support/capybara.rbに切り出したので不要
  # before do
  #   driven_by(:rack_test)
  # end

  let(:user) { FactoryBot.create(:user) }
  let(:other_user_with_activated) { FactoryBot.create(:user, :activated) }
  let(:other_user_without_activated) { FactoryBot.create(:user) }
  let(:user_admin) { FactoryBot.create(:user, :admin) }

  describe "testing users#index view" do
    context "displays all of users with pagination" do
      before do 
        @other_users = []
        49.times do 
          @other_users << FactoryBot.create(:user, :activated)
        end
      end

      scenario "there are 30 users in first page and two paginate links" do
        log_in_as user
        visit users_path
        expect(page).to have_content "All users"
        expect(page).to_not have_link "delete"
        within ".users" do
          expect(page.all('li').count).to eq 30
          expect(page).to_not have_selector 'a[data-turbo-method="delete"]'
        end
        expect(page.all('ul.pagination').count).to eq 2
      end

      scenario "unactivated user shouldn't appear in users#index" do 
        @other_users << other_user_without_activated
        log_in_as user 
        visit users_path
        first("ul.pagination").click_link "Next →"

        # 自身を含めてactivated_userは50個ある。
        # @other_users配列にunactivated_userを追加
        # それでもusers#indexの2ページ目には21個ではなく20個のユーザーインスタンスが存在するべき
        within ".users" do
          expect(page.all('li').count).to_not eq 21
          expect(page.all('li').count).to eq 20
        end
      end
    end

    context "delete button should appear in admin_user's view" do
      before do 
        @other_users = []
        49.times do 
          @other_users << FactoryBot.create(:user, :activated)
        end
      end

      scenario "admin user access users#index" do
        @num_of_delete_links = 0
        log_in_as user_admin
        visit users_path
        expect(page).to have_content "All users"
        expect(page).to have_link "delete"
        within ".users" do 
          expect(page).to have_selector 'a[data-turbo-method="delete"]'
          @num_of_delete_links += page.all('a[data-turbo-method="delete"]').count
        end

        first("ul.pagination").click_link "Next →"
        within ".users" do 
          expect(page).to have_selector 'a[data-turbo-method="delete"]'
          @num_of_delete_links += page.all('a[data-turbo-method="delete"]').count
        end

        expect(@num_of_delete_links).to eq 49

        expect {
          first("ul.users > li").click_link "delete"
        }.to change(User, :count).by(-1)
      end
    end
  end
end


