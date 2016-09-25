class RoomTypeService


  def RoomTypeService.create(size)
    rt = RoomType.new
    rt.size = size
    return rt
  end

  def RoomTypeService.resize(rt, size)
    rt.size = size
    bldg.save
    return bldg
  end

  def RoomTypeService.save (rt)
    rt.save
    return rt
  end

  def RoomTypeService.find (room_size)
    RoomType.find_by(size: room_size)
  end

  def RoomTypeService.find_all()
    RoomType.all();
  end
end