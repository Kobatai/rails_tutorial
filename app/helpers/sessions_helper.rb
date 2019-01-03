module SessionsHelper
  #渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  #ユーザを永続的に復元できるようにする（セッションに記憶する）
  def remember(user)
    user.remember # => DB: remember_digest
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
   # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end
  
  def current_user
    user_id = session[:user_id]
    if user_id #nil以外なら突破
      @current_user ||= User.find_by(id:user_id)
      
    elsif (user_id = cookies.signed[:user_id]) 
    # raise # テストがパスすれば、この部分がテストされていないことがわかる
    #signedで暗号化したuser_idをsignedで復号したuser_idを引っ張ってこれる
    #cookiesにuser_idが入っていたら↓の処理 
      user = User.find_by(id:user_id)
      #cookiesにuser_idが入ってなかったら（nilの場合）↓の処理 
        #平文のremember_tokenとremember_digestをチェック
      if user && user.authenticated?(cookies[:remember_token])
       
        log_in user
        #メモ化している
        @current_user = user
      end
    end
    #全て失敗したらnilが返ってくる
    # @current_user ||= User.find_by(id: session[:user_id])
    # a += 1
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
   # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
