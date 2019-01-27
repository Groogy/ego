class World
  @map : Map
  @terrains = TerrainDatabase.new
  @entities : EntityManager
  @entity_categories = EntityCategoryManager.new
  @entity_templates = EntityTemplateManager.new
  @myth_templates = MythTemplateManager.new
  @social_units : SocialUnitManager
  @name_generators = NameGeneratorManager.new
  @current_tick = GameTime.new
  @paused = false
  @random : Boleite::Random

  getter current_tick, map, random, terrains
  getter entities, entity_categories, entity_templates
  getter myth_templates
  getter social_units
  getter name_generators
  getter? paused

  protected setter current_tick, map, random, entities, social_units, name_generators

  def initialize(size)
    @map = Map.new size
    @entities = EntityManager.new @map
    @social_units = SocialUnitManager.new
    @random = Boleite::NoiseRandom.new 0u32
  end

  def load_data
    @terrains.load_folder "data/tiles"
    @entity_categories.load_folder "data/entity_categories"
    @entity_templates.load_folder "data/entities", self
    @myth_templates.load_folder "data/myths"
    @name_generators.load_folder "data/names"
  end

  def toggle_pause
    @paused = !@paused
  end

  def date
    @current_tick
  end

  def spawn_entity(template, pos)
    @entities.create template, pos, self
  end

  def can_be_placed?(template, pos)
    return @entities.grid.inside?(pos, template.size) &&
           @map.flat?(pos, template.size)
  end

  def within_boundraries?(pos)
    @entities.grid.inside? pos, Boleite::Vector2i.one
  end

  def movement_cost(from, to)
    start_cost = @map.get_movement_cost from
    end_cost = @map.get_movement_cost to
    start_height = @map.get_height from
    end_height = @map.get_height to
    cost = (start_cost + end_cost) / 2.0
    cost *= (end_height - start_height).abs + 1
  end

  def update
    unless @paused
      @entities.update self
      @social_units.update self
      @current_tick = @current_tick.next_tick
    end
  end

  def render(renderer)
    @map.render renderer
    @entities.render renderer
  end
end