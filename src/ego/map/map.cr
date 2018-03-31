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

  def find_closest_point(a, b)
    closest_point = Boleite::Vector2i.zero
    closest_distance = 99999999.0
    each_point do |world, map|
      distance = Boleite::Vector.distance_to_segment a, b, world.to_f32
      if distance < closest_distance
        closest_point = map
        closest_distance = distance
      end
    end
    return closest_point, closest_distance
  end

  def each_point
    @data.each_with_index do |data, index|
      map = to_coord index
      world = Boleite::Vector3f.new map.x.to_f, data.height.to_f, map.y.to_f
      yield world, map
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