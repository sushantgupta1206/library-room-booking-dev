class Room < ApplicationRecord
  belongs_to :building
  belongs_to  :room_type
end
