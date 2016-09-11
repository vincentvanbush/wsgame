class GameError < StandardError; end
class TakenError < GameError; end
class GameOverError < GameError; end
