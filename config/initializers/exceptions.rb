class GameError < StandardError; end
class ColorError < GameError; end
class TakenError < GameError; end
class GameOverError < GameError; end
class TurnError < GameError; end
class NoPlayerError < GameError; end
class SpectatorMoveError < GameError; end