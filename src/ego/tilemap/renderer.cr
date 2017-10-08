class TilemapRenderer
  SHADER_FILE = "tilemap.shader"

  TILE_SIZE = Tilemap::TILE_SIZE.to_f32

  struct Vertex < Boleite::Vertex
    @pos : Boleite::Vector4f32
    @uv : Boleite::Vector2f32

    def initialize(pos, uv)
      @pos = Boleite::Vector4f32.new(pos)
      @uv = Boleite::Vector2f32.new(uv)
    end
  end

  @@shader : Boleite::Shader?
  
  @size : Boleite::Vector2u
  @tileset : Boleite::Texture
  @need_update = true
  @vbo : Boleite::VertexBufferObject?

  def initialize(@size, @tileset)
  end

  def notify_change
    @need_update = true
  end

  def render(tilemap, renderer)
    gfx = renderer.gfx
    vertices = get_vertices tilemap, gfx
    shader = get_shader gfx

    drawcall = Boleite::DrawCallContext.new vertices, shader
    drawcall.uniforms["albedoTexture"] = @tileset
    renderer.draw drawcall
  end

  private def get_vertices(tilemap, gfx) : Boleite::VertexBufferObject
    vbo = @vbo
    if vbo.nil?
      vbo = create_vertices gfx
      @vbo = vbo
    end
    if @need_update
      update_vertices tilemap, vbo 
      @need_update = false
    end
    vbo
  end

  private def create_vertices(gfx) : Boleite::VertexBufferObject
    layout = Boleite::VertexLayout.new [
      Boleite::VertexAttribute.new(0, 4, :float, 24u32, 0u32,  0u32),
      Boleite::VertexAttribute.new(0, 2, :float, 24u32, 16u32, 0u32)
    ]
    vbo = gfx.create_vertex_buffer_object
    vbo.layout = layout
    vbo.primitive = Boleite::Primitive::Triangles
    vbo.create_buffer
    vbo
  end

  private def update_vertices(tilemap, vbo)
    buffer = vbo.get_buffer 0
    buffer.clear
    tilemap.each_tile do |tile, coord|
      if type = tile.tile_type
        build_vertices_for_tile tile, type, coord, buffer
      end
    end
  end

  private def build_vertices_for_tile(tile, type, coord, buffer)
    coord = coord.to_f32
    uv = type.uv.to_f32 / @tileset.size.to_f32
    extent_x = TILE_SIZE / @tileset.size.x
    extent_y = TILE_SIZE / @tileset.size.y
    vertex1 = Vertex.new [coord.x     , 0f32, coord.y     , 1f32], [uv.x         , uv.y]
    vertex2 = Vertex.new [coord.x     , 0f32, coord.y+1f32, 1f32], [uv.x         , uv.y+extent_y]
    vertex3 = Vertex.new [coord.x+1f32, 0f32, coord.y     , 1f32], [uv.x+extent_x, uv.y]
    vertex4 = Vertex.new [coord.x+1f32, 0f32, coord.y+1f32, 1f32], [uv.x+extent_x, uv.y+extent_y]

    buffer.add_data vertex1
    buffer.add_data vertex2
    buffer.add_data vertex3
    buffer.add_data vertex2
    buffer.add_data vertex4
    buffer.add_data vertex3
  end

  private def get_shader(gfx) : Boleite::Shader
    shader = @@shader
    if shader.nil?
      shader = create_shader gfx
      @@shader = shader
    end
    shader
  end

  private def create_shader(gfx) : Boleite::Shader
    Boleite::Shader.load_file SHADER_FILE, gfx
  end
end