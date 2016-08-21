class PagesController < ApplicationController
  def main
    if current_user
      redirect_to rooms_path
    else
      @user = User.new
    end
  end
end
