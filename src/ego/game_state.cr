alias Vector4f32 = Boleite::Vector4f32
alias Vector2f32 = Boleite::Vector2f32

struct SimpleVertex < Boleite::Vertex
  @pos   = Vector4f32.zero
  @color = Vector4f32.zero
  @uv    = Vector2f32.zero

  def initialize
  end

  def initialize(@pos, @color, @uv)
  end

  def initialize(pos, color, uv)
    @pos   = Vector4f32.new(pos)
    @color = Vector4f32.new(color)
    @uv    = Vector2f32.new(uv)
  end
end

class GameState < Boleite::State
  class InputHandler < Boleite::InputReceiver
    def initialize(state)
      register Boleite::PassThroughAction, ->on_input(Boleite::InputEvent)
    end

    def on_input(event)
    end
  end

  @input : InputHandler | Nil
  @vbo : Boleite::VertexBufferObject
  
  def initialize(@app : EgoApplication)
    super()

    vertices = [
      SimpleVertex.new([0.0f32, 0.0f32, 0.0f32, 1.0f32], [1.0f32, 0.0f32, 0.0f32, 1.0f32], [0.0f32, 0.0f32]),
      SimpleVertex.new([0.0f32, 100.0f32, 0.0f32, 1.0f32], [0.0f32, 1.0f32, 0.0f32, 1.0f32], [0.0f32, 1.0f32]),
      SimpleVertex.new([100.0f32, 0.0f32, 0.0f32, 1.0f32], [0.0f32, 0.0f32, 1.0f32, 1.0f32], [1.0f32, 0.0f32]),
      SimpleVertex.new([100.0f32, 100.0f32, 0.0f32, 1.0f32], [1.0f32, 1.0f32, 1.0f32, 1.0f32], [1.0f32, 1.0f32]),
    ]

    layout = Boleite::VertexLayout.new [
      Boleite::VertexAttribute.new(4, :float, 40_u32, 0_u32),
      Boleite::VertexAttribute.new(4, :float, 40_u32, 16_u32),
      Boleite::VertexAttribute.new(2, :float, 40_u32, 32_u32),
    ]

    @vbo = @app.graphics.create_vertex_buffer_object
    @vbo.layout = layout
    @vbo.primitive = Boleite::Primitive::TrianglesStrip
    buffer = @vbo.create_buffer
    buffer.add_data vertices[0]
    buffer.add_data vertices[1]
    buffer.add_data vertices[2]
    buffer.add_data vertices[3]

    @input = nil
  end

  def enable
    input = InputHandler.new(self)
    @app.input_router.register(input)
    @input = input
  end

  def disable
    @app.input_router.unregister(@input)
    @input = nil
  end

  def update(delta)
  end

  def render(delta, renderer)
    renderer.draw_vertices @vbo, nil, Boleite::Matrix44f32.identity
  end
end