class Map
  include CrystalClear

  TILE_WIDTH = 48
  TILE_HEIGHT = 32
  TILE_HEIGHT_SHIFT = 8
  MAX_HEIGHT = 16

  class Data
    @height = 0u8
    @terrain : TerrainType?

    property height, terrain
  end

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

    def inside?(p, map)
      v = create_vertices_for_test map
      Boleite::Vector.inside_shape? v, p
    end

    def create_vertices(map)
      xi, yi = map.apply_view_rotation @x.to_i, @y.to_i
      x = ((xi - yi) * Map::TILE_WIDTH / 2).to_f
      y = ((xi + yi) * Map::TILE_HEIGHT / 2).to_f
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

  @data = {} of Pos => Data
  @size = Boleite::Vector2i.zero
  @view_rotation = 0
  @renderer : MapRenderer

  getter size, data, view_rotation

  def initialize(@size)
    @size.x.times do |x|
      @size.y.times do |y|
        pos = Pos.new x.to_u16, y.to_u16
        @data[pos] = Data.new
      end
    end
    @renderer = MapRenderer.new @size
  end

  requires dir >= -1 && dir <= 1
  def rotate_view(dir)
    @view_rotation += dir
    @view_rotation = 0 if @view_rotation > 3
    @view_rotation = 3 if @view_rotation < 0
    @renderer.notify_change
  end

  def apply_view_rotation(x : Int32, y : Int32, depth=0) 
    x, y = apply_view_rotation y, @size.y - x - 1, depth+1 if depth < view_rotation
    {x, y}
  end

  requires inside? pos
  requires height >= 0 && height < MAX_HEIGHT
  def set_height(pos, height)
    @data[Pos.new pos].height = height.to_u8
    @renderer.notify_change
  end

  requires inside? pos
  def get_height(pos)
    @data[Pos.new pos].height.to_u8
  end

  requires inside? pos
  def get_height(x, y)
    get_height Boleite::Vector2i.new(x, y)
  end

  requires inside? pos
  def set_terrain(pos, terrain)
    @data[Pos.new pos].terrain = terrain
    @renderer.notify_change
  end

  requires inside? pos
  def get_terrain(pos)
    @data[Pos.new pos].terrain
  end

  requires inside? pos
  def get_terrain(x, y)
    get_terrain Boleite::Vector2i.new(x, y)
  end

  requires data.size == @data.size
  def apply_data(data, terrains)
    data.each do |d|
      pos = Pos.new (d[0] % @size.x).to_u16, (d[0] / @size.y).to_u16
      @data[pos].terrain = terrains.find d[1]
      @data[pos].height = d[2]
    end
  end

  def inside?(pos)
    Boleite::IntRect.new(0, 0, @size.x, @size.y).contains? pos
  end

  ensures return_value.nil? || inside? return_value
  def find_tile(pos : Boleite::Vector2f)
    each_tile_reversed do |tile_pos|
      return tile_pos if tile_pos.inside? pos, self
    end
    return nil
  end

  def each_tile
    @data.each_key do |pos|
      yield pos, @data[pos]
    end
  end

  def each_tile_reversed
    @size.y.downto 1 do |y|
      @size.x.downto 1 do |x|
        pos = Pos.new((x-1).to_u16, (y-1).to_u16).rotate_by self
        yield pos, @data[pos]
      end
    end
  end

  def render(renderer)
    @renderer.render self, renderer
  end
end