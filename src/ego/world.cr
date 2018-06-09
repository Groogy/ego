class World
  @map : Map
  @terrains = TerrainDatabase.new
  @entities : EntityManager
  @entity_categories = EntityCategoryManager.new
  @entity_templates = EntityTemplateManager.new
  @current_tick = GameTime.new
  @paused = false
  @random : Boleite::Random

  property current_tick, map, random
  getter terrains, entities, entity_categories, entity_templates
  getter? paused

  def initialize
    size = Boleite::Vector2i.new 64, 64
    @map = Map.new size
    @entities = EntityManager.new @map
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
    @entities.create_entity template, pos, self
  end

  def update
    unless @paused
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
    
    size = 64
    center = Boleite::Vector2f.new size / 2.0 - 1, size / 2.0 - 1
    size.times do |x|
      size.times do |y|
        delta = Boleite::Vector2f.new center.x - x, center.y - y
        distance = Boleite::Vector.magnitude delta
        coord = Boleite::Vector2i.new x, y

        if distance < 18
          height = 9.0 - distance / 2.0
          @map.set_height coord, height
          @map.set_terrain coord, rock
        else
          @map.set_terrain coord, grass
        end
      end
    end
  end
end