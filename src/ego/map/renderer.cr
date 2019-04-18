class MapRenderer
  SHADER_FILE = "resources/shaders/map.shader"
  WATER_SHADER_FILE = "resources/shaders/water.shader"

  @@shader : Boleite::Shader?
  @@water_shader : Boleite::Shader?

  @vertices = Vertices.new
  @water_vertices = WaterVertices.new

  def notify_change
    @vertices.need_update = true
  end

  def render(map, renderer)
    render_ground map, renderer
    render_water map, renderer
  end

  def render_ground(map, renderer)
    gfx = renderer.gfx
    shader = get_shader gfx
    draw = @vertices.get_vertices map, gfx
    if draw.total_buffer_size > 0
      drawcall = Boleite::DrawCallContext.new draw, shader
      drawcall.uniforms["colorSampler"] = map.terrain.generate_texture gfx
      drawcall.uniforms["heightSampler"] = map.heightmap.generate_texture gfx
      drawcall.uniforms["heatSampler"] = map.heat.generate_texture gfx
      renderer.draw drawcall
    end
  end

  def render_water(map, renderer)
    gfx = renderer.gfx
    shader = get_water_shader gfx
    draw = @water_vertices.get_vertices map, gfx
    transform = Boleite::Matrix.translate Boleite::Matrix44f32.identity, Boleite::Vector3f32.new(0f32, map.water_level.to_f32, 0f32)

    drawcall = Boleite::DrawCallContext.new draw, shader, transform
    drawcall.uniforms["heatSampler"] = map.heat.generate_texture gfx
    renderer.draw drawcall
  end

  private def get_shader(gfx) : Boleite::Shader
    shader = @@shader
    if shader.nil?
      shader = create_shader gfx, SHADER_FILE
      @@shader = shader
    end
    shader
  end

  private def get_water_shader(gfx) : Boleite::Shader
    shader = @@water_shader
    if shader.nil?
      shader = create_shader gfx, WATER_SHADER_FILE
      @@water_shader = shader
    end
    shader
  end

  private def create_shader(gfx, file) : Boleite::Shader
    Boleite::Shader.load_file file, gfx
  end
end