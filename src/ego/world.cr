class World
  @map : Map

  def initialize
    @map = Map.new Boleite::Vector2i.new(64, 64)
  end

  def update
  end

  def render(renderer)
    @map.render renderer
  end

  def generate_map
    grass = TerrainType.new "grass", Boleite::Colorf.new 0f32, 1f32, 0f32, 1f32
    mountain = TerrainType.new "mountain", Boleite::Colorf.new 0.5f32, 0.5f32, 0.5f32, 1f32

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
          @map.set_terrain coord, mountain
        else
          @map.set_terrain coord, grass
        end
      end
    end
  end
end