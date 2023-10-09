require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @base_title = "Ruby on Rails Tutorial Sample App" 
    @user = users(:michael)
    @other_user = users(:archer)
  end
  # done (only request and response) 
  test "should get new" do
    get signup_path
    assert_response :success
    assert_select "title", "Sign up | #{@base_title}"
  end

  test "should get edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_response :success
    assert_select "title", "Edit user | #{@base_title}"
  end

  # done (only request and response) 
  # ログインせずにeditアクションを実行しようとする
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  # done (only request and response) 
  # ログインせずにupdateアクションを実行しようとする
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name, 
                                              email: @user.email }}
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  # ログイン済みの別のuserからeditアクションを実行しようとする
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  # ログイン済みの別のuserからupdateアクションを実行しようとする
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # done (only request and response) 
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  # admin 属性が編集可能な属性でないことをテストする
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { password: "password",
                                                    password_confirmation: "password",
                                                    admin: true } }
    assert_not @other_user.reload.admin?
  end

  # done (only request and response) 
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end


  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end
  
  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
