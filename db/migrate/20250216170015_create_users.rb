class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :account
      t.boolean :admin
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :image
      t.string :email_address, null: false

      t.timestamps
    end

    add_index :users, :email_address, unique: true
  end
end
