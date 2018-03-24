class Map
  include CrystalClear

  class Data
    @height = 0.0f32
    @terrain : TerrainType?

    property height, terrain
  end

  @data : Array(Data)
  @size = Boleite::Vector2i.zero
  @renderer : MapRenderer

  getter size, data

  def initialize(@size)
    size = @size.x * @size.y
    @data = Array(Data).new(size) { |index| Data.new }
    @renderer = MapRenderer.new @size
  end

  def set_height(pos, height)
    @data[to_index(pos)].height = height.to_f32
    @renderer.notify_change
  end

  def get_height(pos)
    @data[to_index(pos)].height.to_f64
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

  requires data.size == @data.size
  def apply_data(data, terrains)
    data.each_index do |index|
      @data[index].terrain = terrains.find data[index][0]
      @data[index].height = data[index][1]
    end
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