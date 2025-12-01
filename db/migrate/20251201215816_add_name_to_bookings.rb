class AddNameToBookings < ActiveRecord::Migration[8.1]

  def change
    add_column :bookings, :name, :string
  end

end
