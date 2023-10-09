require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  describe "testing before filter" do
    let(:relationship) { FactoryBot.create(:relationship) }
    context "create action" do
      it "requires user to login" do
        expect {
          post relationships_path
          
          expect(response).to redirect_to login_url
        }.to_not change(Relationship, :count)
      end
    end

    context "delete action" do
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
