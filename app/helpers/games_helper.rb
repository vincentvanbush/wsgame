module GamesHelper
  def panel_class(game)
    if game.can_be_joined?
      'panel-success'
    else
      'panel-default'
    end
  end

  def game_heading(game)
    [game.player1, game.player2].
      compact.to_sentence(two_words_connector: ' vs. ')
  end

  def game_link(game, user)
    if user.blank? || game.can_be_joined? && !user.in_game?
      link_to 'Spectate or join', game
    elsif game.players.include?(user)
      link_to 'Return to game', game
    else
      link_to 'Spectate', game
    end
  end
end
