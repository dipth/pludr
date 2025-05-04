class AddGameWordsCountToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :game_words_count, :integer, default: 0
  end
end
