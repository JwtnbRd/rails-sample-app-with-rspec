require 'rails_helper'

RSpec.describe User, type: :model do
  before do 
    @user = FactoryBot.create(:user)
    @other_user = FactoryBot.create(:user)

    @user_with_posts = FactoryBot.create(:user, :with_microposts)
    @other_user_with_posts = FactoryBot.create(:user, :with_microposts)
    @other_user2_with_posts = FactoryBot.create(:user, :with_microposts)
  end

  # 姓、名、メール、パスワードがあれば有効な状態であること
  it "is valid with name, email, password and password_confirmation" do 
    expect(@user).to be_valid
  end

  # 名がなければ無効な状態であること
  it "is invalid without name" do 
    @user.name = " "
    @user.valid?
    expect(@user.errors[:name]).to include("can't be blank")
  end

  # メールアドレスがなければ無効な状態であること
  it "is invalid without an email address" do
    @user.email = nil
    @user.valid?
    expect(@user.errors[:email]).to include("can't be blank")
  end

  # 重複したメールアドレスなら無効な状態であること
  it "is invalid with a duplicate email address" do
    @user.update(email: "user@example.com")
    other_user = FactoryBot.build(:user, email: "user@example.com")
    other_user.valid?
    expect(other_user.errors[:email]).to include("has already been taken")
  end

  it "is invalid with too long name" do
    @user.name = "a" * 51
    @user.valid?
    expect(@user.errors[:name]).to_not include("name is too long")
  end

  it "is invalid with too long email" do
    @user.email = "a" * 244 + "@example.com"
    @user.valid?
    expect(@user.errors[:email]).to_not include("email is too long")
  end


  it "accept valid emails" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      expect(@user).to be_valid
    end
  end

  it "reject invalid emails" do
    invalid_addresses = %w[foo@bar..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      expect(@user).to_not be_valid
    end
  end

  it "is invalid with a duplicate user" do
    duplicate_user = @user.dup
    expect(duplicate_user).to_not be_valid
  end

  it "saves email with lowercase" do
    @user.update(email: "user@example.com")
    mixed_case_email = "USeR@ExAMPle.CoM"
    @user.email = mixed_case_email
    expect(mixed_case_email.downcase).to eq @user.reload.email
  end

  it "accept only present password" do 
    @user.password = @user.password_confirmation = " " * 6
    expect(@user).to_not be_valid
  end

  it "accept only password with over 5 digits" do 
    @user.password = @user.password_confirmation = "a" * 5
    expect(@user).to_not be_valid
  end

  it "test authenticated? method for a user with nil digest" do
    expect(@user.authenticated?(:remember, '')).to eq false
  end

  it "allows associated micropost be destroyed" do 
    init_count = Micropost.count 
    @user.microposts.create!(content: "Lorem ipsum")
    @user.destroy
    destroyed_count = Micropost.count
    expect(destroyed_count).to eq (init_count)
  end

  it "follows and unfollows other users" do
    expect(@user.following?(@other_user)).to eq false
    @user.follow(@other_user)
    expect(@user.following?(@other_user)).to eq true
    expect(@other_user.followers).to include(@user)
    @user.unfollow(@other_user)
    expect(@user.following?(@other_user)).to eq false
    @user.follow(@user)
    expect(@user.following?(@user)).to eq false
  end
 
  # FactoryBotのuser.rbで指定したtraitが問題なく動くか確認する
  it "can have many microposts" do 
    user = FactoryBot.create(:user, :with_microposts)
    expect(user.microposts.length).to eq 10
  end

  it "has its own customized feed" do 
    @user_with_posts.follow(@other_user_with_posts) 
    @user_with_posts.unfollow(@other_user2_with_posts)
    @other_user_with_posts.microposts.each do |post_following|
      expect(@user_with_posts.feed).to include(post_following)
    end
    @user_with_posts.microposts.each do |post_self|
      expect(@user_with_posts.feed).to include(post_self)
    end
    @other_user2_with_posts.microposts.each do |post_unfollowed|
      expect(@user_with_posts.feed).to_not include(post_unfollowed)
    end
  end
end
