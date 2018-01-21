class Map
  include CrystalClear

  class Data
    @height = 0.0
    @terrain : TerrainType?

    property height, terrain
  end

  @data : Array(Data)
  @size = Boleite::Vector2i.zero
  @renderer : MapRenderer

  getter size

  def initialize(@size)
    size = @size.x * @size.y
    @data = Array(Data).new(size) { |index| Data.new }
    @renderer = MapRenderer.new @size
  end

  def set_height(pos, height)
    @data[to_index(pos)].height = height
    @renderer.notify_change
  end

  def get_height(pos)
    @data[to_index(pos)].height
  end

  def get_height(x, y)
    get_height Boleite::Vector2i.new(x, y)
  end

  def set_terrain(pos, terrain)
    @data[to_index(pos)].terrain = terrain
    @renderer.notify_change
  end

  def get_terrain(pos)
    @data[to_index(pos)].terrain
  end

  def get_terrain(x, y)
    get_terrain Boleite::Vector2i.new(x, y)
  end

  def render(renderer)
    @renderer.render self, renderer
  end

  private def to_index(coord)
    coord.x + coord.y * @size.x
  end

  private def to_coord(index)
    Boleite::Vector2i.new index.to_i32 % @size.x, index.to_i32 / @size.y
  end
end