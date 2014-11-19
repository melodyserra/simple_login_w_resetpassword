class AccessController < ApplicationController
  before_action :confirm_logged_in, only: [:home]
  before_action :prevent_login_signup, only: [:signup, :login]

  def signup
    @user = User.new
  end

   def create
    @user = User.create(user_params)
    if @user.save
      UserMailer.signup_confirmation(@user).deliver
      session[:user_id] = @user.id
      flash[:success] = "You are now logged in!"
      redirect_to home_path
    else
      render :signup
    end
   end

  def login
  end

  def attempt_login

    if params[:username].present? && params[:password].present?
      found_user = User.where(username: params[:username]).first
      if found_user
        authorized_user = found_user.authenticate(params[:password])
      end
    end

    if !found_user
      flash.now[:alert] = "Invalid username"
      render :login

    elsif !authorized_user
      flash.now[:alert] = "Invalid password"
      render :login

    else
      session[:user_id] = authorized_user.id
      flash[:success] = "You are now logged in."
      redirect_to home_path
    end

  end

  def home
  end


  def password_reset

    if params[:username].present?
      user = User.where(username: params[:username]).first
      user.update(:reset_token => Random.rand(100))
      UserMailer.password_reset(user).deliver
      redirect_to login_path
    end
  end

  def reset
    puts "Reset Action"
    if User.find_by_reset_token(params[:user_reset_token]).present?
      @user = User.find_by_reset_token(params[:user_reset_token])
    else
      redirect_to login_path
    end
  end


  def reset_password
    @user = User.find_by_reset_token(params[:user_reset_token])
    @user.update_attributes(user_params)
    @user.update_attributes(:reset_token => nil)
    if(@user.save)
      session[:user_id] = @user.id
      flash[:success] = "You're profile is updated"
      redirect_to root_path
    else
      render :reset
    end
  end

  def edit
    @user = User.find_by_id(session[:user_id])
  end

  def update
    pw_params=params.require(:user).permit(:password, :password_confirmation)
    @user = User.find_by_id(session[:user_id])
    @user.update_attributes(pw_params)
    @user.save
      flash[:success] = "You're profile is updated"
      redirect_to home_path
  end



  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to login_path
  end

  private
  def user_params
    params.require(:user).permit(:username, :password, :password_digest)
  end

  def confirm_logged_in
    unless session[:user_id]
      redirect_to login_path, alert: "Please log in"
    end
  end

  def prevent_login_signup
    if session[:user_id]
      redirect_to home_path
    end
  end
end

