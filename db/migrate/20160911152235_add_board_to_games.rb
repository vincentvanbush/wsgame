class AddBoardToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :board, :text
  end
end
