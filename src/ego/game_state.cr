struct Vertex < Boleite::Vertex
  @pos : Boleite::Vector4f32
  @color : Boleite::Colorf
  
  def initialize(pos, color)
    @pos = pos.to_f32
    @color = color.to_f32
  end
end

alias Vector4 = Boleite::Vector4f

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

class GameState < Boleite::State
  class InputHandler < Boleite::InputReceiver
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

  @input : InputHandler | Nil
  @renderer : Boleite::Renderer
  
  def initialize(@app : EgoApplication)
    super()

    gfx = @app.graphics
    target = gfx.main_target
    @camera = Boleite::Camera3D.new(60.0f32, target.width.to_f32, target.height.to_f32, 0.01f32, 100.0f32)
    shader = Boleite::Shader.load_file "test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera, shader
    @camera.move 0.0, 8.0, -2.5

    tileset = Boleite::Texture.load_file "tileset.png", gfx
    tileset.smooth = false
    @tilemap = Tilemap.new Boleite::Vector2u.new(64u32, 64u32), tileset
    generate_tilemap

    @input = nil
  end

  def generate_tilemap
    size = 64u32
    water = TileType.new "water", "Water", Boleite::Vector2u.new(1u32, 1u32)
    plains = TileType.new "plains", "Plains", Boleite::Vector2u.new(19u32, 1u32)
    mountains = TileType.new "mountains", "Mountains", Boleite::Vector2u.new(37u32, 1u32)
    @tilemap.add_tile_type water
    @tilemap.add_tile_type plains
    @tilemap.add_tile_type mountains

    center = Boleite::Vector2f.new size / 2.0 - 1, size / 2.0 - 1
    size.times do |x|
      size.times do |y|
        delta = Boleite::Vector2f.new center.x - x, center.y - y
        distance = Boleite::Vector.magnitude delta
        coord = Boleite::Vector2u.new x, y
        if distance < 12
          @tilemap.set_tile coord, mountains
        elsif distance < 30
          @tilemap.set_tile coord, plains
        else
          @tilemap.set_tile coord, water
        end

        if distance < 14
          height = 6u16 - distance.to_u16 / 2
          @tilemap.set_tile_height coord, height, distance != 0 && distance.to_u16 % 2 == 0
        end
      end
    end
  end

  def enable
    input = InputHandler.new(@camera)
    @app.input_router.register(input)
    @input = input
  end

  def disable
    @app.input_router.unregister(@input)
    @input = nil
  end

  def update(delta)
    if input = @input
      vector = Boleite::Vector3f.zero
      vector.z += 5.0 * delta.to_f if input.is_moving? :forward
      vector.z -= 5.0 * delta.to_f if input.is_moving? :backward
      vector.x -= 5.0 * delta.to_f if input.is_moving? :left
      vector.x += 5.0 * delta.to_f if input.is_moving? :right
      vector.y -= 5.0 * delta.to_f if input.is_moving? :down
      vector.y += 5.0 * delta.to_f if input.is_moving? :up
      @camera.move vector
    end
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @tilemap.render @renderer
    @renderer.present
  end
end