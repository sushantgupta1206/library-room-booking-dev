# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# Create buildings
require 'services/common.rb'

#bldg1 = BuildingService.create("D.H. Hill")
#bldg2 = BuildingService.create("James B. Hunt")
#BuildingService.save(bldg1)
#BuildingService.save(bldg2)

# Create Room Types

#rt1 = RoomTypeService.create("Small")
#rt2 = RoomTypeService.create("Medium")
#rt3 = RoomTypeService.create("Large")

#RoomTypeService.save(rt1)
#RoomTypeService.save(rt2)
#RoomTypeService.save(rt3)

#room1 = RoomService.create("Pine",bldg1,rt2)
#room2 = RoomService.create("Teak", bldg2, rt2)
#room3 = RoomService.create("Oak", bldg1, rt3)
#RoomService.save(room1)
#RoomService.save(room2)
#RoomService.save(room3)

admin = UserService.create_admin("admin@ncsu.edu", "NCSU", "Admin", "admin01", "admin01")
admin.is_preconfigured = true
admin.save

