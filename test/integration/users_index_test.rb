require "test_helper"

class UsersIndex < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @user = users(:malory)
    @other_user = users(:archer)
  end
end

class UserIndexAdmin < UsersIndex

  def setup 
    super
    log_in_as(@admin)
    get users_path
  end
end

class UsersIndexAdminTest < UserIndexAdmin
  test "should render index page" do
    assert_template 'users/index'
  end

  test "should paginate users" do
    assert_select 'div.pagination'
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      # ここでunlessを使って、admin出ない場合は…
      # としている理由は、ビューの方で、adminユーザーの横にはdeleteボタンは表示しないようにしているから
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
  end

  test "should be able to delete non-admin user" do
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test "should display only activated users" do
    # ページにいる最初のユーザーを無効化する。
    # 無効なユーザーを作成するだけでは、
    # Rails で最初のページに表示される保証がないので不十分
    User.paginate(page: 1).first.toggle!(:activated)
    # /users を再度取得して、無効化済みのユーザーが表示されていないことを確かめる
    get users_path
    # 表示されているすべてのユーザーが有効化済みであることを確かめる
    assigns(:users).each do |user|
      assert user.activated
    end
  end
end

class UserNonAdminIndexTest < UsersIndex

  test "should not have delete links as non-admin" do
    log_in_as(@other_user)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end