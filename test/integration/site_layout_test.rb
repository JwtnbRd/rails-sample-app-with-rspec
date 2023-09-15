require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "layout links without log in" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", login_path
    get contact_path
    assert_template 'static_pages/contact'
    assert_select "title", full_title("Contact")
    get signup_path
    assert_template 'users/new'
    assert_select "title", full_title("Sign up")
    get login_path
    assert_template 'sessions/new'
    assert_select "title", full_title("Log in")
  end

  test "layout links with log in" do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end

  test "sing up view layout links" do
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
  end 
end
