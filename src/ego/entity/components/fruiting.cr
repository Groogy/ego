class FruitingComponent < EntityComponent
  include CrystalClear
  
  @provides : EntityTemplate
  @target_storage : BaseStorageComponent
  @time_since_growth = GameTime.new
  @season : {start: GameTime, end: GameTime}

  getter provides, time_since_growth, target_storage
  protected setter time_since_growth

  def initialize(data, entity, world)
    super data, entity, world
    @provides = world.entity_templates.get data.get_string("provides")
    @target_storage = entity.get_component(data.get_string("into")).as(BaseStorageComponent)

    season = data.get_array "season"
    @season = {start: season[0].as(GameTime), end: season[1].as(GameTime)}
  end

  def growth_time
    @data.get_gametime "growth_time"
  end

  def time_left
    @time_since_growth >= growth_time ? GameTime.new : growth_time - @time_since_growth
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

  def start_season
    @season[:start]
  end

  def end_season
    @season[:end]
  end

  def can_grow?(entity, world)
    date = world.date - world.date.to_years
    @target_storage.count < limit && date > @season[:start] && date < @season[:end]
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
