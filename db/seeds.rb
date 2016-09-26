# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# Create buildings
require 'services/common.rb'

bldg1 = BuildingService.create("D.H. Hill")
bldg2 = BuildingService.create("James B. Hunt")
BuildingService.save(bldg1)
BuildingService.save(bldg2)

# Create Room Types

rt1 = RoomTypeService.create("Small")
rt2 = RoomTypeService.create("Medium")
rt3 = RoomTypeService.create("Large")

RoomTypeService.save(rt1)
RoomTypeService.save(rt2)
RoomTypeService.save(rt3)

room1 = RoomService.create("Pine",bldg1,rt2)
room2 = RoomService.create("Teak", bldg2, rt2)
room3 = RoomService.create("Oak", bldg1, rt3)
RoomService.save(room1)
RoomService.save(room2)
RoomService.save(room3)

admin = UserService.create_admin("admin@admin.edu", "Admin", "Admin", "admin01", "admin01");
admin.is_preconfigured = true;
admin.save

library_user = UserService.create_library_user("arvind@hudli.com", "Arvind", "Hudli", "arvind01", "arvind01")
library_user.save
library_user2 = UserService.create_library_user("arvind@hudli.net", "Arvind", "Hudli", "arvind01", "arvind01")
library_user2.save


booking = BookingService.create_booking(room1, Date.new(2016,9,26),10,12,library_user,"arvind@hudli.com,arvind@hudli.net")
#booking2 = BookingService.create_booking(room1, Date.new(2016,9,27),14,16,library_user,"arvind@hudli.com,arvind@hudli.net")
#booking3 = BookingService.create_booking(room1, Date.new(2016,9,27),15,17,library_user,"arvind@hudli.com,arvind@hudli.net")
#booking4 = BookingService.create_booking(room1, Date.new(2016,9,26),17,19,library_user,"arvind@hudli.com,arvind@hudli.net",true)
#booking5 = BookingService.create_booking(room1, Date.new(2016,9,27),12,14, library_user2,"arvind@hudli.net,arvind@hudli.com")
