class AddLetterScoresToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :letter_scores, :jsonb, default: {}
  end
end
