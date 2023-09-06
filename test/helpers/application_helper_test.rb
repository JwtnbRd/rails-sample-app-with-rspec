require "test_helper"

class ApplicationHelperTest < ActionView::TestCase

  def setup
    @base_title = "Ruby on Rails Tutorial Sample App" 
  end

  test "full title helper" do
    assert_equal "#{@base_title}", full_title
    assert_equal "Help | #{@base_title}", full_title("Help")
    assert_equal "About | #{@base_title}", full_title("About")
    assert_equal "Contact | #{@base_title}", full_title("Contact")
    assert_equal "Sign up | #{@base_title}", full_title("Sign up")
  end
end