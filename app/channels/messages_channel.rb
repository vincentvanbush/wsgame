class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages_room:#{params[:room]}"
  end
end
