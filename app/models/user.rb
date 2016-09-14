# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  username   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string
#

class User < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :rooms, through: :messages
  validates :username, presence: true, uniqueness: true
  validates :uuid, presence: true, uniqueness: true

  def to_s
    username
  end

  def current_game
    current_games.first
  end

  def in_game?
    current_game.present?
  end

  private

  def current_games
    Game.not_over.where('player1_id = ? or player2_id = ?', id, id)
  end
end
