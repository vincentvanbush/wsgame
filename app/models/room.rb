class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :users, through: :messages
  has_many :games, dependent: :destroy
  validates :name, presence: true, uniqueness: true, case_sensitive: false
end
