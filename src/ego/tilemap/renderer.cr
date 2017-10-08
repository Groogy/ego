class TilemapRenderer
  SHADER_FILE = "tilemap.shader"

  TILE_SIZE = Tilemap::TILE_SIZE.to_f32

  struct Vertex < Boleite::Vertex
    @pos : Boleite::Vector4f32
    @uv : Boleite::Vector2f32

    getter pos, uv

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
        surrounding = tilemap.get_surrounding_tiles coord
        build_vertices_for_tile tile, type, coord, surrounding, buffer
      end
    end
  end

  private def build_vertices_for_tile(tile, type, coord, surrounding, buffer)
    coord = coord.to_f32
    uv = type.uv.to_f32 / @tileset.size.to_f32
    extent = Boleite::Vector2f32.new TILE_SIZE / @tileset.size.x, TILE_SIZE / @tileset.size.y
    height = tile.height.to_f32

    build_roof_for_tile buffer, coord, height, uv, extent
    if side = surrounding[0]
      build_north_wall_for_tile buffer, coord, height, side.height, uv, extent if side.height < height
    end
    if side = surrounding[1]
      build_east_wall_for_tile buffer, coord, height, side.height, uv, extent if side.height < height
    end
    if side = surrounding[2]
      build_south_wall_for_tile buffer, coord, height, side.height, uv, extent if side.height < height
    end
    if side = surrounding[3]
      build_west_wall_for_tile buffer, coord, height, side.height, uv, extent if side.height < height
    end
  end

  private def build_roof_for_tile(buffer, coord, height, uv, extent)
    vertex1 = Vertex.new [coord.x,      height, coord.y,      1f32], [uv.x, uv.y]
    vertex2 = Vertex.new [coord.x,      height, coord.y+1f32, 1f32], [uv.x, uv.y+extent.y]
    vertex3 = Vertex.new [coord.x+1f32, height, coord.y,      1f32], [uv.x+extent.x, uv.y]
    vertex4 = Vertex.new [coord.x+1f32, height, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
    buffer.add_data vertex1
    buffer.add_data vertex3
    buffer.add_data vertex2
    buffer.add_data vertex2
    buffer.add_data vertex3
    buffer.add_data vertex4
  end

  private def build_north_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
    delta = my_height - other_height
    vertex1 = Vertex.new [coord.x,      my_height,         coord.y+1f32, 1f32], [uv.x,          uv.y+extent.y]
    vertex2 = Vertex.new [coord.x+1f32, my_height,         coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
    vertex3 = Vertex.new [coord.x,      my_height - delta, coord.y+1f32, 1f32], [uv.x,          uv.y]
    vertex4 = Vertex.new [coord.x+1f32, my_height - delta, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y]
    buffer.add_data vertex1
    buffer.add_data vertex2
    buffer.add_data vertex3
    buffer.add_data vertex2
    buffer.add_data vertex4
    buffer.add_data vertex3
  end

  private def build_east_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
    delta = my_height - other_height
    vertex1 = Vertex.new [coord.x+1f32, my_height,         coord.y,      1f32], [uv.x,          uv.y+extent.y]
    vertex2 = Vertex.new [coord.x+1f32, my_height,         coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
    vertex3 = Vertex.new [coord.x+1f32, my_height - delta, coord.y,      1f32], [uv.x,          uv.y]
    vertex4 = Vertex.new [coord.x+1f32, my_height - delta, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y]
    buffer.add_data vertex1
    buffer.add_data vertex3
    buffer.add_data vertex2
    buffer.add_data vertex2
    buffer.add_data vertex3
    buffer.add_data vertex4
  end

  private def build_south_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
    delta = my_height - other_height
    vertex1 = Vertex.new [coord.x,      my_height,         coord.y, 1f32], [uv.x,          uv.y+extent.y]
    vertex2 = Vertex.new [coord.x+1f32, my_height,         coord.y, 1f32], [uv.x+extent.x, uv.y+extent.y]
    vertex3 = Vertex.new [coord.x,      my_height - delta, coord.y, 1f32], [uv.x,          uv.y]
    vertex4 = Vertex.new [coord.x+1f32, my_height - delta, coord.y, 1f32], [uv.x+extent.x, uv.y]
    buffer.add_data vertex1
    buffer.add_data vertex3
    buffer.add_data vertex2
    buffer.add_data vertex2
    buffer.add_data vertex3
    buffer.add_data vertex4
  end

  private def build_west_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
    delta = my_height - other_height
    vertex1 = Vertex.new [coord.x, my_height,         coord.y,      1f32], [uv.x,          uv.y+extent.y]
    vertex2 = Vertex.new [coord.x, my_height,         coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
    vertex3 = Vertex.new [coord.x, my_height - delta, coord.y,      1f32], [uv.x,          uv.y]
    vertex4 = Vertex.new [coord.x, my_height - delta, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y]
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