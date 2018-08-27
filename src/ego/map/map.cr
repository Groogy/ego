class Map
  include CrystalClear

  TILE_WIDTH = 16
  MAX_HEIGHT = 64

  class Data
    @height = 0u8
    @terrain : TerrainType?

    property height, terrain
  end

  @data = [] of Data
  @size = Boleite::Vector2i.zero
  @view_rotation = 0
  @renderer : MapRenderer

  getter size, data, view_rotation

  def initialize(@size)
    @renderer = MapRenderer.new @size
    @data = Array(Data).new @size.x * @size.y do 
      Data.new
    end
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
  requires height >= 0 && height <= MAX_HEIGHT
  def set_height(pos, height)
    @data[Pos.new(pos).to_index self].height = height.to_u8
    @renderer.notify_change
  end

  requires inside? pos
  def get_height(pos)
    @data[Pos.new(pos).to_index self].height.to_u8
  end

  def get_height(x, y)
    get_height Boleite::Vector2i.new(x, y)
  end

  requires inside? pos
  def get_movement_cost(pos)
    terrain = get_terrain pos
    if terrain
      terrain.cost
    else
      Float64::MAX
    end
  end

  requires inside? pos
  def get_movement_cost(x, y)
    get_movement_cost Boleite::Vector2i.new(x, y)
  end

  requires inside? pos
  def set_terrain(pos, terrain)
    @data[Pos.new(pos).to_index self].terrain = terrain
    @renderer.notify_change
  end

  requires inside? pos
  def get_terrain(pos)
    @data[Pos.new(pos).to_index self].terrain
  end

  requires inside? pos
  def get_terrain(x, y)
    get_terrain Boleite::Vector2i.new(x, y)
  end

  requires data.size == @data.size
  def apply_data(data, terrains)
    data.each do |d|
      pos = Pos.new (d[0] % @size.x).to_i16, (d[0] / @size.y).to_i16
      index = pos.to_index self
      @data[index].terrain = terrains.find d[1]
      @data[index].height = d[2]
    end
  end

  def inside?(pos)
    Boleite::IntRect.new(0, 0, @size.x, @size.y).contains? pos
  end

  def flat?(pos, size)
    value = get_height pos
    size.y.times do |y|
      size.x.times do |x|
        p = pos
        p.x += x
        p.y += y
        return false if value != get_height p
      end
    end
    return true
  end

  ensures return_value.nil? || inside? return_value
  def find_tile(pos : Boleite::Vector2f)
    each_tile_reversed do |tile_pos|
      return tile_pos if tile_pos.inside? pos
    end
    return nil
  end

  def each_tile
    @data.each_index do |index|
      pos = Pos.new index, self
      yield pos, @data[index]
    end
  end

  def each_tile_reversed
    @size.y.downto 1 do |y|
      @size.x.downto 1 do |x|
        pos = Pos.new((x-1).to_i16, (y-1).to_i16).rotate_by self
        yield pos, @data[pos.to_index self]
      end
    end
  end

  def render(renderer)
    @renderer.render self, renderer
  end
end