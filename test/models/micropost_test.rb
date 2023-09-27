require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
  end

  #done
  test "should be valid" do
    assert @micropost.valid?
  end

  #done
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  #done
  test "content should be present" do
    @micropost.content = "  "
    assert_not @micropost.valid?
  end

  #done
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  #done
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end 
