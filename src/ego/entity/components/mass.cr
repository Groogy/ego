class MassComponent < EntityComponent
  include CrystalClear

  def self.volume(data)
    data.get_float "volume"
  end

  def self.weight(data)
    data.get_float "weight"
  end

  def volume
    MassComponent.volume @data
  end

  def weight
    MassComponent.weight @data
  end
end
