require 'rails_helper'

RSpec.describe Micropost, type: :model do
  before do 
    @micropost = FactoryBot.create(:micropost)
  end

  test "exists test object" do 
    p @micropost
  end
end
