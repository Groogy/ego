abstract class ToolBase
end

class TerrainTool < ToolBase
  @terrain : TerrainType

  def initialize(@terrain, world, camera)
    super(world, camera)
  end

  def on_map_click(pos : Map::Pos)
    @world.map.set_terrain pos, @terrain
  end

  def label : String
    "Terrain: #{@terrain.name}"
  end
end