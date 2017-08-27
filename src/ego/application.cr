class EgoApplication < Boleite::Application
  CONFIGURATION_FILE = "config.yml"
  SHADER_FILE = "test.shader"
  
  def create_configuration : Boleite::Configuration
    if File.exists? CONFIGURATION_FILE
      File.open(CONFIGURATION_FILE, "r") do |file|
        serializer = Boleite::Serializer.new
        data = serializer.read(file)
        config = serializer.unmarshal(data, AppConfiguration)
        config.as(AppConfiguration)
      end
    else
      File.open(CONFIGURATION_FILE, "w") do |file|
        config = AppConfiguration.new 
        config.backend = @backend.default_config
        serializer = Boleite::Serializer.new
        serializer.marshal(config)
        serializer.dump(file)
        config
      end
    end
  end

  def create_renderer(gfx : Boleite::GraphicsContext) : Boleite::Renderer
    target = gfx.main_target
    camera = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0.0f32, 10.0f32)
    shader = Boleite::Shader.load_file SHADER_FILE, gfx
    Boleite::ForwardRenderer.new gfx, camera, shader
  end
end