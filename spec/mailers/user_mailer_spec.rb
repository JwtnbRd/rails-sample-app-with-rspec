require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }

  describe "account_activation" do 
    let(:mail) { UserMailer.account_activation(user) }

    it "sends an email for account activation to user's email properly" do 
      expect(mail.to).to eq [user.email]
    end

    it "sends from the support email address" do
      expect(mail.from).to eq ["user@realdomain.com"] 
    end

    it "sends with the correnct subject" do 
      expect(mail.subject).to eq "Account activation"
    end

    it "contains user activatoin token in its body" do 
      expect(mail.body.encoded).to match user.activation_token
    end

    it "contains user email with escaped '@' in its body" do 
      expect(mail.body.encoded).to match CGI.escape(user.email)
    end
  end

  describe "password_reset" do 
    # この一文が必要。
    # password_reset のメールを送るにあたって、activation_tokenとは異なり、
    # user.reset_token はUserモデルのbefore_createではなく、
    # password_resets_controllerのcreateアクション内で生成されるから。
    # これがないと、パスワードリセット用のURLが作れないので、passwordリセットのメール自体が送れなくなってしまう。
    before { user.reset_token = User.new_token }

    let(:mail) { UserMailer.password_reset(user) }

    it "sends an email for password reset to user's email properly" do 
      expect(mail.to).to eq [user.email]
    end

    it "sends from the support email address" do
      expect(mail.from).to eq ["user@realdomain.com"] 
    end

    it "sends with the correnct subject" do 
      expect(mail.subject).to eq "Password reset"
    end

    it "contains user reset token in its body" do 
      expect(mail.body.encoded).to match user.reset_token
    end

    it "contains user email with escaped '@' in its body" do 
      expect(mail.body.encoded).to match CGI.escape(user.email)
    end
  end
end
