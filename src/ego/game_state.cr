class GameState < Boleite::State
  @input : CameraInputHandler?
  @rendering : GameStateRenderHelper
  @fps_timer = 0.0
  @fps_counter = 0
  @frame_time = Time::Span.zero
  
  def initialize(@app : EgoApplication)
    super()

    gfx = @app.graphics
    
    @gui = Boleite::GUI.new gfx, @app.input_router
    @rendering = GameStateRenderHelper.new gfx

    @world = World.new
    @world.generate_map
  end

  def enable
    input = CameraInputHandler.new(@rendering.camera3d)
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
    update_fps delta
  end

  def update_fps(delta)
    @fps_counter += 1
    @fps_timer += delta.to_f
    if @fps_timer > 1.0
      @rendering.update_fps(@fps_counter)
      @fps_timer -= 1.0
      @fps_counter = 0
    end
  end

  def update_game(delta)
    speed = 1.0
    target = Time::Span.new seconds: 0, nanoseconds: (1_000_000_000 * speed).to_i
    @frame_time += delta
    if @frame_time >= target
      @frame_time = Time::Span.zero
      @world.update
      true
    else
      false
    end
  end

  def render(delta)
    @rendering.clear Boleite::Color.black
    @rendering.set_3d_camera
    @world.render @rendering.renderer

    @rendering.set_2d_camera
    @gui.render
    @rendering.present
  end
end
