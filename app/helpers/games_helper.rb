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

  def game_link(game)
    if game.can_be_joined?
      link_to 'Spectate or Join', game
    else
      link_to 'Spectate', game
    end
  end
end
