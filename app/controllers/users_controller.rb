class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] 
  before_action :correct_user, only: [:edit, :update] 
  before_action :admin_user, only: :destroy

  def index 
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id]) 
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated
  end 
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # ここでは、ユーザーインスタンスは作るけど、ログインまではさせないので、以下全て削除
      # reset_session
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to user_path(@user)

      #　アカウント有効化メールを送るコードを実装する
        @user.send_activation_email
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit 
    @user = User.find(params[:id])
  end

  def update 
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to user_path(@user)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
      User.find(params[:id]).destroy
      flash[:success] = "User deleted"
      redirect_to users_path, status: :see_other
  end 

  private 

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user) 
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
