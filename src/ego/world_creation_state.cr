class WorldCreationState < Boleite::State
  def initialize(@app : EgoApplication)
    super()
    
    gfx = @app.graphics
    target = gfx.main_target
    @camera2d = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    shader = Boleite::Shader.load_file "resources/shaders/test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera2d, shader
    
    @gui = Boleite::GUI.new gfx, Boleite::Font.new(gfx, "resources/fonts/arial.ttf")
    @desktop = Boleite::GUI::Desktop.new
    build_gui target.size.to_f
  end

  def enable
    @gui.enable @app.input_router
    @gui.add_root @desktop
  end

  def disable
    @gui.disable @app.input_router
    @gui.remove_root @desktop
  end

  def update(delta)
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @gui.render
    @renderer.present
  end

  def start_world
    world = World.new
    world.load_data
    world.generate_map
    state = GameState.new @app, world
    @app.state_stack.replace state
  end

  def build_gui(size)
    @desktop.size = size
    label = Boleite::GUI::Label.new "Hello world!", Boleite::Vector2f.new(200.0, 20.0)
    @desktop.add label
  end
end