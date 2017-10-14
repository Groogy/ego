class World
  @tilemap : Tilemap

  def initialize(tileset)
    @tilemap = Tilemap.new Boleite::Vector2u.new(64u32, 64u32), tileset
  end

  def update
  end

  def render(renderer)
    @tilemap.render renderer
  end

  def generate_tilemap
    size = 64u32
    water = TileType.new "water", "Water", Boleite::Vector2u.new(1u32, 1u32)
    plains = TileType.new "plains", "Plains", Boleite::Vector2u.new(19u32, 1u32)
    mountains = TileType.new "mountains", "Mountains", Boleite::Vector2u.new(37u32, 1u32)
    @tilemap.add_tile_type water
    @tilemap.add_tile_type plains
    @tilemap.add_tile_type mountains

    center = Boleite::Vector2f.new size / 2.0 - 1, size / 2.0 - 1
    size.times do |x|
      size.times do |y|
        delta = Boleite::Vector2f.new center.x - x, center.y - y
        distance = Boleite::Vector.magnitude delta
        coord = Boleite::Vector2u.new x, y
        if distance < 12
          @tilemap.set_tile coord, mountains
        elsif distance < 30
          @tilemap.set_tile coord, plains
        else
          @tilemap.set_tile coord, water
        end

        if distance < 14
          height = 6u16 - distance.to_u16 / 2
          @tilemap.set_tile_height coord, height, distance != 0 && distance.to_u16 % 2 == 0
        end
      end
    end
    @tilemap.cleanup_ramps
  end

end