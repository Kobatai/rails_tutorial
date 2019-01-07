class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  #⬇︎更新と新規に登録するときに反応する
  before_save   :downcase_email
  #⬇️更新するときは反応しない、新規に登録するときのみ！
  before_create :create_activation_digest
  
  # def remember=(token)
  #   @remember=token
  # end
  
  # def remember
  #   @remember
  # end
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, 
  length: { minimum: 6 }, allow_nil: true
  
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  
  def remember
    self.remember_token = User.new_token
    self.update_attribute(:remember_digest,
      User.digest(remember_token))
  end
  
  def forget
    self.update_attribute(:remember_digest,nil)
  end
  #渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute,token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
   # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  private 
    def downcase_email
      self.email = self.email.downcase
    end
    
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
      #User.activation_digest => 平文（activation＿token）をハッシュ化させたのを入れる
    end
end