class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room

  def self.default_scope
    order(created_at: :asc)
  end
end
