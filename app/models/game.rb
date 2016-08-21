class Game < ApplicationRecord
  belongs_to :room
  belongs_to :player1, class_name: 'User', optional: true
  belongs_to :player2, class_name: 'User', optional: true

  validates :state, presence: true, inclusion: { in: %w(idle started) }

  def can_be_joined?
    state == 'idle' && (player1.blank? || player2.blank?)
  end
end
