class Terrainmap
  @terrain : Array(TerrainType?)
  @need_update = true

  def initialize(@size : Boleite::Vector2u)
    @terrain = Array(TerrainType?).new @size.x * @size.y, nil
  end

  def fill_with(terrain)
    @terrain.fill terrain
  end

  macro pos_to_index(pos)
    pos.x + pos.y * @size.x
  end

  def [](pos)
    index = pos_to_index pos
    @terrain[index]
  end

  def []=(pos, terrain : TerrainType?)
    index = pos_to_index pos
    @terrain[index] = terrain
    @need_update = true
  end
end