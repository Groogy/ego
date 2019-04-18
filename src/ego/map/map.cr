class Map
  @terrain : Terrainmap
  @heightmap : Heightmap
  @heatmap : Heatmap
  @water_level = -0.1

  getter terrain, heightmap, heatmap
  getter size
  property water_level

  def initialize(@size : Boleite::Vector2u)
    @terrain = Terrainmap.new @size
    @heightmap = Heightmap.new @size
    @heatmap = Heatmap.new @size
  end

  def width
    @size.x
  end

  def height
    @size.y
  end
end