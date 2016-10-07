#Booking domain object belongs to a room for a user

#
class Booking < ApplicationRecord
  belongs_to :room
  belongs_to :user
end
