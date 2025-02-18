class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :room, null: false
      t.integer :adults, default: 1
      t.integer :children, default: 0
      t.text :notes
      t.decimal :deposit, precision: 10, scale: 2
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
