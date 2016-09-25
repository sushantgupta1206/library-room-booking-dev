class RoomService

  def RoomService.create(name, bldg, room_type)
    room = Room.new
    room.name = name
    room.building = bldg
    room.room_type = room_type
    return room
  end

  def RoomService.resize(room, rt)
    room.rt = rt;
    room.save
    return bldg
  end

  def RoomService.save (room)
    room.save
    return room
  end

  def RoomService.find (name)
    Room.find_by(name: name)
  end

  def RoomService.find_all()
    Room.all();
  end

  def RoomService.find_all_in_building(bldg)
    Room.where('building_id = ?', bldg.id)
  end

  def RoomService.search_room(room_name, building_id, room_type_id)
      if (room_name != nil and room_name != "")
        Room.where('name = ? AND building_id = ? AND room_type_id = ?', room_name, building_id, room_type_id)
      else
        Room.where('building_id = ? AND room_type_id = ?', building_id, room_type_id)
      end
  end
end