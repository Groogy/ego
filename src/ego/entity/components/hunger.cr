class HungerComponent < EntityComponent
  @satisfaction : Int64

  property satisfaction

  def initialize(data, entity, world)
    super data, entity, world
    @satisfaction = data.get_int "max_satisfaction"
  end

  def satisfaction_decay
    @data.get_int "satisfaction_decay"
  end

  def max_satisfaction
    @data.get_int "max_satisfaction"
  end

  def edible
    @data.get_array("edible").map { |val| val.as(String) }
  end
end
