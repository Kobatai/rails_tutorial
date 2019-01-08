class UserMailer < ApplicationMailer

 #account_activationメソッド（呼び出し元が戻り値を受け取る）
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
    #return mail object
    #=> app/views/user_mailer/account_activation.text.erb
    #=> app/views/user_mailer/account_activation.html.erb
    
    #送りつけたいurl https://hogehoge.com/account_activations/:id/edit
    #:id <= @user.activation_token
  end

  def password_reset(user)
    @user = user

    mail to: user.email,subject:"Password reset"
  end
end
