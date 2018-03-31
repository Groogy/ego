abstract class ToolBase
  abstract def label : String
  abstract def on_map_click(pos : Boleite::Vector2i)

  @world : World
  @camera : Boleite::Camera3D
  @mouse_last = Boleite::Vector2f.zero

  def initialize(@world, @camera)
  end

  def on_screen_click(pos : Boleite::Vector2f)
    ray = @camera.screen_point_to_ray pos
    #ray.direction.z = -ray.direction.z 
    pp ray
    point, distance = @world.map.find_closest_point ray.origin, ray.origin + ray.direction * @camera.far
    on_map_click point if distance < 1
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
    {@mouse_last}
  end
end