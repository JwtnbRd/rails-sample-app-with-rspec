require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
    before do
      ActionMailer::Base.deliveries.clear
    end

    let(:user) { FactoryBot.create(:user) }
    let(:activated_user) { FactoryBot.create(:user, :activated) }

    describe "new action" do
      it "returns http success" do 
        get new_password_reset_path
        aggregate_failures do 
          expect(response).to have_http_status(200)
          expect(response.body).to include "Forgot password"
        end
      end
    end

    describe "create action" do 
      context "when user's email is invalid" do 
        it "returns unprocesssable_entity" do 
          post password_resets_path, params: { password_reset: { email: " " }}
          aggregate_failures do             
            expect(ActionMailer::Base.deliveries.count).to eq 0
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context "when user's email is valid" do 
        it "succeed to send email and redirect root url" do 
          post password_resets_path, params: { password_reset: { email: user.email }}
          aggregate_failures do             
            expect(ActionMailer::Base.deliveries.count).to eq 1
            expect(response).to have_http_status(302)
            expect(response).to redirect_to root_url
          end
        end
      end
    end

    describe "edit action" do 
      # 以下のbeforeブロックの目的は、user.reset_tokenを設定する必要があるが、
      # user.reset_token = User.new_token　では小手先の変更となってしまい、
      # user.authenticated?のreset_tokenとreset_digestの照合の時にこけてしまう。
      # ちゃんと、user.reset_tokenをもとに、reset_digestが生成されたというプロセスを踏む必要があるので、
      # create_reset_digestを事前に読んでいる。
      before { user.create_reset_digest }
      before { activated_user.create_reset_digest }
      
      # get_userとvalid_userの@userの存在性をテスト
      context "when user's email is invalid" do 
        it "fails" do 
          get edit_password_reset_path(user.reset_token, email: "")
          expect(response).to redirect_to root_url 
        end
      end
      
      # valid_userのcallbackの@user.activated?をテスト
      context "when the user is not activated" do 
        it "fails" do 
          get edit_password_reset_path(user.reset_token, email: user.email )
          expect(response).to redirect_to root_url
        end
      end

      # valid_userのcallbackの@user.authenticated?をテスト
      context "when the user's reset_token is invalid, but email is correct" do 
        it "fails" do 
          activated_user.reset_token = User.new_token
          get edit_password_reset_path("", email: activated_user.email )
          expect(response).to redirect_to root_url
        end
      end

      # 全部okの場合
      context "when both of reset_token and email is correct" do 
        it "allows user to access Reset Password page" do
          get edit_password_reset_path(activated_user.reset_token, email: activated_user.email )
          expect(response).to have_http_status 200
          expect(response.body).to include "Reset password"
        end
      end
    end

    describe "update action" do 
      before { activated_user.create_reset_digest }

      # password欄とConfirmation欄がどちらも空の場合
      context "when password and password_confirmation are blank" do 
        it "fails" do 
          patch password_reset_path(activated_user.reset_token), 
          params: {
            email: activated_user.email,
            user: {
              password: "",
              password_confirmation: ""
            }
          }
          expect(CGI.unescapeHTML(response.body)).to include "Password can't be empty"
        end
      end
    
      # userのバリデーションで引っかかる無効なpasswordの場合
      context "when password and password_confirmation are invalid" do
        it "fails" do 
          patch password_reset_path(activated_user.reset_token), 
          params: {
            email: activated_user.email,
            user: {
              password: "fooba",
              password_confirmation: "fooba"
            }
          }
          expect(CGI.unescapeHTML(response.body)).to include "Password is too short (minimum is 6 characters)"
        end
      end

      # password欄とConfirmation欄がどちらも有効な場合
      # passwordのリセットに成功するということは、以下の状況になっているはず
      # 　- userのreset_digest がnilになっている
      # 　- ”Password has been reset.”のflashが出る
      # 　- ログイン状態になっている
      # 　- user_path(@user)にリダイレクトする
      context "when password and password_confirmation are correct" do
        it "succeeds to reset password" do 
          patch password_reset_path(activated_user.reset_token), 
          params: {
            email: activated_user.email,
            user: {
              password: "foobar",
              password_confirmation: "foobar"
            }
          }
          aggregate_failures do 
            expect(activated_user.reload.reset_digest).to eq nil
            expect(is_logged_in? activated_user).to be_truthy
            expect(response).to redirect_to user_path(activated_user)
            expect(flash[:success]).to be_truthy 
          end
        end
      end
    end

    describe "check the URL's expiration" do 
      before { activated_user.create_reset_digest }

      context "when user tyies to access after 3 hours" do 

        it "fails" do
          activated_user.update_attribute(:reset_sent_at, 3.hours.ago)
          patch password_reset_path(activated_user.reset_token), 
          params: {
            email: activated_user.email,
            user: {
              password: "foobar",
              password_confirmation: "foobar"
            }
          }
          expect(response).to redirect_to new_password_reset_url
          expect(flash[:danger]).to be_truthy  
        end
      end
    end
end
