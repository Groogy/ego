class World
  @map : Map
  @terrains = TerrainDatabase.new
  @entities : EntityManager
  @entity_categories = EntityCategoryManager.new
  @entity_templates = EntityTemplateManager.new
  @social_units : SocialUnitManager
  @current_tick = GameTime.new
  @paused = false
  @random : Boleite::Random

  getter current_tick, map, random, terrains
  getter entities, entity_categories, entity_templates
  getter social_units
  getter? paused

  protected setter current_tick, map, random, entities, social_units

  def initialize
    size = Boleite::Vector2i.new 128, 128
    @map = Map.new size
    @entities = EntityManager.new @map
    @social_units = SocialUnitManager.new
    @random = Boleite::NoiseRandom.new 0u32
  end

  def load_data
    @terrains.load_folder "data/tiles"
    @entity_categories.load_folder "data/entity_categories"
    @entity_templates.load_folder "data/entities", self
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

  def generate_map
    grass = @terrains.find "grass"
    rock = @terrains.find "rock"
    
    size = 128
    mountain_size = 36
    center = Boleite::Vector2f.new size / 2.0 - 1, size / 2.0 - 1
    size.times do |x|
      size.times do |y|
        delta = Boleite::Vector2f.new center.x - x, center.y - y
        distance = Boleite::Vector.magnitude delta
        coord = Boleite::Vector2i.new x, y

        if distance < mountain_size
          height = Map::MAX_HEIGHT * ((mountain_size - distance) / mountain_size)
          @map.set_height coord, height
          @map.set_terrain coord, rock
        else
          @map.set_terrain coord, grass
        end
      end
    end
  end
end