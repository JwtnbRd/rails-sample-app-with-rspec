require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "layout links" do
    get signup_path
    assert_template 'users/new'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", login_path
    assert_select "form[action=?]", users_path

    label_titles = ["Name", "Email", "Password", "Confirmation"]
    label_titles.each do |title|
      assert_select "label", title
    end 
    
    # --- Send POST request ---- #
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select "div#error_explanation"
    assert_select "div.alert" 
    assert_select "div.alert-danger"
    assert_select "ul"
    assert_select "li"
    assert_select "div.field_with_errors"
  end

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
    # ↓より↑の方が、better。テキストに対するテストはちょっとしたことで壊れやすく、文章の量が少ないflashでも同様であるから。
    #　そのため、flashが空でないかどうかだけをテストする方が良い。
    # assert_select "div.alert", "Welcome to the Sample App!"
  end
end
