class CreateAuthorizedUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :authorized_users do |t|
      t.string :email_address
      t.references :account
      t.references :user

      t.timestamps
    end
  end
end
