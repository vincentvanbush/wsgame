class Game < ApplicationRecord
  belongs_to :room
  belongs_to :player1, class_name: 'User'
  belongs_to :player2, class_name: 'User'

  validates :state, presence: true, inclusion: { in: %w(idle started) }
end
