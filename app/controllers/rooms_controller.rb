class RoomsController < ApplicationController
  def show
    @room = Room.find_by(name: params[:name])
    @message = Message.new
  end
end
