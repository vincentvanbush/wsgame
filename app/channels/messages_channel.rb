class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages_user:#{params[:user]}_room:#{params[:room]}"
  end
end
