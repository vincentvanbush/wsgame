class PrivateChannel < ApplicationCable::Channel
  def subscribed
    stream_from "private_user:#{params[:user]}"
  end
end
