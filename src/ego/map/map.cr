class Map
  @terrain : Terrainmap
  @heightmap : Heightmap
  @heat : ValueMap
  @humidity : ValueMap
  @water_level = -0.1

  getter terrain, heightmap, heat, humidity
  getter size
  property water_level

  def initialize(@size : Boleite::Vector2u)
    @terrain = Terrainmap.new @size
    @heightmap = Heightmap.new @size
    @heat = ValueMap.new 0.1f32, @size
    @humidity = HumidityMap.new @size
  end

  def over_water_level?(x, y) : Bool
    over_water_level? Boleite::Vector2u.new(x, y)
  end

  def over_water_level?(pos) : Bool
    height = @heightmap[pos]
    height > water_level
  end

  def width
    @size.x
  end

  def height
    @size.y
  end
end