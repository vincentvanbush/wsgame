class GamesController < ApplicationController
  def create
    @room = Room.find_by!(name: params[:room_name])
    @game = @room.games.new(player1: current_user)
    if @game.save
      cable_game_created
      head :ok
    else
      render status: 422,
             json: { error: @game.errors.full_messages.to_sentence }
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @room = @game.room
    if @game.destroy
      cable_game_destroy
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
    cable_move(x, y)
    head :no_content
  rescue GameError => e
    cable_illegal_move(e.message)
    head 422
  rescue ActiveRecord::RecordInvalid => invalid
    cable_illegal_move(invalid.record.errors.full_messages.to_sentence)
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

  def leave
    @game = Game.find(params[:id])
    @room = @game.room
    @user = current_user
    if @game.leave!(@user)
      # tell the other player and spectators
      cable_game_leave
      # notify room
      if @game.destroyed?
        cable_game_destroy
      else
        cable_game_update
      end
      redirect_to room_path(@game.room.name)
    else
      head 422
    end
  end

  def restart
    @game = Game.find(params[:id])
    if !@game.game_over?
      head 422
    elsif @game.players.exclude? current_user
      head 401
    elsif @game.update(board: Board.new, game_over: false)
      cable_game_restart
      head 200
    else
      head 422
    end
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
    free_slot = if @game.player1.blank? && !current_user.in_game?
                  :player1
                elsif @game.player2.blank? && !current_user.in_game?
                  :player2
                end
    if free_slot
      @game.update(free_slot => current_user)
      # tell the other player and spectators
      cable_game_join
      # notify everyone in the room
      cable_game_update
    end
  end

  def cable_game_update
    ActionCable.server.broadcast "messages_room:#{@room.id}",
      msg_type: 'update_game',
      message: '___game updated___',
      game_id: @game.id,
      partial: ApplicationController.render(partial: 'rooms/game', locals: { game: @game, user: nil })
  end

  def cable_game_destroy
    ActionCable.server.broadcast "messages_room:#{@room.id}",
      msg_type: 'delete_game',
      message: '___game deleted___',
      user: current_user.username,
      game_id: @game.id
  end

  def cable_game_join
    ActionCable.server.broadcast "game_#{@game.id}",
      msg_type: 'join',
      user: current_user.username,
      scoreboard_partial: ApplicationController.render(partial: 'games/scoreboard', locals: { game: @game })
  end

  def cable_illegal_move(msg)
    ActionCable.server.broadcast "private_user:#{current_user.uuid}",
      msg_type: 'illegal_move',
      message: msg
  end

  def cable_move(x, y)
    game_over = @game.game_over?
    ActionCable.server.broadcast "game_#{@game.id}",
      msg_type: 'move',
      user: current_user.username,
      color: current_color,
      x: x,
      y: y,
      game_over: game_over,
      winning_coords: game_over ? @game.board.winning_coords.map { |c| { x: c.first, y: c.second } } : nil,
      winner: @game.board.winner,
      scoreboard_partial: ApplicationController.render(partial: 'games/scoreboard', locals: { game: @game })
  end

  def cable_game_created
    ActionCable.server.broadcast "messages_room:#{@room.id}",
      msg_type: 'new_game',
      message: '___new game created___',
      user: current_user.username,
      uuid: current_user.uuid,
      game_id: @game.id,
      partial: ApplicationController.render(partial: 'rooms/game', locals: { game: @game, user: nil })
  end

  def cable_game_leave
    ActionCable.server.broadcast "game_#{@game.id}",
      msg_type: 'leave',
      user: current_user.username,
      scoreboard_partial: ApplicationController.render(partial: 'games/scoreboard', locals: { game: @game })
  end

  def cable_game_restart
    ActionCable.server.broadcast "game_#{@game.id}",
      msg_type: 'restart'

  end
end
