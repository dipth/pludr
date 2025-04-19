class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :workflow_state, null: false, index: true
      t.string :letters, null: false
      t.string :salt, null: false
      t.timestamps
      t.datetime :started_at
      t.datetime :ended_at
    end
  end
end
