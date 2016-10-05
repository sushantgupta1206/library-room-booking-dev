# A room domain object is in a building and has a type
# Room has a name/number

class Room < ApplicationRecord
  belongs_to :building
  belongs_to  :room_type
end

=begin
class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.references :building, foreign_key: true

      t.timestamps
    end
  end
end
=end
