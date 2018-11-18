class MassComponent < EntityComponent
  include CrystalClear

  def volume
    @data.get_float "volume"
  end

  def weight
    @data.get_float "weight"
  end
end
