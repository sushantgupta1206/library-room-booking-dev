class BuildingService

  def BuildingService.create(name)
    b = Building.new
    b.name = name
    return b
  end

  def BuildingService.rename(bldg, name)
    bldg.name = name
    bldg.save
    return bldg
  end

  def BuildingService.save (bldg)
    bldg.save
    return bldg
  end

  def BuildingService.find (bldg_name)
    Building.find_by(name: bldg_name)
  end

  def BuildingService.find_all()
    Building.all()
  end
end