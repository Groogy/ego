abstract class ToolBase
  abstract def label : String
  abstract def on_map_click(pos : Map::Pos)

  @world : World
  @camera : Boleite::Camera2D
  @mouse_last = Boleite::Vector2f.zero

  def initialize(@world, @camera)
  end

  def on_screen_click(pos : Boleite::Vector2f)
    pos = pos * @camera.scale + @camera.position
    point = @world.map.find_tile pos
    on_map_click point if point
  end

  def interested?(event : Boleite::InputEvent) : Bool
    if event.is_a? Boleite::MouseButtonEvent
      if event.action == Boleite::InputAction::Press && 
        return event.button == Boleite::Mouse::Left
      end
    end
    if event.is_a? Boleite::MousePosEvent
      @mouse_last = event.pos
    end
    return false
  end

  def translate(event : Boleite::InputEvent)
    event.claim
    {@mouse_last}
  end
end