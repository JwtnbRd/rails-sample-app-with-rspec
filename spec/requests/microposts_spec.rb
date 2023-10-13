require 'rails_helper'

RSpec.describe "Microposts", type: :request do
  let(:micropost) { FactoryBot.create(:micropost) }
  let(:user) { FactoryBot.create(:user) }
  
  describe "create action" do
    context "when user is not logged in" do
      it "doesn't allow user to post any microposts" do 
        expect {
          post microposts_path, params: {
            micropost: { content: "Lorem Ipsum" } 
          }
          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to login_url
        }.to_not change(Micropost, :count)
      end

      it "doesn't allow user to delete any microposts" do 
        micropost
        expect {
          delete micropost_path(micropost)
          
          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to login_url
        }.to_not change(Micropost, :count)
      end
      # リクエストスペック内でsessionメソッドを使うにはメソッドを呼ぶ前に何らかのHTTPリクエストを送っている必要がある。
      # 「ログインしたユーザーが他のユーザーのマイクロポストに対してdeleteしようとした場合はエラーになる」というテストの書き換えがまだだけど…
      # -> ログインをシミュレートして、どうこうするというのはシステムスペックに任せる方が良いかも
    end
  end
end
