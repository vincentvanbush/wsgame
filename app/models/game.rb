class Game < ApplicationRecord
  belongs_to :room
  belongs_to :player1, class_name: 'User', optional: true
  belongs_to :player2, class_name: 'User', optional: true

  validates :state, presence: true, inclusion: { in: %w(idle started) }
  validate :users_in_one_game

  def can_be_joined?
    state == 'idle' && (player1.blank? || player2.blank?)
  end

  def players
    [player1, player2].compact
  end

  private

  def users_in_one_game
    return unless ['player1', 'player2'].any? { |f| send("#{f}_id_changed?")}
    errors.add(:base,'Cannot join more than one game at a time') if players.any?(&:in_game?)
  end
end
