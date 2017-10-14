
class CameraMouseDrag
  def initialize
    @dragging = false
    @last = Boleite::Vector2f.zero
  end

  def interested?(event : Boleite::InputEvent) : Bool
    if event.is_a? Boleite::MouseButtonEvent
      @dragging = event.action == Boleite::InputAction::Press
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
    Boleite::Key::W => :forward, Boleite::Key::S => :backward,
    Boleite::Key::A => :left, Boleite::Key::D => :right,
    Boleite::Key::C => :down, Boleite::Key::Z => :up
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
    { event.action == Boleite::InputAction::Press, @map[event.key] }
  end
end

class CameraInputHandler < Boleite::InputReceiver
  @move_actions = {
    :forward => false, :backward => false, 
    :left => false, :right => false,
    :down => false, :up => false
  }

  def initialize(@camera : Boleite::Camera3D)
    register CameraMouseDrag, ->on_camera_drag(Float64, Float64)
    register CameraMove, ->on_camera_move(Bool, Symbol)
  end

  def on_camera_drag(x : Float64, y : Float64)
    @camera.rotate y / 360, x / 360, 0.0
  end

  def on_camera_move(on : Bool, action : Symbol)
    @move_actions[action] = on
  end

  def is_moving?(direction)
    @move_actions[direction]
  end
end