class Map
  struct Pos
    @x : Int16
    @y : Int16

    property x, y

    def initialize(index, map)
      size = map.size
      @x = index % size.x
      @y = index / size.x
    end

    def initialize(@x, @y)
    end

    def initialize(pos)
      @x = pos.x.to_i16
      @y = pos.y.to_i16
    end

    def -(val : Int)
      Pos.new @x - val, @y - val
    end

    def -(other)
      Pos.new @x - other.x, @y - other.y
    end

    def +(val : Int)
      Pos.new @x + val, @y + val
    end

    def +(other)
      Pos.new @x + other.x, @y + other.y
    end
  
    def rotate_by(map)
      x, y = @x.to_i, @y.to_i
      x, y = map.apply_view_rotation x, y
      Pos.new x.to_i16, y.to_i16
    end

    def to_index(map)
      @x + (@y * map.size.x)
    end

    def to_vector
      Boleite::Vector2i.new @x.to_i, @y.to_i
    end

    def to_rect
      Boleite::IntRect.new @x.to_i * Map::TILE_WIDTH, @y.to_i * Map::TILE_WIDTH, Map::TILE_WIDTH, Map::TILE_WIDTH
    end

    def inside?(pos)
      to_rect.contains? pos
    end

    def ==(other)
      @x == other.x && @y == other.y
    end
  end
end