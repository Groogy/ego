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
    @humidity = ValueMap.new 0f32, @size
  end

  def width
    @size.x
  end

  def height
    @size.y
  end
end