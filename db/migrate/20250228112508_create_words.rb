class CreateWords < ActiveRecord::Migration[8.0]
  def change
    create_table :words do |t|
      t.citext :value, null: false, index: { unique: true }
      t.timestamps
      t.datetime :deleted_at, index: true
    end
  end
end
