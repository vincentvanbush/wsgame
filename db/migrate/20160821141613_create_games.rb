class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.references :room, foreign_key: true, null: false
      t.string :state, null: false, default: 'idle'

      t.timestamps
    end
    add_reference :games, :player1, foreign_key: { to_table: :users }
    add_reference :games, :player2, foreign_key: { to_table: :users }
  end
end
