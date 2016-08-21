class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room

  def self.default_scope
    order(created_at: :desc).limit(50)
  end
end
