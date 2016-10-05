# The roomtype domain object is used by many rooms
# Roomtype has a size attribute - small, medium, large

class RoomType < ApplicationRecord
  has_many :rooms
end

=begin
class CreateRoomTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :room_types do |t|
      t.string :size

      t.timestamps
    end
  end
end
=end
