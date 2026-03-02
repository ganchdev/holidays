class RemoveColorFromRooms < ActiveRecord::Migration[8.1]
  def change
    remove_column :rooms, :color, :string
  end
end
