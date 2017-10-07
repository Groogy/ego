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

class GameState < Boleite::State
  class InputHandler < Boleite::InputReceiver
    def initialize(@camera : Boleite::Camera3D)
      register CameraMouseDrag, ->on_camera_move(Float64, Float64)
    end

    def on_camera_move(x : Float64, y : Float64)
      @camera.rotate y / 360, x / 360, 0.0
    end
  end

  @input : InputHandler | Nil
  @renderer : Boleite::Renderer
  @vbo : Boleite::VertexBufferObject
  @rot = 0.0
  
  def initialize(@app : EgoApplication)
    super()

    gfx = @app.graphics
    target = gfx.main_target
    @camera = Boleite::Camera3D.new(90.0f32, target.width.to_f32, target.height.to_f32, 0.01f32, 10.0f32)
    shader = Boleite::Shader.load_file "test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera, shader
    @camera.move 0.0, 0.0, -2.5

    vertices = [
      Vertex.new(Vector4.new(-1.0, -1.0, -1.0, 1.0), Vector4.new(1.0, 0.0, 0.0, 1.0)),
      Vertex.new(Vector4.new(-1.0,  1.0, -1.0, 1.0), Vector4.new(1.0, 0.0, 0.0, 1.0)),
      Vertex.new(Vector4.new( 1.0, -1.0, -1.0, 1.0), Vector4.new(1.0, 0.0, 0.0, 1.0)),
      Vertex.new(Vector4.new( 1.0,  1.0, -1.0, 1.0), Vector4.new(1.0, 0.0, 0.0, 1.0)),
      Vertex.new(Vector4.new( 1.0, -1.0, -1.0, 1.0), Vector4.new(0.0, 1.0, 0.0, 1.0)),
      Vertex.new(Vector4.new( 1.0,  1.0, -1.0, 1.0), Vector4.new(0.0, 1.0, 0.0, 1.0)),
      Vertex.new(Vector4.new( 1.0, -1.0,  1.0, 1.0), Vector4.new(0.0, 1.0, 0.0, 1.0)),
      Vertex.new(Vector4.new( 1.0,  1.0,  1.0, 1.0), Vector4.new(0.0, 1.0, 0.0, 1.0)),
      Vertex.new(Vector4.new( 1.0, -1.0,  1.0, 1.0), Vector4.new(0.0, 0.0, 1.0, 1.0)),
      Vertex.new(Vector4.new( 1.0,  1.0,  1.0, 1.0), Vector4.new(0.0, 0.0, 1.0, 1.0)),
      Vertex.new(Vector4.new(-1.0, -1.0,  1.0, 1.0), Vector4.new(0.0, 0.0, 1.0, 1.0)),
      Vertex.new(Vector4.new(-1.0,  1.0,  1.0, 1.0), Vector4.new(0.0, 0.0, 1.0, 1.0)),
      Vertex.new(Vector4.new(-1.0, -1.0,  1.0, 1.0), Vector4.new(0.0, 1.0, 1.0, 1.0)),
      Vertex.new(Vector4.new(-1.0,  1.0,  1.0, 1.0), Vector4.new(0.0, 1.0, 1.0, 1.0)),
      Vertex.new(Vector4.new(-1.0, -1.0, -1.0, 1.0), Vector4.new(0.0, 1.0, 1.0, 1.0)),
      Vertex.new(Vector4.new(-1.0,  1.0, -1.0, 1.0), Vector4.new(0.0, 1.0, 1.0, 1.0)),
    ]
    layout = Boleite::VertexLayout.new [
      Boleite::VertexAttribute.new(0, 4, :float, 32u32,  0u32, 0u32),
      Boleite::VertexAttribute.new(0, 4, :float, 32u32, 16u32, 0u32),
    ]
    @vbo = gfx.create_vertex_buffer_object
    @vbo.layout = layout
    @vbo.primitive = Boleite::Primitive::TrianglesStrip
    buffer = @vbo.create_buffer
    vertices.each { |vertex| buffer.add_data vertex }

    @input = nil
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
  end

  def render(delta)
    @rot += delta.to_f
    matrix = Boleite::Matrix.rotate_around_y Boleite::Matrix44f32.identity, @rot.to_f32
    @renderer.clear Boleite::Color.black
    drawcall = Boleite::DrawCallContext.new @vbo, matrix
    @renderer.draw drawcall
    @renderer.present
  end
end