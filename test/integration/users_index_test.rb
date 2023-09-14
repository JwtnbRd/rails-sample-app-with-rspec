require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @user = users(:malory)
    @other_user = users(:archer)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "should have two will_paginate link" do 
    log_in_as(@user)
    get users_path
    assert_select 'div.pagination', count: 2
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      # ここでunlessを使って、admin出ない場合は…
      # としている理由は、ビューの方で、adminユーザーの横にはdeleteボタンは表示しないようにしているから
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  test "index as non-admin" do
    log_in_as(@other_user)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
