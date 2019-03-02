class Map
  @terrain : Terrainmap
  @heightmap : Heightmap

  getter terrain, heightmap, size

  def initialize(@size : Boleite::Vector2u)
    @terrain = Terrainmap.new @size
    @heightmap = Heightmap.new @size
  end

  def width
    @size.x
  end

  def height
    @size.y
  end
end