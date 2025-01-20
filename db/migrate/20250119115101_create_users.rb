class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.citext  :username, null: false
      t.string  :name, null: false
      t.citext  :email_address, null: false
      t.string  :password_digest, null: false
      t.boolean :admin, null: false, default: false

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :email_address, unique: true
  end
end
