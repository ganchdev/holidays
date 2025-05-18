class AddPriceToBookings < ActiveRecord::Migration[8.0]

  def change
    add_column :bookings, :price, :decimal, precision: 10, scale: 2
  end

end
