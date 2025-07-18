class CreateGuess < ActiveRecord::Migration[8.0]
  def change
    create_table :guesses do |t|
      t.references :game_word, null: false, foreign_key: { on_delete: :cascade }, index: true
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: true

      t.timestamps
    end

    add_index :guesses, [ :user_id, :game_word_id ], unique: true
  end
end
