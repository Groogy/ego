class World
  @map : Map
  @terrain_types : TerrainDatabase
  @current_tick = GameTime.new
  @paused = false

  property current_tick
  getter? paused

  def initialize
    @map = Map.new Boleite::Vector2i.new(64, 64)
    @terrain_types = TerrainDatabase.new
    @terrain_types.load_file "data/tiles/basic.yml"
  end

  def toggle_pause
    @paused = !@paused
  end

  def date
    @current_tick
  end

  def update
    unless @paused
      @current_tick = @current_tick.next_tick
    end
  end

  def render(renderer)
    @map.render renderer
  end

  def generate_map
    grass = @terrain_types.find "grass"
    rock = @terrain_types.find "rock"
    
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