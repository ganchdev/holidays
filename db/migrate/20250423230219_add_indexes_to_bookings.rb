class AddIndexesToBookings < ActiveRecord::Migration[8.0]

  def change
    add_index :bookings, :starts_at
    add_index :bookings, :ends_at
    add_index :bookings, :cancelled_at
  end

end
