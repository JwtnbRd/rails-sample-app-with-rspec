require 'rails_helper'

RSpec.describe User, type: :model do 
  let(:user) { FactoryBot.create(:user) }

  # Userモデルのバリデーションテストを行う
  describe "test validations on User model" do
    # --- バリデーションが通るパターン --- #
    context "when the user instance is valid" do
      # Userモデルのそれぞれの属性に有効な値が与えられた場合
      it "is valid with name, email, password and password_confirmation" do
        expect(user).to be_valid
      end
      # 有効な形式のメールアドレスが渡された場合
      it "is valid with proper style emails" do
        valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn] 

        valid_addresses.each do |valid_address|
          user.email = valid_address
          expect(user).to be_valid
        end
      end
    end

    # --- バリデーションが通らないパターン --- #
    context "when the user instance is invalid" do
      # 重複したuser情報で登録されようとした場合(user情報の一意性をテスト）
      it "is invalid with a duplicated user information" do
        duplicate_user = user.dup
        expect(duplicate_user).to_not be_valid
      end
      # --- name属性のバリデーションが引っかかるパターン --- #
      context "when the validation on user's name attribute works" do
        # name属性がない場合
        it "is invalid without name" do 
          user.name = nil
          user.valid?
          expect(user.errors[:name]).to include("can't be blank")
        end
        # name属性の値が５０文字以上の場合
        it "is invalid because of name with over 50 characters" do
          user.name = "a" * 51
          user.valid?
          expect(user.errors[:name]).to_not include("name is too long")
        end
      end
      # --- email属性のバリデーションが引っかかるパターン --- #
      context "when the validation on user's email attribute works" do
        # メールアドレス属性がない場合
        it "is invalid without email" do
          user.email = nil
          user.valid?
          expect(user.errors[:email]).to include("can't be blank")
        end
        # 無効な形式のメールアドレスが渡された場合
        it "is invalid with improper email" do
          invalid_addresses = %w[foo@bar..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
          invalid_addresses.each do |invalid_address|
            user.email = invalid_address
            expect(user).to_not be_valid
          end
        end
        # 255文字以上のメールアドレスが渡された場合
        it "is invalid because of email with over 255 characters" do
          user.email = "a" * 244 + "@example.com"
          user.valid?
          expect(user.errors[:email]).to_not include("email is too long")
        end
        # 重複したメールアドレスが渡された場合
        it "is invalid with duplicated email" do
          user.update(email: "user@example.com")
          other_user = User.new(
                        name: "Other User",
                        email: "user@example.com",
                        password: "foobar",
                        password_confirmation: "foobar",
                      )
          other_user.valid?
          expect(other_user.errors[:email]).to include("has already been taken")
        end
      end
      # --- password属性のバリデーションが引っかかるパターン　--- #
      context "when the validation on user's password attribute works" do
        # password属性がない場合
        it "accept only present password" do 
          user.password = user.password_confirmation = " " * 6
          expect(user).to_not be_valid
        end
        # passwordが５文字以下の場合      
        it "accept only password with over 5 digits" do 
          user.password = user.password_confirmation = "a" * 5
          expect(user).to_not be_valid
        end
      end
    end
  end

  # Userクラスのクラスメソッドを検証する
  describe "test class methods" do
    # User.digest(string)のテスト
    context "User.digest(string)..." do
      # このメソッドは何かしらの値を引数にとる。データ型は問わないが、一応stringを期待している
      # => 引数なしでこのメソッドが呼ばれた時にはArgumentErrorクラスの例外を発生させる。
      it "expects an argument" do 
        expect {
          User.digest
        }.to raise_error(ArgumentError)
      end
      # このメソッドの戻り値は常に60ケタの文字列である。
      it "always returns a random string with 60 characters" do
        expect(User.digest("aaa").length).to eq 60 
      end
      # 呼ばれるたびに異なるユニークな文字列の組み合わせを返す。
      it "always returns a random and unique string" do
        first_commit = User.digest("aaa")
        expect(User.digest("aaa")).to_not eq first_commit
      end
    end
    # User.new_tokenのテスト
    context "User.new_token" do
      # このメソッドの戻り値は常に22ケタの文字列である。
      it "always returns a random string with 22 characters" do
        expect(User.new_token.length).to eq 22
      end
      # 呼ばれるたびに異なるユニークな文字列の組み合わせを返す。
      it "always returns a random and unique string" do
        first_commit = User.new_token
        expect(User.new_token).to_not eq first_commit
      end
    end
  end

  # # Userクラスのインスタンスメソッドとprivateメソッドのコールバックを検証する
  describe "test instance methods and callbacks" do
    # downcase_email callbackがbefore_saveでちゃんと呼ばれるかどうかのテスト
    context "downcase_email callback" do 
      it "saves email with lowercase when user is newly created" do
        mixed_case_email = "USeR@ExAMPle.CoM"
        user_with_mixed_case_email = User.create(
          name: "Test User",
          email: mixed_case_email,
          password: "foobar",
          password_confirmation: "foobar",
        )
        expect(mixed_case_email.downcase).to eq user_with_mixed_case_email.reload.email
      end

      it "saves email with lowercase when user's email is updated" do
        mixed_case_email = "USeR@ExAMPle.CoM"
        user.update(email: mixed_case_email)
        expect(mixed_case_email.downcase).to eq user.reload.email
      end
    end

    # create_activarion_digestがbefore_createで呼び出されているかどうかのテスト
    context "user instance has its own activation_token and digest just after created" do
      it "has activation_token attribute" do
        expect(user.activation_token.length).to eq 22
      end

      it "has activation_diges attribute" do
        expect(user.activation_digest.length).to eq 60
      end
    end

    # rememberメソッドのテスト
    context "when remember method is called" do
      it "returns nil with remember_token attribute just after created" do
        expect(user.remember_token).to eq nil
      end
      it "applys 22 characters string to remember_token attribute after the method called" do
        user.remember
        expect(user.reload.remember_token.length).to eq 22        
      end
      it "updates user's remember_digest attribute after the method called" do
        user.remember
        expect(user.reload.remember_digest.length).to eq 60
      end
      it "returns user's remember_digest" do
        expect(user.remember).to eq user.reload.remember_digest
      end 
    end

    # session_token メソッドのテスト
    context "when session_token method is called" do 
      it "returns remember_token which is newly generated" do
        expect(user.session_token.length).to eq 60 
      end
    end

    # authenticated? メソッドのテスト
    context "when auhtenticated? method is called" do 
      it "returns false to a user with nil remember_digest" do 
        expect(user.authenticated?(:remember, '')).to eq false
      end

      it "returns false to a user with nil activation_digest" do 
        expect(user.authenticated?(:activation, '')).to eq false
      end
    end

    # forget メソッド
    context "forget method" do
      it "update remember_digest attribute with nil when it's called" do
          user.forget
          expect(user.remember_digest).to eq nil
      end      
    end

    # activate メソッド
    context "activate" do
      it "turns activated attribute to true" do
        user.activate
        expect(user.activated).to eq true
      end

      it "also marks activated_at attribute with timestamp" do
        user.activate
        expect(user.activated_at.class).to eq ActiveSupport::TimeWithZone 
      end
    end

    # followメソッド　unfollowメソッド
    context "follow method and unfollow method" do
      before do
        @other_user = FactoryBot.create(:user) 
      end

      it "can follow other user" do
        expect {
          user.follow(@other_user)
        }.to change{ user.following.size }.by(1)
      end

      it "can unfollow other user" do
        user.follow(@other_user)
        expect {
          user.unfollow(@other_user)
        }.to change{ user.following.size }.by(-1)
      end

      it "returns true if user follows other user" do
        user.follow(@other_user)
        expect(user.following?(@other_user)).to be true
      end
    end

    # feed メソッド
    context "user has its own customized feed" do 
      before do
        @user_with_posts = FactoryBot.create(:user, :with_microposts)
        @other_user_with_posts = FactoryBot.create(:user, :with_microposts)
        @other_user2_with_posts = FactoryBot.create(:user, :with_microposts)
      end

      # followしているユーザーのマイクロポストがuserのfeedに表示される
      it "contains following user's microposts" do
        @user_with_posts.follow(@other_user_with_posts) 
        @other_user_with_posts.microposts.each do |post_following|
          expect(@user_with_posts.feed).to include(post_following)
        end
      end 
      # 自分自身のマイクロポストもuserのfeedに表示される
      it "contains user's own microposts" do 
        @user_with_posts.microposts.each do |post_self|
          expect(@user_with_posts.feed).to include(post_self)
        end
      end
      # followしていないユーザーのマイクロポストはuserのfeedには表示されない
      it "doesn't contain not following user's microposts" do 
        @other_user2_with_posts.microposts.each do |post_unfollowed|
          expect(@user_with_posts.feed).to_not include(post_unfollowed)
        end
      end
    end
  end


  # ---------書き換え前------------ #

  # before do 
  #   @user = FactoryBot.create(:user)
  #   @other_user = FactoryBot.create(:user)

  #   @user_with_posts = FactoryBot.create(:user, :with_microposts)
  #   @other_user_with_posts = FactoryBot.create(:user, :with_microposts)
  #   @other_user2_with_posts = FactoryBot.create(:user, :with_microposts)
  # end

  # # 姓、名、メール、パスワードがあれば有効な状態であること
  # # it "is valid with name, email, password and password_confirmation" do 
  # #   expect(@user).to be_valid
  # # end

  # # 名がなければ無効な状態であること
  # # it "is invalid without name" do 
  # #   @user.name = " "
  # #   @user.valid?
  # #   expect(@user.errors[:name]).to include("can't be blank")
  # # end

  # # メールアドレスがなければ無効な状態であること
  # # it "is invalid without an email address" do
  # #   @user.email = nil
  # #   @user.valid?
  # #   expect(@user.errors[:email]).to include("can't be blank")
  # # end

  # # 重複したメールアドレスなら無効な状態であること
  # # it "is invalid with a duplicate email address" do
  # #   @user.update(email: "user@example.com")
  # #   other_user = FactoryBot.build(:user, email: "user@example.com")
  # #   other_user.valid?
  # #   expect(other_user.errors[:email]).to include("has already been taken")
  # # end

  # # it "is invalid with too long name" do
  # #   @user.name = "a" * 51
  # #   @user.valid?
  # #   expect(@user.errors[:name]).to_not include("name is too long")
  # # end

  # # it "is invalid with too long email" do
  # #   @user.email = "a" * 244 + "@example.com"
  # #   @user.valid?
  # #   expect(@user.errors[:email]).to_not include("email is too long")
  # # end

  # # it "accept valid emails" do
  # #   valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    
  # #   valid_addresses.each do |valid_address|
  # #     @user.email = valid_address
  # #     expect(@user).to be_valid
  # #   end
  # # end

  # it "reject invalid emails" do
  #   invalid_addresses = %w[foo@bar..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
  #   invalid_addresses.each do |invalid_address|
  #     @user.email = invalid_address
  #     expect(@user).to_not be_valid
  #   end
  # end

  # # it "is invalid with a duplicate user" do
  # #   duplicate_user = @user.dup
  # #   expect(duplicate_user).to_not be_valid
  # # end

  # it "saves email with lowercase" do
  #   @user.update(email: "user@example.com")
  #   mixed_case_email = "USeR@ExAMPle.CoM"
  #   @user.email = mixed_case_email
  #   expect(mixed_case_email.downcase).to eq @user.reload.email
  # end

  # it "accept only present password" do 
  #   @user.password = @user.password_confirmation = " " * 6
  #   expect(@user).to_not be_valid
  # end

  # it "accept only password with over 5 digits" do 
  #   @user.password = @user.password_confirmation = "a" * 5
  #   expect(@user).to_not be_valid
  # end

  # it "test authenticated? method for a user with nil digest" do
  #   expect(@user.authenticated?(:remember, '')).to eq false
  # end

  # it "allows associated micropost be destroyed" do 
  #   init_count = Micropost.count 
  #   @user.microposts.create!(content: "Lorem ipsum")
  #   @user.destroy
  #   destroyed_count = Micropost.count
  #   expect(destroyed_count).to eq (init_count)
  # end

  # it "follows and unfollows other users" do
  #   expect(@user.following?(@other_user)).to eq false
  #   @user.follow(@other_user)
  #   expect(@user.following?(@other_user)).to eq true
  #   expect(@other_user.followers).to include(@user)
  #   @user.unfollow(@other_user)
  #   expect(@user.following?(@other_user)).to eq false
  #   @user.follow(@user)
  #   expect(@user.following?(@user)).to eq false
  # end
 
  # # FactoryBotのuser.rbで指定したtraitが問題なく動くか確認する
  # it "can have many microposts" do 
  #   user = FactoryBot.create(:user, :with_microposts)
  #   expect(user.microposts.length).to eq 10
  # end

  # it "has its own customized feed" do 
  #   @user_with_posts.follow(@other_user_with_posts) 
  #   @user_with_posts.unfollow(@other_user2_with_posts)
  #   @other_user_with_posts.microposts.each do |post_following|
  #     expect(@user_with_posts.feed).to include(post_following)
  #   end
  #   @user_with_posts.microposts.each do |post_self|
  #     expect(@user_with_posts.feed).to include(post_self)
  #   end
  #   @other_user2_with_posts.microposts.each do |post_unfollowed|
  #     expect(@user_with_posts.feed).to_not include(post_unfollowed)
  #   end
  # end
end
