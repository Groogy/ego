class GameState < Boleite::State
  @camera_input : CameraInputHandler?
  @game_input : GameStateInputHandler?
  @rendering : GameStateRenderHelper
  @world : World
  @frame_time = Time::Span.zero
  
  def initialize(@app : EgoApplication, @world : World)
    super()

    gfx = @app.graphics
    
    @gui = Boleite::GUI.new gfx, @app.input_router
    @rendering = GameStateRenderHelper.new gfx
    @interface = GameStateInterface.new @gui, @app, @world
  end

  def enable
    @interface.enable
    camera_input = CameraInputHandler.new @rendering.camera3d
    game_input = GameStateInputHandler.new @interface
    @app.input_router.register camera_input
    @app.input_router.register game_input
    @camera_input = camera_input
    @game_input = game_input
  end

  def disable
    @app.input_router.unregister @camera_input
    @app.input_router.unregister @game_input
    @camera_input = nil
    @game_input = nil
    @interface.disable
  end

  def update(delta)
    if input = @camera_input
      input.update delta
    end

    did_update = update_game delta
    @interface.update did_update
  end

  def update_game(delta)
    speed = @interface.control_menu.speed_modifier
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
