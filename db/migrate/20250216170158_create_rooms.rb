class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.references :property, null: false
      t.integer :capacity
      t.string :name
      t.string :color

      t.timestamps
    end
  end
end
