class EntityRenderer
  SHADER_FILE = "resources/shaders/entity.shader"
  TEXTURE_FILE = "resources/entities.png"

  @@shader : Boleite::Shader?
  @@texture : Boleite::Texture?

  @vertices = Vertices.new
  @selected_tile : Map::Pos?

  def initialize
  end

  def notify_change
    @vertices.need_update = true
  end

  def selected_tile=(@selected_tile : Map::Pos?)
    notify_change
  end

  def render(entities, map, renderer)
    gfx = renderer.gfx
    texture = get_texture gfx
    shader = get_shader gfx
    shader.set_parameter "albedoSampler", texture
    shader.set_parameter "mapSize", map.size.to_f32
    draw = @vertices.get_vertices @selected_tile, entities, map, gfx
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

  private def get_texture(gfx) : Boleite::Texture
    texture = @@texture
    if texture.nil?
      texture = create_texture gfx
      @@texture = texture
    end
    texture
  end

  private def create_texture(gfx) : Boleite::Texture
    texture = Boleite::Texture.load_file TEXTURE_FILE, gfx
    texture.smooth = false
    texture
  end
end