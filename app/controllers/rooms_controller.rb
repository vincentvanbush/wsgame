class RoomsController < ApplicationController
  before_action :login_required

  def show
    @room = Room.find_by(name: params[:name])
    @user = current_user
    @message = Message.new
  end

  def index
    @rooms = Room.all
  end
end
