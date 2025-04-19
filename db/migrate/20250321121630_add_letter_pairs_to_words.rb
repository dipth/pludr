class AddLetterPairsToWords < ActiveRecord::Migration[8.0]
  def change
    add_column :words, :letter_pairs, :string, array: true, default: []
    add_index :words, :letter_pairs, using: :gin
  end
end
