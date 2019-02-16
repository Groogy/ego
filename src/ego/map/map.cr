class Map
  @terrain : Terrainmap

  getter terrain, size

  def initialize(@size : Boleite::Vector2u)
    @terrain = Terrainmap.new @size
  end

  def width
    @size.x
  end

  def height
    @size.y
  end
end