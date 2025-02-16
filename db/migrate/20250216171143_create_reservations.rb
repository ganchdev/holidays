class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :room, null: false
      t.integer :adults
      t.integer :children
      t.text :notes
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
