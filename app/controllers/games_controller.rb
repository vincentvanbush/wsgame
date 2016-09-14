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

  def push_move
    @game = Game.find(params[:id])
    x, y = move_params[:x], move_params[:y]
    @game.board[x, y] = current_color
    @game.save!
    ActionCable.server.broadcast "game_#{@game.id}",
      msg_type: 'move',
      user: current_user.username,
      color: current_color,
      x: x,
      y: y
    head :no_content
  rescue GameError => e
    ActionCable.server.broadcast "private_user:#{current_user.uuid}",
      msg_type: 'illegal_move',
      message: e.message
    head 422
  end

  def board
    game = Game.find(params[:id])
    white_coords = game.board.coords_of :white
    black_coords = game.board.coords_of :black
    render json: {
      white: white_coords,
      black: black_coords
    }
  end

  def show
    @game = Game.find(params[:id])
    @user = current_user
    @message = Message.new
    @room = @game.room
  end

  private

  def move_params
    params.permit(:x, :y)
  end

  def current_color
    current_user.id == @game.player1_id ? :white : :black
  end
end
