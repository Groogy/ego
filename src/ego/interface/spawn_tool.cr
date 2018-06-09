abstract class ToolBase
end

class SpawnTool < ToolBase
  @tmpl : EntityTemplate

  def initialize(@tmpl, world, camera)
    super(world, camera)
  end

  def on_map_click(pos : Map::Pos)
    @world.spawn_entity @tmpl, MapEntityPos.new(pos)
  end

  def label : String
    "Spawn: #{@tmpl.name}"
  end
end