class GamesController < ApplicationController
  def create
    room = Room.find_by!(name: params[:room_name])
    game = room.games.new(player1: current_user)
    if game.save
      ActionCable.server.broadcast "messages_room:#{room.id}",
        msg_type: 'new_game',
        message: '___new game created___',
        user: current_user.username,
        uuid: current_user.uuid,
        game_id: game.id,
        partial: self.render(partial: 'rooms/game', locals: { game: game })
      head :ok
    else
      render status: 422,
             json: { error: game.errors.full_messages.to_sentence }
    end
  end

  def destroy
    game = Game.find(params[:id])
    if game.destroy
      ActionCable.server.broadcast "messages_room:#{game.room.id}",
        msg_type: 'delete_game',
        message: '___game deleted___',
        user: current_user.username,
        game_id: game.id
      head :no_content
    end
  end

  def show
    @game = Game.find(params[:id])
    @user = current_user
    @message = Message.new
    @room = @game.room
  end
end
