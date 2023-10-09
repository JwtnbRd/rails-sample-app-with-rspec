module ControllerSpecHelper
  def log_in_as(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  def is_logged_in?(user)
    !session[:user_id].nil?
  end
end