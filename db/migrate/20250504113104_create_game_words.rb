class CreateGameWords < ActiveRecord::Migration[8.0]
  def change
    create_table :game_words do |t|
      t.references :game, null: false, foreign_key: { on_delete: :cascade }
      t.references :word, null: false, foreign_key: { on_delete: :nullify }
      t.citext :value, index: true
      t.string :hashed_value, index: true
      t.integer :length, index: true
      t.integer :score, index: true

      t.timestamps
    end

    add_index :game_words, [ :game_id, :value ], unique: true
  end
end
