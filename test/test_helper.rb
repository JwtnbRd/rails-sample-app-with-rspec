ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
end 

# 以下のコードはAcrionDispatchクラス内で定義しなくても使えるのはなぜ？
#　逆にクラス指定する必要はなぜあるのか？同じ名前のメソッドを用意しておけば、
# そのメソッドの使い所がどのクラスを継承しているかに応じて、メソッドを使い分けてくれるから？
class ActionDispatch::IntegrationTest
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password, 
                                          remember_me: remember_me }}
  end
end



