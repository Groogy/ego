class GameState < Boleite::State
  @input : CameraInputHandler?
  @renderer : Boleite::Renderer
  @fps_timer = 0.0
  @fps_counter = 0
  @frame_time = Time::Span.zero
  
  def initialize(@app : EgoApplication)
    super()

    gfx = @app.graphics
    @font = Boleite::Font.new gfx, "arial.ttf"
    @gui = Boleite::GUI.new gfx, @app.input_router

    target = gfx.main_target
    @camera3d = Boleite::Camera3D.new(60.0f32, target.width.to_f32, target.height.to_f32, 0.01f32, 100.0f32)
    @camera2d = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    shader = Boleite::Shader.load_file "test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera3d, shader
    @camera3d.move 0.0, 8.0, -2.5

    @world = World.new
    @world.generate_map

    @input = nil

    @fps_text = Boleite::Text.new @font, "FPS:"
    @fps_text.formatter.add /(\d+)/, Boleite::Color.yellow
    @fps_text.size = 24u32
    @fps_text.position = Boleite::Vector2f.new 10.0, 10.0
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

    update_game delta

    @fps_counter += 1
    @fps_timer += delta.to_f
    if @fps_timer > 1.0
      @fps_text.text = "FPS: #{@fps_counter}"
      @fps_timer -= 1.0
      @fps_counter = 0
    end
  end

  def update_game(delta)
    target = Time::Span.new seconds: 1, nanoseconds: 0
    speed = 1
    @frame_time += delta
    if @frame_time >= target * speed
      @frame_time = Time::Span.zero
      @world.update
    end
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @renderer.camera = @camera3d
    @world.render @renderer
    @renderer.camera = @camera2d
    @renderer.draw @fps_text

    @gui.render
    @renderer.present
  end
end
