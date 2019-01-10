class PasswordResetsController < ApplicationController
  before_action:get_user  ,only:[:edit, :update]
  before_action:valid_user,only:[:edit, :update]
  before_action:check_expiration,only:[:edit,:update]
  def new
  end

  def create
    @user = User.find_by(email:params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    elsera
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end  
  
  #GET /password_resets/:id/edit?email=foo@bar.com
  def edit
    # @user = User.find_by(email:params[:email])
    # パスワードを入力してもらうフォームを描画
  end
  
  #PATCH /password_resets/:id?email=foo@bar.com
  def update
    # パスワードを再設定する
    # @user.password_digest = User.digest(params[:password])
    # if @user.save
    # else
  
    # @user = User.find_by(email:params[:email])
    # params[:id] == self.reset_token
    # params[:email] == @user.email 
    if params[:user][:password].empty?                  # (3) への対応
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)          # (4) への対応
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     # (2) への対応
    end
  end
   
  private
    
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    #editとupdateでやってる同じ処理をbeforeアクションで抽象化する＝リファクタリング
    def get_user
      @user = User.find_by(email:params[:email])
    end
    
    #有効なユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
      # 1:@userがnilじゃない、2:有効化がされていること,
      # 3:リセットダイジェストとリセットトークンが一致しない
      #いずれかがtrueだったら本人じゃない
      
        redirect_to root_url
      end
    end
    
    #トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
