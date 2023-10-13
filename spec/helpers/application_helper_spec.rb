require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  before do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  describe "testing full_title helper method" do
    context "when any variable isn't passed to the method" do
      it "displays only base title" do
        expect(full_title).to eq @base_title
      end
    end

    context "when a string passed to the method" do
      it "displays combination of variable and base title" do 
        expect(full_title("Hoge")).to eq "Hoge | #{@base_title}"
      end
    end
  end
end
