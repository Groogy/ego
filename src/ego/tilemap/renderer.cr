class TilemapRenderer
  SHADER_FILE = "tilemap.shader"

  TILE_SIZE = Tilemap::TILE_SIZE.to_f32

  @@shader : Boleite::Shader?
  
  @size : Boleite::Vector2u
  @tileset : Boleite::Texture
  @vertices = Vertices.new

  def initialize(@size, @tileset)
  end

  def notify_change
    @vertices.need_update = true
  end

  def render(tilemap, renderer)
    gfx = renderer.gfx
    vertices = @vertices.get_vertices tilemap, @tileset.size, gfx
    shader = get_shader gfx

    drawcall = Boleite::DrawCallContext.new vertices, shader
    drawcall.uniforms["albedoTexture"] = @tileset
    renderer.draw drawcall
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