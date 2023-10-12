require 'rails_helper'

RSpec.describe "Microposts", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { FactoryBot.create(:user, :with_microposts) }
  let(:user_with_no_microposts) { FactoryBot.create(:user, :activated) }
  let(:user_with_single_micropost) { FactoryBot.create(:user, :with_single_micropost) }

  describe "testing microposts ui" do 
    context "when user has some microposts" do 
      before do
        @other_user = FactoryBot.create(:user, :with_microposts) 
      end 

      it "has pagination links" do
        log_in_as user 
        visit root_path
        expect(page.all('ul.pagination').count).to eq 1
      end

      it "has delete links on own posts" do 
        log_in_as user
        click_link "Profile"
        within "ol.microposts" do
          expect(page.all('li').count).to eq 30
          # expect(page).to have_selector 'a[data-turbo-method="delete"]'
          expect(page).to have_content 'delete'
        end
      end

      it "allows user to delete its own post" do 
        log_in_as user 
        visit user_path(user)
        expect {
          first("ol.microposts li").click_link "delete"
        }.to change(user.microposts, :count).by(-1)
      end

      it "doesn't have delete link on other user's posts" do 
        log_in_as user 
        visit user_path(@other_user)
        expect(page).to_not have_content 'delete'
      end
    end

    context "user submit invalid value in micropost form" do 
      it "doesn't allow user to have new post" do 
        log_in_as user
        visit root_path
        expect {
          fill_in 'micropost_content', with: ""
          click_button "Post"
          expect(page).to have_http_status :unprocessable_entity
        }.to_not change(Micropost, :count)
      end
    end

    context "user submit valid value in micropost form" do
      it "allows user to have new post" do 
        log_in_as user
        visit root_path
        expect {
          fill_in 'micropost_content', with: "Hello World"
          click_button "Post"
          expect(page).to have_content "Micropost created!"
          expect(page).to have_current_path root_path
        }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "microposts side bar test" do 
    context "check the ui in side bar" do 
      it "has right number of the post" do 
        log_in_as user
        visit root_path
        expect(page).to have_content "#{user.microposts.count} microposts"
      end

      it "has proper pluralization for zero microposts" do 
        log_in_as user_with_no_microposts
        visit root_path
        expect(page).to have_content "0 microposts"
      end

      it "has proper pluralization for one microposts" do 
        log_in_as user_with_single_micropost
        visit root_path
        expect(page).to have_content "1 micropost"
      end
    end
  end

  describe "image upload test" do 
    context "checking image upload field" do 
      it "should hace a file input area for images" do 
        log_in_as user
        visit root_path
        expect(page).to have_selector 'input[type="file"]'
      end

      it "allows user to upload a image" do 
        log_in_as user
        visit root_path
        fill_in 'micropost_content', with: "Hello World"
        attach_file "micropost_image", "#{Rails.root}/spec/files/kitten.jpg"
        click_button "Post"
        expect(page).to have_content "Micropost created!"
        expect(page).to have_current_path root_path
        expect(Micropost.first.image.attached?).to be_truthy
      end
    end
  end
end
