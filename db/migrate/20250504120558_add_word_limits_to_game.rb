class AddWordLimitsToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :min_words, :integer, null: false
    add_column :games, :max_words, :integer, null: false
  end
end
