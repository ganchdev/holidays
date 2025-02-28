class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :room, null: false
      t.integer :adults, default: 1
      t.integer :children, default: 0
      t.text :notes
      t.decimal :deposit, precision: 10, scale: 2
      t.datetime :cancelled_at
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
