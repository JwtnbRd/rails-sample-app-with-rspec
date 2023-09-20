require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

# Userモデルのname属性の文字数が51文字の場合、そのインスタンスは有効でないということを期待。
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

# Userモデルのemail属性の@以下を含めた文字数が256文字になった場合、そのインスタンスは有効でないということを期待。
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

# メールアドレスのバリデーションテスト。有効なフォーマットを期待する。
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      # assertに第二引数を指定することで、どのメールアドレスが失敗したのかを特定できるメッセージを返すようにする。
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

# メールアドレスのバリデーションテスト。無効なフォーマットを期待する。
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[foo@bar..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

# 属性の一意性のバリデーションのテスト。メモリ上だけでなく、DBに実際にインスタンスを保存した上で、他のデータと比較する必要がある。
  test "email addresses should be unique" do
    # dupは同じ属性を持つデータを複製するためのメソッド。setupで用意したインスタンスを複製している
    duplicate_user = @user.dup
    # レプリカのメールアドレスをオリジナルのメールアドレスの文字列を全て大文字にしたものに変換する
    # なぜなら、文字の並びは同じであっても、大文字、小文字が異なると違うメールアドレスと認識されてしまうから。
    # 実際には大文字、小文字の違いも含めて検証したい。
    # duplicate_user.email = @user.email.upcase
    # ↑ User モデルにbefore_saveが追加されたので、この手順は不要
    # 先にオリジナルをDBに保存
    @user.save
    # 次にレプリカのインスタンスが有効かどうかをテスト。falseであることを期待
    assert_not duplicate_user.valid?
  end

# Userモデルに追加したメールアドレスを小文字に変換して保存するbefore_saveコールバックがうまく動作するかのテスト
  test "email addresses should be saved as lowercase" do 
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do 
    @user.save 
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end
