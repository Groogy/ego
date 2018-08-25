class MovingComponent < EntityComponent
  include CrystalClear

  @target : Path?
  @progress = 0.0

  property progress
  property target

  def initialize(data, entity, world)
    super data, entity, world
  end

  def speed
    @data.get_float "speed"
  end
end
