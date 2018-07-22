class HarvestGrowthComponent < EntityComponent
  include CrystalClear
  
  @provides : EntityTemplate
  @target_storage : BaseStorageComponent
  @time_since_growth = GameTime.new

  getter provides, time_since_growth, target_storage

  def initialize(data, entity, world)
    super data, entity, world
    @provides = world.entity_templates.get data.get_string("provides")
    @target_storage = entity.get_component(data.get_string("into")).as(BaseStorageComponent)
  end

  def growth_time
    @data.get_gametime "growth_time"
  end

  def limit
    @data.get_int "limit"
  end

  def reset_growth
    @time_since_growth = GameTime.new
  end

  def advance_growth
    @time_since_growth = @time_since_growth.next_tick
  end

  def can_grow?
    @target_storage.count < limit 
  end

  def can_spawn?(entity)
    @time_since_growth >= growth_time && @target_storage.can_store? entity, @provides
  end

  def spawn_entity(world, entity)
    harvest = world.spawn_entity @provides, OffmapEntityPos.new(entity)
    @target_storage.store entity, harvest
    harvest
  end
end
