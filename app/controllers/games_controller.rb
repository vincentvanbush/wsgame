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
        partial: self.render(partial: 'rooms/game', locals: { game: game, user: nil })
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
    ensure_user_is_player
    x, y = move_params[:x], move_params[:y]
    @game.board[x, y] = current_color
    @game.game_over = true if @game.board.game_over?
    @game.save!
    ActionCable.server.broadcast "game_#{@game.id}",
      msg_type: 'move',
      user: current_user.username,
      color: current_color,
      x: x,
      y: y,
      game_over: @game.game_over?,
      winner: @game.board.winner
    head :no_content
  rescue GameError => e
    ActionCable.server.broadcast "private_user:#{current_user.uuid}",
      msg_type: 'illegal_move',
      message: e.message
    head 422
  rescue ActiveRecord::RecordInvalid => invalid
    ActionCable.server.broadcast "private_user:#{current_user.uuid}",
      msg_type: 'illegal_move',
      message: invalid.record.errors.full_messages.to_sentence
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
    join_or_spectate
  rescue ActiveRecord::RecordNotFound
    redirect_to rooms_path
  end

  private

  def move_params
    params.permit(:x, :y)
  end

  def current_color
    current_user.id == @game.player1_id ? :white : :black
  end

  def ensure_user_is_player
    if [@game.player1_id, @game.player2_id].exclude?(current_user.id)
      raise SpectatorMoveError,
            'As a spectator you can only watch the game'
    end

    if @game.players.size < 2
      raise NoPlayerError, 'Please wait for another player'
    end
  end

  def join_or_spectate
    if @game.player1.blank? && !current_user.in_game?
      @game.update(player1: current_user)
    elsif @game.player2.blank? && !current_user.in_game?
      @game.update(player2: current_user)
    end
  end
end
