abstract class ToolBase
end

class SpawnTool < ToolBase
  @tmpl : EntityTemplate

  def initialize(@tmpl, world, camera)
    super(world, camera)
  end

  def on_map_click(pos : Map::Pos)
    if @world.can_be_placed? @tmpl, pos
      @world.spawn_entity @tmpl, MapEntityPos.new(pos)
    end
  end

  def label : String
    "Spawn: #{@tmpl.name}"
  end
end