class GameState < Boleite::State
  @input : CameraInputHandler?
  @renderer : Boleite::Renderer
  @fps_timer = 0.0
  @fps_counter = 0
  
  def initialize(@app : EgoApplication)
    super()

    gfx = @app.graphics
    target = gfx.main_target
    @camera3d = Boleite::Camera3D.new(60.0f32, target.width.to_f32, target.height.to_f32, 0.01f32, 100.0f32)
    @camera2d = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    shader = Boleite::Shader.load_file "test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera3d, shader
    @camera3d.move 0.0, 8.0, -2.5

    tileset = Boleite::Texture.load_file "tileset.png", gfx
    tileset.smooth = false
    @world = World.new tileset
    @world.generate_tilemap

    @input = nil

    @font = Boleite::Font.new gfx, "arial.ttf"
    @fps_text = Boleite::Text.new @font, "FPS:"
    @fps_text.formatter.add /(\d+)/, Boleite::Color.yellow
    @fps_text.size = 24u32
  end

  def enable
    input = CameraInputHandler.new(@camera3d)
    @app.input_router.register(input)
    @input = input
  end

  def disable
    @app.input_router.unregister(@input)
    @input = nil
  end

  def update(delta)
    if input = @input
      input.update delta
    end

    @world.update

    @fps_counter += 1
    @fps_timer += delta.to_f
    if @fps_timer > 1.0
      @fps_text.text = "FPS: #{@fps_counter}"
      @fps_timer -= 1.0
      @fps_counter = 0
    end
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @renderer.camera = @camera3d
    @world.render @renderer
    @renderer.camera = @camera2d
    @renderer.draw @fps_text
    @renderer.present
  end
end