module LoginSupport 
  def log_in_as(user) 
    get edit_account_activation_path(user.activation_token, email: user.email)

    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end

  def log_in_with_remember_me(user) 
    get edit_account_activation_path(user.activation_token, email: user.email)

    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    check "Remember me on this computer"
    click_button "Log in"
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end