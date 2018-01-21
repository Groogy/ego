class MapRenderer
  SHADER_FILE = "map.shader"

  @@shader : Boleite::Shader?
  
  @size : Boleite::Vector2i
  @vertices = Vertices.new

  def initialize(@size)
  end

  def notify_change
    @vertices.need_update = true
  end

  def render(map, renderer)
    gfx = renderer.gfx
    vertices = @vertices.get_vertices map, gfx
    shader = get_shader gfx

    drawcall = Boleite::DrawCallContext.new vertices, shader
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