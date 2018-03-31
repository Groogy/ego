class Map
  include CrystalClear

  TILE_WIDTH = 48
  TILE_HEIGHT = 32
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

    def inside?(p)
      v = create_vertices
      Boleite::Vector.inside_shape? v, p
    end

    def create_vertices
      x = (@x * Map::TILE_WIDTH).to_f
      y = (@y / 2 * Map::TILE_HEIGHT).to_f
      if @y % 2 == 1
        y += Map::TILE_HEIGHT / 2
        x -= Map::TILE_WIDTH / 2
      end
      vertex1 = Boleite::Vector2f.new x, y
      vertex2 = Boleite::Vector2f.new x + Map::TILE_WIDTH / 2, y + Map::TILE_HEIGHT / 2
      vertex3 = Boleite::Vector2f.new x + Map::TILE_WIDTH, y
      vertex4 = Boleite::Vector2f.new x + Map::TILE_WIDTH / 2, y - Map::TILE_HEIGHT / 2
      {vertex1, vertex2, vertex3, vertex4}
    end
  end

  @data = {} of Pos => Data
  @size = Boleite::Vector2i.zero
  @renderer : MapRenderer

  getter size, data

  def initialize(@size)
    @size.x.times do |x|
      @size.y.times do |y|
        pos = Pos.new x.to_u16, y.to_u16
        @data[pos] = Data.new
      end
    end
    @renderer = MapRenderer.new @size
  end

  def set_height(pos, height)
    @data[Pos.new pos].height = height.to_u8
    @renderer.notify_change
  end

  def get_height(pos)
    @data[Pos.new pos].height.to_u8
  end

  def get_height(x, y)
    get_height Boleite::Vector2i.new(x, y)
  end

  def set_terrain(pos, terrain)
    @data[Pos.new pos].terrain = terrain
    @renderer.notify_change
  end

  def get_terrain(pos)
    @data[Pos.new pos].terrain
  end

  def get_terrain(x, y)
    get_terrain Boleite::Vector2i.new(x, y)
  end

  requires data.size == @data.size
  def apply_data(data, terrains)
    data.each_index do |index|
      #@data[index].terrain = terrains.find data[index][0]
      #@data[index].height = data[index][1]
    end
  end

  def inside?(pos : Pos)
    Boleite::IntRect.new(0, 0, @size.x, @size.y).contains? pos
  end

  ensures return_value.nil? || inside? return_value
  def find_tile(pos : Boleite::Vector2f)
    each_tile do |tile_pos|
      return tile_pos if tile_pos.inside? pos
    end
    return nil
  end

  def each_tile
    @data.each_key do |pos|
      yield pos, @data[pos]
    end
  end

  def render(renderer)
    @renderer.render self, renderer
  end
end