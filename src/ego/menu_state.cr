class MenuState < Boleite::State
  DEFAULT_SAVE_FILE = "saves/default.yml"

  def initialize(@app : EgoApplication)
    super()
    
    gfx = @app.graphics
    target = gfx.main_target
    @camera2d = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    shader = Boleite::Shader.load_file "test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera2d, shader
    
    @gui = Boleite::GUI.new gfx, @app.input_router
    @window = Boleite::GUI::Window.new
    build_gui target.size
  end

  def enable
    @gui.add_root @window
  end

  def disable
    @gui.remove_root @window
  end

  def update(delta)
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @gui.render
    @renderer.present
  end

  def new_game
    world = World.new
    world.generate_map
    state = GameState.new @app, world
    @app.state_stack.push state
  end

  def load_game
    world = File.open(DEFAULT_SAVE_FILE, "r") do |file|
      serializer = Boleite::Serializer.new
      data = serializer.read(file)
      tmp = serializer.unmarshal(data, World)
      tmp.as(World)
    end
    state = GameState.new @app, world
    @app.state_stack.push state
  end

  def quit
    @app.close
  end

  def build_gui(size)
    @window.header_text = "Main Menu"
    container = Boleite::GUI::Layout.new :vertical
    
    button = Boleite::GUI::Button.new "New World", Boleite::Vector2f.new(200.0, 24.0)
    button.click.on { new_game }
    container.add button

    button = Boleite::GUI::Button.new "Continue", Boleite::Vector2f.new(200.0, 24.0)
    button.click.on { load_game }
    container.add button

    button = Boleite::GUI::Button.new "Quit", Boleite::Vector2f.new(200.0, 24.0)
    button.click.on { quit }
    container.add button

    @window.add container
    window_size = @window.size
    @window.position = Boleite::Vector2f.new size.x / 2 - window_size.x / 2, size.y / 2 - window_size.y / 2
  end
end