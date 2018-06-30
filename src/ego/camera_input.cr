
class CameraMouseDrag
  def initialize
    @dragging = false
    @last = Boleite::Vector2f.zero
  end

  def interested?(event : Boleite::InputEvent) : Bool
    if event.is_a? Boleite::MouseButtonEvent
      @dragging = event.action == Boleite::InputAction::Press
      @last = Boleite::Vector2f.zero
    end
    @dragging && event.class == Boleite::MousePosEvent
  end

  def translate(event : Boleite::InputEvent)
    event = event.as(Boleite::MousePosEvent)
    @last = event.pos if @last.x == 0 && @last.y == 0
    val = {event.x - @last.x, event.y - @last.y}
    @last = event.pos
    val
  end
end

class CameraMove
  @map = {
    Boleite::Key::W => :up, Boleite::Key::S => :down,
    Boleite::Key::A => :left, Boleite::Key::D => :right,
  }
  def interested?(event : Boleite::InputEvent) : Bool
    if event.is_a? Boleite::KeyEvent
      if event.action == Boleite::InputAction::Press || event.action == Boleite::InputAction::Release
        return @map.keys.includes? event.key
      end
    end
    return false
  end

  def translate(event : Boleite::InputEvent)
    event = event.as(Boleite::KeyEvent)
    event.claim
    {event.action == Boleite::InputAction::Press, @map[event.key]}
  end
end

class CameraZoom
  @map = {
    Boleite::Key::PageUp => :up, Boleite::Key::PageDown => :down
  }
  def interested?(event : Boleite::InputEvent) : Bool
    if event.is_a? Boleite::KeyEvent
      if event.action == Boleite::InputAction::Press || event.action == Boleite::InputAction::Release
        return @map.keys.includes? event.key
      end
    end
    return false
  end

  def translate(event : Boleite::InputEvent)
    event = event.as(Boleite::KeyEvent)
    event.claim
    {event.action == Boleite::InputAction::Press, @map[event.key]}
  end
end

class CameraInputHandler < Boleite::InputReceiver
  @move_actions = {
    :down => false, :up => false,
    :left => false, :right => false,
  }

  @zoom_actions = {
    :down => false, :up => false
  }

  def initialize(@camera : Boleite::Camera2D)
    register CameraMove, ->on_camera_move(Bool, Symbol)
    register CameraZoom, ->on_camera_zoom(Bool, Symbol)
    register CameraMouseDrag, ->on_camera_drag(Float64, Float64)
  end

  def on_camera_drag(x : Float64, y : Float64)
    @camera.move -x, -y
  end

  def on_camera_move(on : Bool, action : Symbol)
    @move_actions[action] = on
  end

  def on_camera_zoom(on : Bool, action : Symbol)
    @zoom_actions[action] = on
  end

  def is_moving?(direction)
    @move_actions[direction]
  end

  def is_zooming?(action)
    @zoom_actions[action]
  end

  def update(delta)
    scale = @camera.scale
    seconds = delta.to_f
    vector = Boleite::Vector2f.zero
    vector.x -= 500.0 if is_moving? :left
    vector.x += 500.0 if is_moving? :right
    vector.y -= 500.0 if is_moving? :up
    vector.y += 500.0 if is_moving? :down
    vector *= seconds * scale
    @camera.move vector

    scale -= 0.5 * seconds if is_zooming? :up
    scale += 0.5 * seconds if is_zooming? :down
    @camera.scale = scale.clamp 0.25, 3.0
  end
end
