class MapRenderer
  SHADER_FILE = "map.shader"

  @@shader : Boleite::Shader?
  
  @vertices = Vertices.new
  @size : Boleite::Vector2i

  def initialize(@size)
  end

  def notify_change
    @vertices.need_update = true
  end

  def render(map, renderer)
    gfx = renderer.gfx
    shader = get_shader gfx
    shader.set_parameter "mapSize", map.size.to_f32
    draw = @vertices.get_vertices map, gfx
    if draw.total_buffer_size > 0
      drawcall = Boleite::DrawCallContext.new draw, shader
      renderer.draw drawcall
    end
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