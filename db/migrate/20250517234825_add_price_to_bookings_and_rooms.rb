class AddPriceToBookingsAndRooms < ActiveRecord::Migration[8.0]

  def change
    add_column :bookings, :price, :decimal, precision: 10, scale: 2
    add_column :rooms, :price, :decimal, precision: 10, scale: 2
  end

end
