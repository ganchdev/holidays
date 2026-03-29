# frozen_string_literal: true

class CreateBotVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :bot_verifications do |t|
      t.string :code, null: false
      t.string :chat_id, null: false
      t.datetime :expires_at, null: false
      t.references :authorized_user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :bot_verifications, [:chat_id, :code]
  end
end
