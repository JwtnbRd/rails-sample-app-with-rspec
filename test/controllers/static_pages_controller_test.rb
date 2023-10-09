require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = "Ruby on Rails Tutorial Sample App" 
  end

  #done 
  test "should get root" do
    get root_url
    assert_response :success
  end

  #done 
  ###ただし、ページタイトルのテストは未実施###
  test "should get home" do
    get home_url
    assert_response :success
    assert_select "title", "#{@base_title}"
  end

  #done 
  ###ただし、ページタイトルのテストは未実施###
  test "should get help" do
    get help_url
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  #done 
  ###ただし、ページタイトルのテストは未実施###
  test "should get about" do
    get about_url
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

  #done 
  ###ただし、ページタイトルのテストは未実施###
  test "should get conatct" do
    get contact_url
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end

  test "should get signup" do
    get signup_url
    assert_response :success
    assert_select "title", "Sign up | #{@base_title}"
  end
end
