abstract class ToolBase
end

class HeightTool < ToolBase
  @amount : Int8

  def initialize(@amount, world, camera)
    super(world, camera)
  end

  def on_map_click(pos : Map::Pos)
    height = @world.map.get_height pos
    unless  height == 0 && @amount < 0 || 
            height == Map::MAX_HEIGHT && @amount > 0
      @world.map.set_height pos, height + @amount
    end
  end

  def label : String
    dir = @amount > 0 ? "Raise" : "Lower"
    "Height: #{dir}"
  end
end