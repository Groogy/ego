class Map
  struct Pos
    @x : UInt16
    @y : UInt16

    property x, y

    def initialize(@x, @y)
    end

    def initialize(pos)
      @x = pos.x.to_u16
      @y = pos.y.to_u16
    end

    def -(other)
      Pos.new @x - other.x, @y - other.y
    end

    def +(other)
      Pos.new @x + other.x, @y + other.y
    end

    def inside?(p, map)
      v = create_vertices_for_test map
      Boleite::Vector.inside_shape? v, p
    end

    def translate_to_isometric(map)
      xi, yi = map.apply_view_rotation @x.to_i, @y.to_i
      x = ((xi - yi) * Map::TILE_WIDTH / 2).to_f
      y = ((xi + yi) * Map::TILE_HEIGHT / 2).to_f
      return x, y
    end

    def translate_to_isometric
      xi, yi = @x.to_i, @y.to_i
      x = ((xi - yi) * Map::TILE_WIDTH / 2).to_f
      y = ((xi + yi) * Map::TILE_HEIGHT / 2).to_f
      return x, y
    end

    def create_vertices(map)
      x, y = translate_to_isometric map
      height = map.get_height(self) * Map::TILE_HEIGHT_SHIFT
      vertex1 = Boleite::Vector2f.new x, y - height
      vertex2 = Boleite::Vector2f.new x + Map::TILE_WIDTH / 2, y - Map::TILE_HEIGHT / 2 - height
      vertex3 = Boleite::Vector2f.new x + Map::TILE_WIDTH, y - height
      vertex4 = Boleite::Vector2f.new x + Map::TILE_WIDTH, y + Map::TILE_HEIGHT_SHIFT
      vertex5 = Boleite::Vector2f.new x, y + Map::TILE_HEIGHT_SHIFT
      vertex6 = Boleite::Vector2f.new x + Map::TILE_WIDTH / 2, y + Map::TILE_HEIGHT / 2 - height
      {vertex1, vertex2, vertex3, vertex4, vertex5, vertex6}
    end

    def create_vertices_for_test(map)
      v = create_vertices map
      if map.get_height(self) > 0
        {v[0], v[1], v[2], v[3], v[4]}
      else
        {v[0], v[1], v[2], v[5]}
      end
    end

    def create_vertices_for_render(map)
      v = create_vertices map
      {v[0], v[1], v[2], v[5]}
    end
  
    def rotate_by(map)
      x, y = @x.to_i, @y.to_i
      x, y = map.apply_view_rotation x, y
      Pos.new x.to_u16, y.to_u16
    end
  end
end