class SessionsController < ApplicationController
  include SessionsHelper
  def new
    #POST /login => create action
  end
  
  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      log_in user
      # remember => save to DB + cookies[:token] 
      # remember user #SessionsHelper
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
     redirect_back_or user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'   
    end
  end
  
  #DELETE /logout
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
