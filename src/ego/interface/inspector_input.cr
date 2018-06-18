class InspectorClickInput
  @world : World
  @camera : Boleite::Camera2D
  @mouse_last = Boleite::Vector2f.zero

  def initialize(@world, @camera)
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
    pos = @mouse_last * @camera.scale + @camera.position
    point = @world.map.find_tile pos
    {point}
  end
end