class User < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :rooms, through: :messages
  validates :username, presence: true, uniqueness: true
  validates :uuid, presence: true, uniqueness: true

  def to_s
    username
  end
end
