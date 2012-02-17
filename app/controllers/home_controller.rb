class HomeController < ApplicationController
  def index
    @users = User.latest
  end
end
