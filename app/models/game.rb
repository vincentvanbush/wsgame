# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  room_id    :integer          not null
#  state      :string           default("idle"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player1_id :integer
#  player2_id :integer
#  board      :text
#  game_over  :boolean          default(FALSE)
#

class Game < ApplicationRecord
  belongs_to :room
  belongs_to :player1, class_name: 'User', optional: true
  belongs_to :player2, class_name: 'User', optional: true

  validates :state, presence: true, inclusion: { in: %w(idle started) }
  validate :users_in_one_game
  validate :dont_touch_archived_games, if: proc { |g| g.stale? }

  serialize :board, Board

  scope :not_over, -> { where(game_over: false) }
  scope :over, -> { where(game_over: true) }
  scope :not_stale, -> { where('updated_at > ?', 3.minutes.ago) }
  scope :active, -> { not_over.not_stale }

  def can_be_joined?
    state == 'idle' && (player1.blank? || player2.blank?)
  end

  def players
    [player1, player2].compact
  end

  def current_player
    case board.turn
    when :white then player1
    when :black then player2
    end
  end

  def leave!(user)
    leaving_player = if user.id == player1_id
                       :player1
                     elsif user.id == player2_id
                       :player2
                     end
    left = leaving_player && update(leaving_player => nil)
    destroy if players.blank?
    left
  end

  def stale?
    (updated_at || Time.current) < 3.minutes.ago
  end

  private

  def users_in_one_game
    return unless ['player1', 'player2'].any? { |f| send("#{f}_id_changed?")}
    errors.add(:base,'Cannot join more than one game at a time') if players.any? do |player|
      player.in_game? && player.current_game.id != self.id
    end
  end

  def dont_touch_archived_games
    errors.add(:base, 'This game has been archived because of inactivity for more than 3 minutes.')
  end
end
