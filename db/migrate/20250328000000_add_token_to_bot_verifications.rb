# frozen_string_literal: true

class AddTokenToBotVerifications < ActiveRecord::Migration[8.0]
  def change
    add_column :bot_verifications, :token, :string
    add_index :bot_verifications, :token, unique: true
  end
end
