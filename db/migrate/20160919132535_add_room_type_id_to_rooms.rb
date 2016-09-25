class AddRoomTypeIdToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :room_type_id, :integer
  end
end
