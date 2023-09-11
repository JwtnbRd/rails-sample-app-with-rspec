class User < ApplicationRecord
  # before_save { self.email = email.downcase }
  before_save { email.downcase! } #こちらでも可
  
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
  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    
    BCrypt::Password.create(string, cost: cost)
  end
end
