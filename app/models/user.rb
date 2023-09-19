class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  # before_save { self.email = email.downcase }
  # before_save { email.downcase! } #こちらでも可
  before_save :downcase_email # ブロックを直接渡すよりもメソッドコールバックの方が良い。
  before_create :create_activation_digest
  
  validates :name, presence: true, length: { maximum: 50 }
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    # これはuniquenessがtrueである上で、case_sensitive:をfalse（大文字小文字の区別をしない）としている
                    # uniqueness: { case_sensitive: false }

                    # before_saveでアドレスを全て小文字に変換する手順を加えたので、case_sensitive:を判断する必要は無くなった。
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  # User....となるのはクラスメソッドの命名規則？
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを得る
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをDBに保存する（ハッシュ化の手続きも踏む）
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したら true を返す
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end
  # ↑のメソッドを改良。記憶トークンに対しても、有効化トークンに対しても使用可能に。
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    # self.update_attribute(:activated, true)
    # self.update_attribute(:activated_at, Time.zone.now)
    self.update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end  

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    self.update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private 
    def downcase_email
      email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
