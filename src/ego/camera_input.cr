
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

  def update(delta)
    seconds = delta.to_f
    transform = @camera.transformation.to_f64
    forward = Boleite::Matrix.forward transform
    left = Boleite::Matrix.left transform
    vector = Boleite::Vector3f.zero
    vector += forward * 5.0 * seconds if is_moving? :forward
    vector -= forward * 5.0 * seconds if is_moving? :backward
    vector -= left * 5.0 * seconds if is_moving? :left
    vector += left * 5.0 * seconds if is_moving? :right

    vector.y -= 5.0 * seconds if is_moving? :down
    vector.y += 5.0 * seconds if is_moving? :up
    @camera.move vector
  end
end