class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.boolean :admin
      t.string :email_address
      t.string :password_digest
      t.references :account, null: false

      t.timestamps
    end
  end
end
