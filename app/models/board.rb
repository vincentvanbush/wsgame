class Board
  attr_accessor :turn

  MAX = 15
  LEN = 5

  def initialize(board_hash = {})
    unless board_hash.is_a? Hash
      raise ArgumentError, 'Pass a hash as an argument'
    end

    unless board_hash.all? do |k, v|
             k.is_a?(Integer) && k.between?(0, MAX - 1) && v.is_a?(Hash)
           end
      raise ArgumentError, 'Pass a hash with integer keys and hash values'
    end

    unless board_hash.values.all? do |v|
             v.keys.all? do |k|
               k.is_a?(Integer) &&
               v.values.all? { |vv| [:white, :black].include?(vv) }
             end
           end
      raise ArgumentError,
            'Inner hashes must have integer keys and :white/:black values'
    end

    @turn = :white
    @board_hash = board_hash
  end

  def [](a, b)
    @board_hash.dig(a.to_i, b.to_i)
  end

  def []=(a, b, x)
    validate_move(a.to_i, b.to_i, x)
    switch_turn!
    @board_hash[a.to_i] ||= []
    @board_hash[a.to_i][b.to_i] = x
  end

  def validate_move(a, b, x)
    raise ArgumentError,
          "#{x} is not :white or :black" if [:white, :black].exclude?(x)
    raise GameOverError, 'Game is already over' if game_over?
    raise TurnError, "It is now #{@turn}'s turn" unless x == @turn
    raise TakenError, "#{a}:#{b} is taken" if taken?(a.to_i, b.to_i)
  end

  def game_over?
    winner.present?
  end

  def coords_of(color)
    @board_hash.
      map { |k, v| [k, v.each_with_index.map { |x, i| x == color ? i : nil }.compact] }.
      map { |a| a.second.zip([a.first] * a.second.size).map(&:reverse) }.
      flatten.each_slice(2).to_a
  end

  def winner
    # This is very suboptimal but who cares lol
    all_xy_pairs.each do |coords|
      startx, starty = coords
      v = self[startx, starty]
      next if v.nil?
      horiz = (0..4).map { |i| self[startx, starty + i] }
      vert = (0..4).map { |i| self[startx + i, starty] }
      diag1 = (0..4).map { |i| self[startx + i, starty + i] }
      diag2 = (0..4).map { |i| self[startx + i, starty - i] }
      if [horiz, vert, diag1, diag2].any? { |list| list.all? { |x| x == v } }
        return v
      end
    end
    nil
  end

  def free?(a, b)
    self[a, b].nil?
  end

  def taken?(a, b)
    !free?(a, b)
  end

  def to_h
    @board_hash
  end

  private

  def all_xy_pairs
    (0...MAX * MAX).map { |x| [x / MAX, x % MAX] }
  end

  def switch_turn!
    @turn = @turn == :white ? :black : :white
  end
end
