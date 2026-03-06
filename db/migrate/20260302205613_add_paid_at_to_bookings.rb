class AddPaidAtToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :paid_at, :datetime
  end
end
