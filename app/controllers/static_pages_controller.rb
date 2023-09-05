class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
    render stream: true
  end

  def contact
  end

  def testguard
  end
end
