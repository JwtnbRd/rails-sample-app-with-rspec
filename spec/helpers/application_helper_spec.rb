require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#
# describe ApplicationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ApplicationHelper, type: :helper do
  before do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  describe "displays full title with full title helper" do
    context "full title helper without any variables" do
      it "displays only base title" do
        expect(full_title).to eq @base_title
      end
    end

    context "full title helper with a variable" do
      it "combines base title and a variable string" do 
        expect(full_title("Hoge")).to eq "Hoge | #{@base_title}"
      end
    end
  end
end
