require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  let(:relationship) { FactoryBot.create(:relationship) }
  
  describe "create action" do
    context "when user is not logged in" do
      it "fails to create new relationship" do
        expect {
          post relationships_path
          expect(response).to redirect_to login_url
        }.to_not change(Relationship, :count)
      end
    end
  end

  describe "delete action" do 
    context "when user is not logged in" do
      it "requires user to login" do
        relationship
        expect {
          delete relationship_path(relationship)
          
          expect(response).to redirect_to login_url
        }.to_not change(Relationship, :count)
      end
    end
  end
end
