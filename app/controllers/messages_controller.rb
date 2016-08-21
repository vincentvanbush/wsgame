class MessagesController < ApplicationController
  before_action :login_required

  def create
    message = Message.new(message_params)
    message.user = current_user
    if message.save
      ActionCable.server.broadcast "messages_room:#{message.room.id}",
        msg_type: 'chat',
        message: message.content,
        user: message.user.username
      head :ok
    else
      render status: 422,
             json: { error: message.errors.full_messages.to_sentence }
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :room_id)
  end
end
