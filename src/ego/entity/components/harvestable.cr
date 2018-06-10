class HarvestableComponent < EntityComponent
  include CrystalClear
  
  @entity : Entity?
  @provides : EntityTemplate
  @time_since_harvest = GameTime.new

  getter provides, time_since_harvest

  def initialize(data, entity, world)
    super data, entity, world
    @provides = world.entity_templates.get data.get_string("provides")
    create_entity world, entity
  end

  def growth_time
    @data.get_gametime "growth_time"
  end

  def can_harvest?
    @entity != nil
  end

  def reset_harvest
    @time_since_harvest = GameTime.new
  end

  def increase_time_since_harvest
    @time_since_harvest = @time_since_harvest.next_tick
  end

  def create_entity(world, entity)
    @entity = world.spawn_entity @provides, OffmapEntityPos.new(entity)
  end
end
